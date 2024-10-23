-- auditoria estoque
WITH movimentacoes_anteriores AS (
    SELECT
        tipo_unidade,
        unidade,
        cod_produto,
        SUM(CASE 
            WHEN tipo_movimentacao = 'COMPRA' 
            THEN CAST(REPLACE(qtd_movimentacao, ',', '.') AS NUMERIC) 
            ELSE 0 
        END) AS total_entrada
    FROM
        estoque_produtos
    WHERE
        TO_DATE(data_movimentacao, 'YYYY-MM-DD') = CURRENT_DATE - INTERVAL '1 day'
    GROUP BY
        tipo_unidade,
        unidade,
        cod_produto
),
media_vendas AS (
    SELECT
        tipo_unidade,
        unidade,
        cod_produto,
        SUM(CASE 
            WHEN tipo_movimentacao = 'VENDA' 
            THEN ABS(CAST(REPLACE(qtd_movimentacao, ',', '.') AS NUMERIC)) 
            ELSE 0 
        END) AS total_venda
    FROM
        estoque_produtos
    WHERE
        TO_DATE(data_movimentacao, 'YYYY-MM-DD') >= CURRENT_DATE - INTERVAL '6 month'
    GROUP BY
        tipo_unidade,
        unidade,
        cod_produto
)
SELECT
    ep.tipo_unidade,
    ep.unidade,
    ep.cod_produto,
    ep.nome_produto,
    CAST(REPLACE(ep.estoque_atual, ',', '.') AS NUMERIC) AS estoque_atual,
    ma.total_entrada,
    (CAST(REPLACE(ep.estoque_atual, ',', '.') AS NUMERIC) - ma.total_entrada) AS estoque_antes,
    COALESCE(mv.total_venda, 0) AS total_venda,
    CASE 
        WHEN mv.total_venda > 0 THEN 
            mv.total_venda / 6
        ELSE 
            0 
    END AS media_vendas,
    CASE 
        WHEN mv.total_venda > 0 THEN 
            CAST(REPLACE(ep.estoque_atual, ',', '.') AS NUMERIC) / (mv.total_venda / 6)
        ELSE 
            NULL 
    END AS previsao_estoque
FROM
    estoque_produtos ep
JOIN
    movimentacoes_anteriores ma ON ep.cod_produto = ma.cod_produto
    AND ep.tipo_unidade = ma.tipo_unidade
    AND ep.unidade = ma.unidade
LEFT JOIN
    media_vendas mv ON ep.cod_produto = mv.cod_produto
    AND ep.tipo_unidade = mv.tipo_unidade
    AND ep.unidade = mv.unidade
WHERE
    ma.total_entrada > 0
GROUP BY
    ep.tipo_unidade,
    ep.unidade,
    ep.cod_produto,
    ep.nome_produto,
    ep.estoque_atual,
    ma.total_entrada,
    mv.total_venda;