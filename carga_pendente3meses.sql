WITH pedidos_distintos AS (
    SELECT 
        eg.cod_pedido,
        eg.unidade,
        eg.nome_cliente,
        eg.cod_cliente,
        MIN(eg.data_hora_entregue) AS data_hora_entregue -- Mantém a data da entrega mais antiga
    FROM 
        entregas_geral eg
    WHERE 
        eg.data_hora_entregue >= CURRENT_DATE - INTERVAL '3 MONTHS'
        AND eg.unidade = 'PERFILUX' -- Filtra pela unidade desejada
    GROUP BY 
        eg.cod_pedido, 
        eg.unidade, 
        eg.nome_cliente, 
        eg.cod_cliente
)bababaa
SELECT 
    pd.unidade,
    pd.nome_cliente,
    pd.cod_cliente,
    COALESCE(SUM(spp.totalpendente), 0) AS total_pendente, -- Soma os totais pendentes
    CURRENT_DATE - MIN(pd.data_hora_entregue)::date AS tempo_pendente, -- Calcula o tempo pendente
    COALESCE(msc.saldo, 0) AS saldo, -- Inclui o saldo do cliente
    mc.ramo_atividade -- Inclui o ramo de atividade do cliente
FROM 
    pedidos_distintos pd
LEFT JOIN 
    status_pagamento_pedidos spp
    ON pd.cod_pedido = spp.cod_pedido
    AND pd.unidade = spp.unidade -- Garante a relação correta
LEFT JOIN 
    main_saldo_cliente msc
    ON pd.unidade = msc.unidade
    AND pd.nome_cliente = msc.nome -- Adiciona o saldo do cliente
LEFT JOIN 
    mapeamento_clientes mc
    on pd.unidade = mc.unidade and pd.cod_cliente = mc.codcliente -- Adiciona o ramo de atividade
WHERE 
    spp.totalpendente != 0 -- Apenas pedidos com pendências de pagamenento
GROUP BY 
    pd.unidade,
    pd.cod_cliente,
    pd.nome_cliente,
    msc.saldo,
    mc.ramo_atividade
