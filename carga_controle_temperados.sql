-- CONTROLE TEMPERADOS
SELECT 
	vpcp.unidade ,
    vpcp.cod_cliente,
    vpcp.nome_cliente ,
    vpcp.cod_pedido,
    vpcp.status_pedido ,
    vpcp.pedido_pago2 ,
    vpcp.categoria_produto ,
    MAX(vpcp.classe_produto) AS classe_produto ,
    MAX(vpcp.sub_classe_produto) AS sub_classe_produto ,
    DATE(vpcp.data_pedido ::timestamp) as data_pedido ,
    vpcp.valor_unitario_com_desconto
FROM 
	view_pedidos_com_pagamento vpcp 
where
	--p.unidade = ''
	DATE(vpcp.data_pedido ::timestamp) between '2024-01-01' AND '2024-05-31'
	and vpcp.categoria_produto = 'TEMPERADO'
	and vpcp.status_pedido = 'Finalizado'
	and pedido_pago2 = '1'
	and vpcp.unidade = 'INBRAVIDROS'
group by 
	vpcp.unidade ,
    vpcp.cod_cliente,
    vpcp.nome_cliente ,
    vpcp.cod_pedido,
    vpcp.status_pedido ,
    vpcp.pedido_pago2 ,
    vpcp.categoria_produto ,
	classe_produto ,
  	sub_classe_produto ,
   	data_pedido ,
    vpcp.valor_unitario_com_desconto