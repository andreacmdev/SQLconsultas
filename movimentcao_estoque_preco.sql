WITH cte_datas_base AS (
    SELECT GENERATE_SERIES(
        DATE '2026-01-01',
        DATE_TRUNC('month', CURRENT_DATE),
        INTERVAL '1 month'
    )::DATE AS data_base
),
cte_base_filtrada AS (
    SELECT
        unidade,
        cod_produto,
        nome_produto,
        categoria,
        classe,
        subclasse,
        data_movimentacao::timestamp AS dt,
        DATE_TRUNC('month', data_movimentacao::timestamp)::DATE AS mes,
        tipo_movimentacao,
        saldo_dia,
        custo_unitario,
        qtd_movimentacao,
        precovenda
    FROM estoque_produtos
    WHERE data_movimentacao::timestamp >= DATE '2026-01-01'
      AND data_movimentacao::timestamp <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
),
cte_ultima_movimentacao_mes AS (
    SELECT
        unidade,
        cod_produto,
        DATE_TRUNC('month', dt)::DATE AS data_base,
        MAX(dt) AS ultima_data
    FROM cte_base_filtrada
    GROUP BY unidade, cod_produto, DATE_TRUNC('month', dt)::DATE
),
cte_saldos_completos AS (
    SELECT
        u.unidade,
        u.cod_produto,
        u.data_base,
        b.nome_produto,
        b.categoria,
        b.classe,
        b.subclasse,
        b.saldo_dia AS ultimo_saldo_dia,
        b.custo_unitario
    FROM cte_ultima_movimentacao_mes u
    LEFT JOIN cte_base_filtrada b
        ON b.unidade      = u.unidade
        AND b.cod_produto  = u.cod_produto
        AND b.dt           = u.ultima_data
),
cte_movimentacoes_mes AS (
    SELECT
        unidade,
        cod_produto,
        mes AS data_base,
        SUM(CASE WHEN tipo_movimentacao = 'COMPRA'
            THEN CAST(REPLACE(custo_unitario, ',', '.') AS NUMERIC) *
                 CAST(REPLACE(qtd_movimentacao, ',', '.') AS NUMERIC) ELSE 0 END
        ) AS custo_compra_mes,
        SUM(CASE WHEN tipo_movimentacao = 'VENDA'
            THEN CAST(REPLACE(custo_unitario, ',', '.') AS NUMERIC) *
                 ABS(CAST(REPLACE(qtd_movimentacao, ',', '.') AS NUMERIC)) ELSE 0 END
        ) AS custo_venda_mes,
        SUM(CASE WHEN tipo_movimentacao = 'COMPRA'
            THEN CAST(REPLACE(qtd_movimentacao, ',', '.') AS NUMERIC) ELSE 0 END
        ) AS qtde_compra_mes,
        SUM(CASE WHEN tipo_movimentacao = 'VENDA'
            THEN ABS(CAST(REPLACE(qtd_movimentacao, ',', '.') AS NUMERIC)) ELSE 0 END
        ) AS qtde_venda_mes,
		AVG(CASE WHEN tipo_movimentacao = 'VENDA'
            THEN CAST(REPLACE(precovenda, ',', '.') AS NUMERIC) END
        ) AS preco_venda_unitario_mes,
        SUM(CASE WHEN tipo_movimentacao = 'VENDA'
            THEN CAST(REPLACE(precovenda, ',', '.') AS NUMERIC) *
                 ABS(CAST(REPLACE(qtd_movimentacao, ',', '.') AS NUMERIC)) ELSE 0 END
        ) AS preco_venda_total_mes
    FROM cte_base_filtrada
    GROUP BY unidade, cod_produto, mes
),
cte_preenchimento_ausencias AS (
    SELECT
        s.unidade,
        s.cod_produto,
        s.data_base,
        s.nome_produto,
        s.categoria,
        s.classe,
        s.subclasse,
        COALESCE(
            s.ultimo_saldo_dia,
            LAG(s.ultimo_saldo_dia) OVER (PARTITION BY s.unidade, s.cod_produto ORDER BY s.data_base)
        ) AS saldo_ajustado,
        COALESCE(
            s.custo_unitario,
            LAG(s.custo_unitario) OVER (PARTITION BY s.unidade, s.cod_produto ORDER BY s.data_base)
        ) AS custo_unitario_ajustado,
        COALESCE(
            m.custo_compra_mes,
            LAG(m.custo_compra_mes) OVER (PARTITION BY s.unidade, s.cod_produto ORDER BY s.data_base)
        ) AS custo_compra_ajustado,
        COALESCE(
            m.custo_venda_mes,
            LAG(m.custo_venda_mes) OVER (PARTITION BY s.unidade, s.cod_produto ORDER BY s.data_base)
        ) AS custo_venda_ajustado,
        COALESCE(
            m.qtde_compra_mes,
            LAG(m.qtde_compra_mes) OVER (PARTITION BY s.unidade, s.cod_produto ORDER BY s.data_base)
        ) AS qtde_compra_ajustado,
        COALESCE(
            m.qtde_venda_mes,
            LAG(m.qtde_venda_mes) OVER (PARTITION BY s.unidade, s.cod_produto ORDER BY s.data_base)
        ) AS qtde_venda_ajustado,
        COALESCE(
            m.preco_venda_unitario_mes,
            LAG(m.preco_venda_unitario_mes) OVER (PARTITION BY s.unidade, s.cod_produto ORDER BY s.data_base)
        ) AS preco_venda_unitario_ajustado,
        COALESCE(
            m.preco_venda_total_mes,
            LAG(m.preco_venda_total_mes) OVER (PARTITION BY s.unidade, s.cod_produto ORDER BY s.data_base)
        ) AS preco_venda_total_ajustado
    FROM cte_saldos_completos s
    LEFT JOIN cte_movimentacoes_mes m
        ON m.unidade      = s.unidade
        AND m.cod_produto  = s.cod_produto
        AND m.data_base    = s.data_base
)
SELECT
    unidade,
    cod_produto,
    nome_produto,
    categoria,
    classe,
    subclasse,
    data_base + INTERVAL '1 month'  AS data_referencia,
    saldo_ajustado                   AS saldo_dia,
        ROUND(
        CAST(REPLACE(saldo_ajustado,          ',', '.') AS NUMERIC) *
        CAST(REPLACE(custo_unitario_ajustado, ',', '.') AS NUMERIC), 2
    )                                AS custo_total_estoque,
    custo_unitario_ajustado          AS custo_unitario,
    ROUND(qtde_compra_ajustado,  2)  AS qtde_compra_mes,
    ROUND(custo_compra_ajustado, 2)  AS custo_compra_mes,
    ROUND(qtde_venda_ajustado,   2)  AS qtde_venda_mes,
    ROUND(custo_venda_ajustado,  2)  AS custo_venda_mes,
    ROUND(preco_venda_unitario_ajustado, 2) AS preco_venda_unitario,
    ROUND(preco_venda_total_ajustado,    2) AS preco_venda_total
FROM cte_preenchimento_ausencias
ORDER BY
    cod_produto,
    data_base;