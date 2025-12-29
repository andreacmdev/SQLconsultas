WITH fornecedor_produto AS (
    SELECT 
        pc.cod_produto,
        pc.unidade,
        MIN(pc.fornecedor) AS fornecedor
    FROM pedidos_compras pc
    GROUP BY 
        pc.cod_produto,
        pc.unidade
),
base AS (
    SELECT 
        ep.tipo_unidade,
        ep.unidade,
        ep.categoria,
        ep.nome_produto,
        ep.cod_produto,
        ep.classe,
        ep.subclasse,
        ep.fator_conversao,
        date_trunc('month', ep.data_movimentacao::timestamp)::date AS mes_movimentacao,
        NULLIF(REPLACE(ep.custo_unitario, ',', '.'), '')::numeric AS custo_unitario,
        NULLIF(REPLACE(ep.qtd_movimentacao, ',', '.'), '')::numeric AS qtd_movimentacao,
        (
            SELECT SUM(m[1]::numeric)
            FROM regexp_matches(ep.subclasse, '([0-9]+)', 'g') AS m
        ) AS espessura_mm,
        ecp.id_produto,
        fp.fornecedor
    FROM estoque_produtos ep
    LEFT JOIN estoque_completo_produtos ecp 
        ON ecp.cod_produto = ep.cod_produto
       AND ecp.unidade = ep.unidade
    LEFT JOIN fornecedor_produto fp
        ON fp.cod_produto = ecp.id_produto
       AND fp.unidade = ecp.unidade
    WHERE 
        ep.data_movimentacao::date >= '2025-01-01'
        AND ep.categoria ILIKE '%chaparia%'
        AND ep.tipo_movimentacao = 'COMPRA'
)
SELECT 
    tipo_unidade,
    unidade,
    categoria,
    nome_produto,
    cod_produto,
    classe,
    subclasse,
    id_produto,
    fornecedor,
    mes_movimentacao,
    MAX(espessura_mm) AS espessura_mm,
    MAX(fator_conversao) AS fator_conversao,
    MAX(custo_unitario) AS custo_unitario_max,
    SUM(qtd_movimentacao) AS qtd_total_movimentada,
    SUM(2.5 * espessura_mm / 1000 * qtd_movimentacao)
        AS toneladas_vidro
FROM base
GROUP BY 
    tipo_unidade,
    unidade,
    categoria,
    nome_produto,
    cod_produto,
    classe,
    subclasse,
    id_produto,
    fornecedor,
    mes_movimentacao
ORDER BY 
    tipo_unidade,
    unidade,
    mes_movimentacao,
    fornecedor,
    nome_produto;
