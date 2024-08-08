--verifica cancelado
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
		p.status_pedido
from
	pedidos p  
left join
	coes c on p.coes = c.nome
where
	p.unidade = 'INBRAVIDROS'
	and p.pedido_cliente = '26676'