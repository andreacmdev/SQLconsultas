WITH pedidos_distintos AS (
    SELECT 
        eg.cod_pedido,
        eg.unidade,
        eg.origem,
        eg.nome_cliente,
        eg.cod_cliente,
        MIN(eg.data_hora_entregue) AS data_hora_entregue
    FROM 
        entregas_geral eg
    WHERE 
        eg.data_hora_entregue >= CURRENT_DATE - INTERVAL '3 MONTHS'
    GROUP BY 
        eg.cod_pedido, 
        eg.unidade, 
        eg.origem,
        eg.nome_cliente, 
        eg.cod_cliente
)
SELECT 
    pd.unidade,
    pd.nome_cliente,
    pd.cod_cliente,
    COALESCE(SUM(spp.totalpendente), 0) AS total_pendente,
    CURRENT_DATE - MIN(pd.data_hora_entregue)::date AS tempo_pendente, 
    COALESCE(msc.saldo, 0) AS saldo, 
    mc.ramo_atividade,
    mc.bloqueado,
    pd.origem,
    COALESCE(
        (SELECT STRING_AGG(DISTINCT p.cond_pagamento, ', ')
         FROM pedidos p
         JOIN status_pagamento_pedidos spp2  -- Filtro para pedidos pendentes
           ON p.unidade = spp2.unidade
          AND p.cod_pedido = spp2.cod_pedido
         WHERE p.unidade = pd.unidade
           AND p.cod_cliente = pd.cod_cliente
           AND spp2.totalpendente != 0),  -- Apenas pedidos pendentes
        'N/A'
    ) AS condicoes_pagamento
FROM 
    pedidos_distintos pd
LEFT JOIN 
    status_pagamento_pedidos spp
    ON pd.cod_pedido = spp.cod_pedido
    AND pd.unidade = spp.unidade
LEFT JOIN 
    main_saldo_cliente msc
    ON pd.unidade = msc.unidade
    AND pd.nome_cliente = msc.nome
LEFT JOIN 
    mapeamento_clientes mc
    ON pd.unidade = mc.unidade 
    AND pd.cod_cliente = mc.codcliente
WHERE 
    spp.totalpendente != 0  -- Filtro para pedidos pendentes
    and mc.ramo_atividade != 'INTERCOMPANY'
GROUP BY 
    pd.unidade,
    pd.origem,
    pd.cod_cliente,
    pd.nome_cliente,
    msc.saldo,
    mc.ramo_atividade,
    mc.bloqueado;