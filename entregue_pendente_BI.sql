WITH pedidos_distintos AS (
    SELECT 
        eg.cod_pedido,
        eg.unidade,
        eg.origem,
        eg.cod_romaneio,
        eg.nome_cliente,
        eg.cod_cliente,
        MIN(eg.data_hora_entregue) AS data_hora_entregue
    FROM 
        entregas_geral eg
    WHERE 
        eg.data_hora_entregue >= CURRENT_DATE - INTERVAL '6 MONTHS'
    GROUP BY 
        eg.cod_pedido, 
        eg.unidade, 
        eg.origem,
        eg.cod_romaneio,
        eg.nome_cliente, 
        eg.cod_cliente
),
entregas_totais AS (
    SELECT 
        ec.cod_pedido,
        ec.unidade,  
        SUM(ec.valor_entregue) AS valor_entregue_total 
    FROM 
        entregas_completa ec
    GROUP BY 
        ec.cod_pedido, 
        ec.unidade  
)
SELECT 
    pd.unidade,
    pd.nome_cliente,
    pd.cod_cliente,
    pd.cod_pedido,
    STRING_AGG(DISTINCT pd.cod_romaneio, ', ') AS cod_romaneios,
    -- Ajuste no cálculo do total_pendente
    CASE 
        WHEN COALESCE(MAX(spp.totalpendente), 0) > COALESCE(ROUND(et.valor_entregue_total, 2), 0) 
        THEN COALESCE(ROUND(et.valor_entregue_total, 2), 0) 
        ELSE COALESCE(MAX(spp.totalpendente), 0) 
    END AS total_pendente,
    CURRENT_DATE - MIN(pd.data_hora_entregue)::date AS tempo_pendente, 
    COALESCE(msc.saldo, 0) AS saldo, 
    mc.ramo_atividade,
    mc.bloqueado,
    pd.origem,
    -- Removido o STRING_AGG da condição de pagamento
    COALESCE(
        (SELECT p.cond_pagamento
         FROM pedidos p
         JOIN status_pagamento_pedidos spp2  
           ON p.unidade = spp2.unidade
          AND p.cod_pedido = spp2.cod_pedido
         WHERE p.unidade = pd.unidade
           AND p.cod_cliente = pd.cod_cliente
           AND spp2.totalpendente != 0
         LIMIT 1),  
        'N/A'
    ) AS condicoes_pagamento,
    COALESCE(ROUND(et.valor_entregue_total, 2), 0) AS valor_entregue_total
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
LEFT JOIN 
    entregas_totais et
    ON pd.cod_pedido = et.cod_pedido  
    AND pd.unidade = et.unidade  
WHERE 
    spp.totalpendente != 0  
GROUP BY 
    pd.unidade,
    pd.origem,
    pd.cod_pedido,
    pd.cod_cliente,
    pd.nome_cliente,
    msc.saldo,
    mc.ramo_atividade,
    mc.bloqueado,
    et.valor_entregue_total;















    -- NEW CODE


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
        eg.data_hora_entregue >= CURRENT_DATE - INTERVAL '12 MONTHS'
    GROUP BY 
        eg.cod_pedido, 
        eg.unidade, 
        eg.origem,
        eg.nome_cliente, 
        eg.cod_cliente
),
entregas_totais AS (
    SELECT 
        ec.cod_pedido,
        ec.unidade,  
        SUM(ec.valor_entregue) AS valor_entregue_total 
    FROM 
        entregas_completa ec
    GROUP BY 
        ec.cod_pedido, 
        ec.unidade  
),
valor_total_pedidos AS (
    SELECT 
        cod_pedido,
        unidade,
        SUM(valor_unitario_total_com_desconto::numeric) AS valor_total_pedido
    FROM pedidos
    GROUP BY cod_pedido, unidade
),
condicoes_por_cliente AS (
    SELECT 
        cod_cliente,
        unidade,
        STRING_AGG(DISTINCT cond_pagamento, ' / ') AS condicoes_pagamento
    FROM pedidos p
    WHERE p.cond_pagamento IS NOT NULL
    GROUP BY cod_cliente, unidade
)
SELECT 
    pd.unidade,
    pd.cod_cliente,
    pd.nome_cliente,
    pd.origem,
    MAX(CURRENT_DATE - pd.data_hora_entregue::date) AS tempo_pendente,
    MAX(msc.saldo) AS saldo,
    mc.ramo_atividade,
    mc.bloqueado,
    COALESCE(cpc.condicoes_pagamento, 'N/A') AS condicoes_pagamento,
    SUM(CASE 
            WHEN COALESCE(spp.totalpendente, 0) > COALESCE(et.valor_entregue_total, 0) 
            THEN COALESCE(et.valor_entregue_total, 0) 
            ELSE COALESCE(spp.totalpendente, 0) 
        END) AS total_pendente,
    GREATEST(
        SUM(COALESCE(et.valor_entregue_total, 0)) - 
        (SUM(COALESCE(vtp.valor_total_pedido, 0)) - SUM(COALESCE(spp.totalpendente, 0))),
        0
    ) AS total_devido
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
LEFT JOIN 
    entregas_totais et
    ON pd.cod_pedido = et.cod_pedido  
    AND pd.unidade = et.unidade  
LEFT JOIN 
    valor_total_pedidos vtp
    ON vtp.cod_pedido = pd.cod_pedido
    AND vtp.unidade = pd.unidade
LEFT JOIN condicoes_por_cliente cpc
    ON pd.cod_cliente = cpc.cod_cliente
    AND pd.unidade = cpc.unidade
WHERE 
    spp.totalpendente != 0
    AND ramo_atividade != 'INTERCOMPANY'
GROUP BY 
    pd.cod_cliente,
    pd.nome_cliente,
    pd.unidade,
    pd.origem,
    mc.ramo_atividade,
    mc.bloqueado,
    cpc.condicoes_pagamento
HAVING 
    SUM(COALESCE(et.valor_entregue_total, 0)) - 
    (SUM(COALESCE(vtp.valor_total_pedido, 0)) - SUM(COALESCE(spp.totalpendente, 0))) > 0
    AND MAX(CURRENT_DATE - pd.data_hora_entregue::date) > 1;