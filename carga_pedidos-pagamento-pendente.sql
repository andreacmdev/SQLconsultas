-- Consolidar pedidos pendentes emitidos nos últimos 12 meses e que não foram entregues
WITH pedidos_consolidados AS (
    SELECT 
        p.tipo_unidade,
        p.unidade,
        p.cod_cliente,
        p.nome_cliente,
        p.cod_pedido,
        p.cond_pagamento,
        p.data_pedido,
        p.status_pedido,
        p.tipo_pedido,
        p.coes,
        p.pedido_pronto,
        p.pedido_pago,
        ROUND(SUM(CAST(REPLACE(p.valor_unitario_total_com_desconto, ',', '.') AS NUMERIC))) AS valor_unitario_total_com_desconto
    FROM 
        pedidos p
    LEFT JOIN 
        status_pagamento_pedidos spp ON p.cod_pedido = spp.cod_pedido AND p.unidade = spp.unidade
    WHERE 
         spp.totalpendente != 0
        AND p.status_pedido = 'Aberto'
        AND p.tipo_pedido = 'Engenharia'
        AND DATE(p.data_pedido::timestamp) >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY 
        p.tipo_unidade,
        p.unidade,
        p.cod_cliente,
        p.nome_cliente,
        p.cod_pedido,
        p.cond_pagamento,
        p.data_pedido,
        p.status_pedido,
        p.tipo_pedido,
        p.coes,
        p.pedido_pronto,
        p.pedido_pago
)
SELECT 
    pc.tipo_unidade,
    pc.unidade,
    pc.cod_cliente,
    pc.cod_pedido,
    pc.nome_cliente,
    pc.cond_pagamento,
    pc.data_pedido,
    pc.status_pedido,
    pc.valor_unitario_total_com_desconto,
    pc.tipo_pedido,
    pc.coes,
    pc.pedido_pronto,
    pc.pedido_pago,
    spp.totalpago,
    spp.totalpendente,
    e.cod_romaneio
FROM 
    pedidos_consolidados pc
LEFT JOIN 
    status_pagamento_pedidos spp ON pc.cod_pedido = spp.cod_pedido AND pc.unidade = spp.unidade
LEFT JOIN
    entregas e ON pc.cod_pedido = e.cod_pedido 
    AND pc.tipo_unidade = e.tipo_unidade 
    AND pc.unidade = e.unidade
GROUP BY 
    pc.tipo_unidade,
    pc.unidade,
    pc.cod_cliente,
    pc.nome_cliente,
    pc.cod_pedido,
    pc.cond_pagamento,
    pc.data_pedido,
    pc.status_pedido,
    pc.valor_unitario_total_com_desconto,
    pc.tipo_pedido,
    pc.coes,
    pc.pedido_pronto,
    pc.pedido_pago,
    spp.totalpago,
    spp.totalpendente,
    e.cod_romaneio
ORDER BY 
    pc.unidade;
