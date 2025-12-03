SELECT 
    ecp.tipo_unidade, 
    ecp.unidade, 
    ecp.categoria, 
    ecp.classe, 
    ecp.subclasse, 
    ecp.cod_produto, 
    ecp.nome_produto,
    ecp.estoque_qtd,
    ecp.custo_unt,
    -- Total vendido nos últimos 6 meses
    ROUND(
        COALESCE((
            SELECT SUM(REPLACE(p.qtd_produto, ',', '.')::numeric)
            FROM pedidos p
            WHERE 
                p.cod_produto = ecp.cod_produto
                AND p.unidade = ecp.unidade
                AND p.data_pedido >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '6 month')
        ), 0), 2
    ) AS total_vendido_semestre,
    -- Média mensal = total dividido por 6
    ROUND(
        COALESCE((
            SELECT SUM(REPLACE(p.qtd_produto, ',', '.')::numeric) / 6
            FROM pedidos p
            WHERE 
                p.cod_produto = ecp.cod_produto
                AND p.unidade = ecp.unidade
                AND p.data_pedido >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '6 month')
        ), 0), 2
    ) AS media_venda_mensal
FROM estoque_completo_produtos ecp
LEFT JOIN unidades u 
    ON ecp.unidade = u.unidade
WHERE 
    u.ativo = 'S';