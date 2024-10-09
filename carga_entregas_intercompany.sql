WITH TotalPendentes AS (
    SELECT 
        unidade,
        cod_pedido,
        MAX(totalpendente) AS total_pendente -- Agregando o valor totalpendente por pedido
    FROM 
        status_pagamento_pedidos
    GROUP BY 
        unidade, 
        cod_pedido
)
SELECT 
	eg.tipo_unidade ,
    eg.unidade,
    eg.cod_pedido,
    eg.cod_romaneio, 
    eg.data_hora_entregue ,
    eg.carga ,
    eg.categoria_produto ,
    eg.nome_produto ,
    SUM(eg.valor_entregue) AS valor_entregue_total, -- Somando o valor entregue por pedido
    MAX(tp.total_pendente) AS total_pendente, -- Pegando o valor total pendente para o pedido
    eg.nome_cliente,
    eg.cod_cliente ,
    COUNT(DISTINCT eg.cod_pedido) AS qtd_entregas, -- Contagem de entregas por pedido
    CASE
        WHEN MAX(tp.total_pendente) > SUM(eg.valor_entregue) THEN SUM(eg.valor_entregue) -- Se totalpendente > valor_entregue, pendente_entregue será o valor_entregue
        ELSE MAX(tp.total_pendente) -- Caso contrário, será o valor total pendente
    END AS pendente_entregue -- Nova coluna com a lógica solicitada
FROM 
    entregas_geral eg
LEFT JOIN 
    TotalPendentes tp ON eg.cod_pedido = tp.cod_pedido AND eg.unidade = tp.unidade
LEFT JOIN 
    mapeamento_clientes mc ON eg.unidade = mc.unidade AND eg.cod_cliente = mc.codcliente
WHERE 
    eg.unidade = 'VITORIA DE SANTO ANTAO'
    AND eg.data_hora_entregue >= CURRENT_DATE - INTERVAL '30 DAYS'
    AND mc.ramo_atividade = 'INTERCOMPANY'
GROUP BY 
	eg.tipo_unidade ,
    eg.unidade,
    eg.cod_pedido,
    eg.cod_romaneio, 
    eg.data_hora_entregue ,
    eg.carga ,
    eg.categoria_produto ,
    eg.nome_produto ,
    eg.nome_cliente,
    eg.cod_cliente 
ORDER BY 
    eg.cod_pedido
LIMIT 20;