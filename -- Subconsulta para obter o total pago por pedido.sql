-- Subconsulta para obter o total pago por pedido
WITH total_pago_por_pedido AS (
    SELECT
        cod_pedido,
        unidade,
        MAX(totalpago) AS totalpago  -- Garantir que totalpago é retornado corretamente para cada pedido
    FROM
        status_pagamento_pedidos
    GROUP BY
        cod_pedido,
        unidade
)
-- Consulta principal
SELECT 
    p.id,
    p.coes,
    p.id_item,
    p.vendedor,
    p.cod_pedido,
    p.cod_cliente,
    p.cod_produto,
    DATE(p.data_pedido::timestamp) AS data_pedido,
    p.pedido_pago,
    p.pedido_cliente,
    p.qtd_produto,
    p.tipo_pedido,
    p.endereco_gps,
    p.last_updated,
    p.nome_cliente,
    p.nome_produto,
    p.rota_entrega,
    p.tipo_produto,
    p.tipo_unidade,
    p.unidade,
    p.medida_altura,
    p.metragem_real,
    p.pedido_pronto,
    p.status_pedido,
    MAX(p.classe_produto) AS classe_produto,
    p.cond_pagamento,
    p.medida_largura,
    p.valor_desconto,
    p.valor_acrescimo,
    p.data_hora_pedido,
    p.metragem_cobrada,
    p.previsao_entrega,
    p.categoria_produto,
    MAX(p.sub_classe_produto) AS sub_classe_produto,
    p.valor_final_pedido,
    p.valor_total_pedido,
    p.percentual_desconto,
    p.percentual_acrescimo,
    p.valor_unitario_total,
    p.valor_unitario_produto,
    p.custo_unitario_total_produto,
    p.valor_unitario_com_desconto,
    p.custo_unitario_produto,
    p.valor_unitario_total_com_desconto,
    tp.totalpago,  -- Total pago sem repetição
    spp.totalpendente  -- Manter o valor correto de totalpendente
FROM 
    pedidos p
LEFT JOIN 
    total_pago_por_pedido tp ON p.cod_pedido = tp.cod_pedido AND p.unidade = tp.unidade
LEFT JOIN
    status_pagamento_pedidos spp ON p.cod_pedido = spp.cod_pedido AND p.unidade = spp.unidade
WHERE 
    DATE(p.data_pedido::timestamp) BETWEEN '2023-01-01' AND '2024-08-26'
    AND p.nome_cliente LIKE '%TROPICAL%'
GROUP BY
    p.id,
    p.coes,
    p.id_item,
    p.vendedor,
    p.cod_pedido,
    p.cod_cliente,
    p.cod_produto,
    DATE(p.data_pedido::timestamp),
    p.pedido_pago,
    p.pedido_cliente,
    p.qtd_produto,
    p.tipo_pedido,
    p.endereco_gps,
    p.last_updated,
    p.nome_cliente,
    p.nome_produto,
    p.rota_entrega,
    p.tipo_produto,
    p.tipo_unidade,
    p.unidade,
    p.medida_altura,
    p.metragem_real,
    p.pedido_pronto,
    p.status_pedido,
    p.cond_pagamento,
    p.medida_largura,
    p.valor_desconto,
    p.valor_acrescimo,
    p.data_hora_pedido,
    p.metragem_cobrada,
    p.previsao_entrega,
    p.categoria_produto,
    p.valor_final_pedido,
    p.valor_total_pedido,
    p.percentual_desconto,
    p.percentual_acrescimo,
    p.valor_unitario_total,
    p.valor_unitario_produto,
    p.custo_unitario_total_produto,
    p.valor_unitario_com_desconto,
    p.custo_unitario_produto,
    p.valor_unitario_total_com_desconto,
    tp.totalpago,  -- Total pago sem repetição
    spp.totalpendente;  -- Total pendente