-- Agreste Vidros Estoque Anual e Contínuo
WITH cte_datas_base AS (
    -- Gera uma lista de datas do primeiro dia de cada mês, começando de janeiro de 2024 até o mês atual
    SELECT 
        GENERATE_SERIES(
            DATE '2024-01-01', -- Data inicial fixa ou personalizável
            DATE_TRUNC('month', CURRENT_DATE), -- Gera até o mês atual
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
        AND ep.unidade = 'CD VIDROS'
    GROUP BY
        ep.unidade, ep.cod_produto, d.data_base
),
cte_saldos_completos AS (
    -- Pega o saldo correspondente à última movimentação do mês e adiciona custo_unitario
    SELECT
        u.unidade,
        u.cod_produto,
        u.data_base,
        ep.nome_produto,
        ep.categoria,
        ep.saldo_dia AS ultimo_saldo_dia,
        ep.custo_unitario, -- Inclui o custo unitário
        u.ultima_data
    FROM
        cte_ultima_movimentacao_mes u
    LEFT JOIN estoque_produtos ep
        ON ep.unidade = u.unidade
        AND ep.cod_produto = u.cod_produto
        AND ep.data_movimentacao::timestamp = u.ultima_data -- Conversão explícita
),
cte_preenchimento_ausencias AS (
    -- Preenche os meses sem movimentação com o saldo do mês anterior, mas evita preenchimento além da data atual
    SELECT
        unidade,
        cod_produto,
        data_base,
        nome_produto,
        categoria,
        ultimo_saldo_dia,
        custo_unitario, -- Mantém o custo unitário
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
    saldo_ajustado AS saldo_dia,
    ROUND(
        CAST(REPLACE(saldo_ajustado, ',', '.') AS NUMERIC) * 
        CAST(REPLACE(custo_unitario, ',', '.') AS NUMERIC),
        2
    ) AS custo_total
FROM
    cte_preenchimento_ausencias
WHERE
    unidade = 'CD VIDROS'
    AND data_base <= CURRENT_DATE -- Limita os resultados até a data atual
ORDER BY
    cod_produto,
    data_referencia;