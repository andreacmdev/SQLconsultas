-- BI Contas a Receber

-- documentos devolvidos
SELECT
    dd.tipo_unidade,
    dd.unidade,
    dd.tipo,
    dd.codcliente,
    dd.cliente,
    dd.titulo,
    TO_DATE(dd.emissaotitulo, 'YYYY-MM-DD') AS emissaotitulo,
    dd.valortitulo,
    dd.observacoes
FROM
    documentos_devolvidos dd
WHERE
    dd.tipo_unidade != 'Bodinho'
    AND TO_DATE(dd.emissaotitulo, 'YYYY-MM-DD') BETWEEN DATE '2023-12-01' AND CURRENT_DATE
ORDER BY
    dd.unidade;


 

 -------------------------------------------------------------------------------------------------

 --entregue_pendente   
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
     WHERE p.unidade = pd.unidade
       AND p.cod_pedido = pd.cod_pedido
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