-- Consolidar pedidos e unir com status_pagamento usando cod_pedido e unidade como referência
WITH pedidos_consolidados AS (
    SELECT 
        p.tipo_unidade,
        p.unidade,
        p.cod_cliente,
        p.cod_pedido,
        p.cond_pagamento,
        p.data_pedido,
        p.status_pedido,
        p.tipo_pedido,
        p.coes,
        p.pedido_pronto,
        p.pedido_pago,
        round(SUM(CAST(REPLACE(p.valor_unitario_total_com_desconto, ',', '.') AS NUMERIC))) AS valor_unitario_total_com_desconto
    FROM 
        pedidos p
    LEFT JOIN 
        status_pagamento_pedidos spp ON p.cod_pedido = spp.cod_pedido AND p.unidade = spp.unidade
    WHERE 
        p.tipo_unidade = 'Bodinho'
        AND spp.totalpendente != 0
        AND DATE(p.data_pedido::timestamp)  <= CURRENT_DATE - INTERVAL '15 days'
    GROUP BY 
        p.tipo_unidade,
        p.unidade,
        p.cod_cliente,
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