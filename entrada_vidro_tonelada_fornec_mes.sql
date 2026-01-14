WITH dim_produto AS (
    SELECT 
        ep.tipo_unidade,
        ep.unidade,
        ep.cod_produto,
        MAX(ep.nome_produto)    AS nome_produto,
        MAX(ep.categoria)       AS categoria,
        MAX(ep.classe)          AS classe,
        MAX(ep.subclasse)       AS subclasse,
        MAX(ep.fator_conversao) AS fator_conversao
    FROM estoque_produtos ep
    WHERE 
        ep.categoria ILIKE '%chaparia%'
    GROUP BY 
        ep.tipo_unidade,
        ep.unidade,
        ep.cod_produto
),
base AS (
    SELECT 
        dp.tipo_unidade,
        pc.unidade,
        pc.fornecedor,
        pc.pedido,
        pc.data_pedido::timestamp AS data_pedido,
        pc.cod_produto      AS id_produto,
        -- 🔹 conversão segura de número BR
        CAST(
            NULLIF(
                REPLACE(
                    regexp_replace(pc.qtd_comprada, '\.', '', 'g'),
                    ',',
                    '.'
                ),
                ''
            )
        AS numeric) AS qtd_comprada,
        dp.cod_produto,
        dp.nome_produto,
        dp.categoria,
        dp.classe,
        dp.subclasse,
        dp.fator_conversao,
        -- 🔹 espessura somada
        (
            SELECT SUM(m[1]::numeric)
            FROM regexp_matches(dp.subclasse, '([0-9]+)', 'g') AS m
        ) AS espessura_mm
    FROM pedidos_compras pc
    LEFT JOIN estoque_completo_produtos ecp
        ON ecp.id_produto = pc.cod_produto
       AND ecp.unidade   = pc.unidade
    LEFT JOIN dim_produto dp
        ON dp.cod_produto = ecp.cod_produto
       AND dp.unidade    = ecp.unidade
    WHERE 
        pc.data_pedido::date >= '2025-01-01'
        AND dp.cod_produto IS NOT NULL and pc.status in ('4')
)
SELECT 
    tipo_unidade,
    unidade,
    fornecedor,
    pedido,
    data_pedido,
    cod_produto,
    id_produto,
    nome_produto,
    categoria,
    classe,
    subclasse,
    fator_conversao,
    espessura_mm,
    qtd_comprada,
    -- 🔹 cálculo direto por linha (sem somar nada)
    (2.5 * espessura_mm / 1000 * qtd_comprada) AS toneladas_vidro
FROM base
ORDER BY 
    tipo_unidade,
    unidade,
    fornecedor,
    data_pedido,
    pedido,
    nome_produto;