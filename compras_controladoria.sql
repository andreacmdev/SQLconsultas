-- compras controladoria

SELECT
    compras.NU_PCO AS nu_pedido,
    compras.NU_FOR AS fornecedor,
    compras.DT_PCO AS data_pedido,
    compras.ID_STATUS,
    compras.USU_INS,
    compras.VLR_TOT_PCO,
    compras.NU_USU_SOLICITANTE,
    compra_produto.NU_PRO,
    compra_produto.DS_PRO_FORNEC,
    prod.DS_COD_INTERNO,
    prod.DS_PRO,
    cat.DS_CAT,
    compra_produto.QTDE_PCO AS qtde_comprada,
    prod.NU_ESTOQAT AS estoque_atual,
    -- Vendas (últimos 180 dias)
    COALESCE(v.total_vendido, 0) AS total_vendido_180d,
    COALESCE(v.dias_com_venda, 0) AS dias_com_venda_180d,
    v.dias_periodo_180d,
    ROUND(COALESCE(v.media_dia_180d, 0), 4) AS media_vendas_dia_180d,
    -- Cobertura de estoque (em dias)
    CASE 
        WHEN COALESCE(v.media_dia_180d, 0) > 0 
            THEN ROUND(prod.NU_ESTOQAT / v.media_dia_180d, 1)
        ELSE NULL
    END                                         AS dias_cobertura,
    -- Regra de alerta
    CASE 
        WHEN COALESCE(v.media_dia_180d, 0) = 0 AND prod.NU_ESTOQAT > 0
            THEN 'ALERTA: sem venda em 180d'
        WHEN COALESCE(v.media_dia_180d, 0) > 0 
             AND (prod.NU_ESTOQAT / v.media_dia_180d) > 30
            THEN 'ALERTA: cobertura > 30 dias'
        ELSE 'OK'
    END                                         AS status_alerta
FROM mgpco01010 compras
LEFT JOIN mgpco01011 compra_produto 
       ON compras.NU_PCO = compra_produto.NU_PCO
LEFT JOIN mgpro01010 prod
       ON compra_produto.NU_PRO = prod.NU_PRO
LEFT JOIN mgcat01010 cat
       ON prod.NU_CAT = cat.NU_CAT
-- Subquery de vendas (últimos 180 dias)
LEFT JOIN (
    SELECT 
        ped.NU_PRO,
        SUM(ped.QT_PRO) AS total_vendido,  -- ajuste o nome caso seja QT_PRODUTO
        COUNT(DISTINCT DATE(pv.DT_PVE)) AS dias_com_venda,
        TIMESTAMPDIFF(DAY, CURDATE() - INTERVAL 180 DAY, CURDATE()) AS dias_periodo_180d,
        SUM(ped.QT_PRO) / NULLIF(
            TIMESTAMPDIFF(DAY, CURDATE() - INTERVAL 180 DAY, CURDATE()), 0
        ) AS media_dia_180d
    FROM mgpve01011 ped
    JOIN mgpve01010 pv ON ped.NU_PVE = pv.NU_PVE
    WHERE pv.DT_PVE >= CURDATE() - INTERVAL 180 DAY
    GROUP BY ped.NU_PRO
) v ON v.NU_PRO = compra_produto.NU_PRO
WHERE compras.ID_STATUS = '1'
  AND compras.DT_PCO = CURDATE();