--venda de sucata
select
		p.tipo_unidade ,
		p.unidade,
		p.cod_pedido,
		P.pedido_cliente ,
		p.nome_cliente,
		p.cod_cliente ,
		p.cond_pagamento,
		to_char(data_pedido, 'DD/MM/YYYY') AS data_formatada,
		REPLACE(CAST(REPLACE(p.valor_unitario_total_com_desconto , ',', '.') AS NUMERIC)::TEXT, '.', ',') AS valor_unitario_total_com_desconto,
		p.valor_total_pedido,
		p.coes,
		p.vendedor ,
		P.pedido_pago ,
		p.status_pedido,
		p.categoria_produto 
from
	pedidos p  
left join
	coes c on p.coes = c.nome
where 
	data_pedido::date between '2024-01-01' and '2024-07-31'
	and p.categoria_produto in (
	'BOX AVARIA',
	'BOX COM AVARIA',
	'BOX PORTA AVARIA',
	'SUCATA',
	'SUCATA VIDRO'
	)