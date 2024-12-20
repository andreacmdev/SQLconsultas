-- agreste vidros estoque anual
WITH cte_datas_base AS (
    -- Gera uma lista com o primeiro dia de cada mês de 2024
    SELECT 
        GENERATE_SERIES(
            DATE '2024-01-01', 
            DATE '2024-12-01', 
            INTERVAL '1 month'
        )::DATE AS data_base
),
cte_ultima_movimentacao_mes AS (
    -- Encontra a última movimentação de cada produto em cada mês
    SELECT
        ep.unidade,
        ep.cod_produto,
        d.data_base,
        MAX(ep.data_movimentacao::timestamp) AS ultima_data -- Conversão explícita
    FROM
        cte_datas_base d
    LEFT JOIN estoque_produtos ep
        ON ep.data_movimentacao::timestamp <= (d.data_base + INTERVAL '1 month' - INTERVAL '1 day') -- Conversão explícita
        AND ep.unidade = 'Agreste Vidros'
    GROUP BY
        ep.unidade, ep.cod_produto, d.data_base
),
cte_saldos_completos AS (
    -- Pega o saldo correspondente à última movimentação do mês
    SELECT
        u.unidade,
        u.cod_produto,
        u.data_base,
        ep.nome_produto,
        ep.categoria,
        ep.saldo_dia AS ultimo_saldo_dia,
        u.ultima_data
    FROM
        cte_ultima_movimentacao_mes u
    LEFT JOIN estoque_produtos ep
        ON ep.unidade = u.unidade
        AND ep.cod_produto = u.cod_produto
        AND ep.data_movimentacao::timestamp = u.ultima_data -- Conversão explícita
),
cte_preenchimento_ausencias AS (
    -- Preenche os meses sem movimentação com o saldo do mês anterior
    SELECT
        unidade,
        cod_produto,
        data_base,
        nome_produto,
        categoria,
        ultimo_saldo_dia,
        ultima_data,
        COALESCE(
            ultimo_saldo_dia, 
            LAG(ultimo_saldo_dia) OVER (PARTITION BY unidade, cod_produto ORDER BY data_base)
        ) AS saldo_ajustado
    FROM
        cte_saldos_completos
)
-- Resultado final
SELECT
    unidade,
    cod_produto,
    nome_produto,
    categoria,
    data_base AS data_referencia,
    saldo_ajustado AS saldo_dia
FROM
    cte_preenchimento_ausencias
WHERE
    unidade = 'Agreste Vidros'
ORDER BY
    cod_produto,
    data_referencia;
    