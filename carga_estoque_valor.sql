WITH cte_datas_base AS (
    SELECT 
        GENERATE_SERIES(
            DATE_TRUNC('month', CURRENT_DATE - INTERVAL '12 months'),
            DATE_TRUNC('month', CURRENT_DATE),
            INTERVAL '1 month'
        )::DATE AS data_base
),
cte_ultima_movimentacao_mes AS (
    select
    	ep.tipo_unidade ,
        ep.unidade,
        ep.cod_produto,
        d.data_base,
        MAX(ep.data_movimentacao::timestamp) AS ultima_data 
    FROM
        cte_datas_base d
    LEFT JOIN estoque_produtos ep
        ON ep.data_movimentacao::timestamp 
           <= (d.data_base + INTERVAL '1 month' - INTERVAL '1 day')
    GROUP BY
        ep.tipo_unidade, ep.unidade, ep.cod_produto, d.data_base
),
cte_saldos_completos AS (
    select
    	u.tipo_unidade ,
        u.unidade,
        u.cod_produto,
        u.data_base,
        ep.saldo_dia AS ultimo_saldo_dia,
        ep.custo_unitario
    FROM
        cte_ultima_movimentacao_mes u
    LEFT JOIN estoque_produtos ep
        ON ep.unidade = u.unidade
        AND ep.cod_produto = u.cod_produto
        AND ep.data_movimentacao::timestamp = u.ultima_data
),
cte_preenchimento_ausencias AS (
    select
    	tipo_unidade,
        unidade,
        cod_produto,
        data_base,
        COALESCE(
            ultimo_saldo_dia, 
            LAG(ultimo_saldo_dia) OVER (
                PARTITION BY unidade, cod_produto 
                ORDER BY data_base
            )
        ) AS saldo_ajustado,
        COALESCE(
            custo_unitario, 
            LAG(custo_unitario) OVER (
                PARTITION BY unidade, cod_produto 
                ORDER BY data_base
            )
        ) AS custo_unitario_ajustado
    FROM
        cte_saldos_completos
)
select
	tipo_unidade,
    unidade,
    data_base + INTERVAL '1 month' AS data_referencia,
    /* Quantidade total em estoque */
    SUM(
        CAST(REPLACE(saldo_ajustado, ',', '.') AS NUMERIC)
    ) AS qtd_estoque_total,
    /* Valor total do estoque */
    ROUND(
        SUM(
            CAST(REPLACE(saldo_ajustado, ',', '.') AS NUMERIC) *
            CAST(REPLACE(custo_unitario_ajustado, ',', '.') AS NUMERIC)
        ),
        2
    ) AS valor_estoque_total
FROM
    cte_preenchimento_ausencias
GROUP BY
    tipo_unidade,
    unidade,
    data_referencia
ORDER BY
    unidade,
    data_referencia;