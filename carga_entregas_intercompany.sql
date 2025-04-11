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
select
    eg.tipo_unidade ,
    eg.unidade,
    eg.cod_pedido,
    eg.pedido_cliente , 
    eg.cod_romaneio ,
    eg.data_hora_entregue, 
    eg.carga,
    eg.categoria_produto,
    eg.nome_produto,
    eg.nome_cliente ,
    eg.cod_cliente,
    eg.valor_entregue as valor,
    eg.acrescimo ,
    sum(eg.qtd_entregue) as qtde_entregue,
    eg.metragem_entregue ,
    SUM(eg.valor_entregue) as valor_entregue_pedido,
     CASE
        WHEN MAX(tp.total_pendente) > SUM(eg.valor_entregue) THEN SUM(eg.valor_entregue)
        ELSE MAX(tp.total_pendente)
    END AS pendente_entregue
    from
        entregas_geral eg
    LEFT JOIN 
        TotalPendentes tp ON eg.cod_pedido = tp.cod_pedido AND eg.unidade = tp.unidade
    WHERE 
        -- eg.unidade = 'Oazem'
        eg.data_hora_entregue BETWEEN '2025-03-01' AND CURRENT_DATE
        -- and eg.nome_cliente = 'GM Maceio'
group by 
    eg.tipo_unidade ,
    eg.unidade ,
    eg.cod_pedido ,
    eg.pedido_cliente ,
    eg.cod_romaneio ,
    eg.data_hora_entregue , 
    eg.carga,
    eg.categoria_produto,
    eg.nome_produto,
    eg.nome_cliente ,
    eg.cod_cliente,
    eg.qtd_entregue,
    eg.metragem_entregue ,
    eg.valor_entregue ,
    eg.acrescimo ,
    eg.carga