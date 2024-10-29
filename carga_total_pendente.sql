-- total_pendente por cliente
WITH pedidos_consolidados AS (
    SELECT 
        p.tipo_unidade,
        p.unidade,
        p.cod_cliente,
        p.nome_cliente,
        p.data_pedido,
        p.cod_pedido,
        p.coes,
        p.nome_produto,
        p.categoria_produto,
        eg.data_hora_entregue,
        eg.cod_romaneio,
        spp.totalpendente AS total_pendente,
        COUNT(*) OVER (PARTITION BY p.cod_pedido, p.unidade) AS count_pedido  -- Contar quantas vezes o pedido aparece
    FROM 
        pedidos p
    LEFT JOIN 
        status_pagamento_pedidos spp ON p.cod_pedido = spp.cod_pedido AND p.unidade = spp.unidade
    LEFT JOIN 
        entregas_geral eg ON p.cod_pedido = eg.cod_pedido AND p.unidade = eg.unidade
    WHERE 
        spp.totalpendente != 0
        AND (p.nome_cliente ILIKE '%NOBRE%' OR p.nome_cliente ILIKE '%NÓBRE%')
)
SELECT 
    pc.tipo_unidade,
    pc.unidade,
    pc.cod_cliente,
    pc.nome_cliente,
    pc.categoria_produto,
    pc.nome_produto,
    pc.data_hora_entregue,
    pc.cod_romaneio,
    pc.cod_pedido,
    ROUND(pc.total_pendente / pc.count_pedido, 2) AS total_pendente  -- Arredondar o total pendente para 2 casas decimais
FROM 
    pedidos_consolidados pc
ORDER BY 
    pc.tipo_unidade, pc.unidade;
