-- consolidar os pedidos com pagamento pendente
WITH pedidos_consolidados AS (
    SELECT 
        p.tipo_unidade,
        p.unidade,
        p.cod_cliente,
        p.cod_pedido
    FROM 
        pedidos p
    LEFT JOIN 
        status_pagamento_pedidos spp ON p.cod_pedido = spp.cod_pedido AND p.unidade = spp.unidade
    WHERE 
        spp.totalpendente != 0
        AND p.data_pedido <= CURRENT_DATE - INTERVAL '15 days'
    GROUP BY 
        p.tipo_unidade,
        p.unidade,
        p.cod_cliente,
        p.cod_pedido
)
-- Consulta final para unir os clientes desbloqueados com os pedidos pendentes
SELECT 
    dc.tipo_unidade,
    dc.unidade,
    dc.cod_cliente,
    dc.nome_cliente,
    dc.usuario ,
    DATE(dc.data_alteracao::timestamp) AS data_alteracao,
    SUM(spp.totalpendente) AS valor_pendente
FROM 
    desbloqueio_clientes dc
LEFT JOIN 
    pedidos_consolidados pc ON dc.cod_cliente = pc.cod_cliente 
    AND dc.tipo_unidade = pc.tipo_unidade 
    AND dc.unidade = pc.unidade
LEFT JOIN 
    status_pagamento_pedidos spp ON pc.cod_pedido = spp.cod_pedido 
    AND pc.unidade = spp.unidade
WHERE 
    DATE(dc.data_alteracao::timestamp) BETWEEN '2024-08-15' AND '2024-08-15'
    AND dc.tipo_unidade != 'Tempera'
GROUP BY
    dc.tipo_unidade,
    dc.unidade,
    dc.cod_cliente,
    dc.nome_cliente,
    dc.usuario ,
    dc.data_alteracao
ORDER BY 
    dc.tipo_unidade, dc.unidade;