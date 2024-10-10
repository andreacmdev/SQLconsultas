-- pedidos finalizados pendentes
SELECT 
	p.unidade ,
	p.coes ,
    p.cod_cliente,
    P.nome_cliente ,
    p.cod_pedido,
    p.status_pedido ,
    p.pedido_pago , 
    p.categoria_produto ,
    MAX(p.classe_produto) AS classe_produto ,
    MAX(p.sub_classe_produto) AS sub_classe_produto ,
    p.previsao_entrega ,
    DATE(p.data_pedido ::timestamp) as data_pedido ,
    p.valor_unitario_com_desconto
FROM 
    pedidos p
where
	--p.unidade = ''
	DATE(p.data_pedido ::timestamp) between '2024-01-01' AND '2024-06-30'
	and p.status_pedido = 'Finalizado'
	and p.unidade = 'CABO VIDROS'
	and (p.pedido_pago != 'S' or p.pedido_pago is NULL)
group by 
	p.unidade ,
	p.coes ,
	p.cod_cliente , 
	P.nome_cliente ,
	p.cod_pedido , 
	p.status_pedido , 
	p.pedido_pago , 
	p.categoria_produto , 
	classe_produto , 
	sub_classe_produto , 
	p.previsao_entrega , 
	p.data_pedido ,
	p.valor_unitario_com_desconto 