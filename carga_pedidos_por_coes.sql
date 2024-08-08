-- Pedidos por Coes rep
	select
		p.tipo_unidade ,
		p.unidade,
		p.cod_pedido,
		p.nome_cliente,
		p.cod_cliente ,
		p.cond_pagamento,
		to_char(data_pedido, 'DD/MM/YYYY') AS data_formatada,
		REPLACE(CAST(REPLACE(p.valor_unitario_total_com_desconto , ',', '.') AS NUMERIC)::TEXT, '.', ',') AS valor_unitario_total_com_desconto,
		p.valor_total_pedido,
		p.coes,
		p.vendedor ,
		P.pedido_pago 
from
	pedidos p 
left join
	coes c on p.coes = c.nome
where 	
	data_pedido::date between '2024-06-01' and '2024-06-30'
	and p.coes in (
	'10 - REPOSIÇÃO VIVIX' ,
	'15 - REPOSICAO TEMPERADO' ,
	'15 - REPOSIÇÃO TEMPERADO - GT' ,
	'17 - REPOSICAO VIDRO CORTADO' ,
	'22 - REP PROD INTERNA' ,
	'ENGENHARIA REPOSIÇÃO' ,
	'ENGENHARIA REPOSIÇÃO TEMPERADO' ,
	'ENGERARIA REPOSIÇÃO TEMPERADOARIA' ,
	'REPOSIÇÃO' ,
	'REPOSIÇÃO BOX CLIENTE' ,
	'REPOSICAO CHAPARIA CORTADA' ,
	'REPOSICAO COMERCIAL ENG' ,
	'REPOSIÇÃO DE TEMPERADO' ,
	'REPOSIÇÃO ENG' ,
	'REPOSICAO ENGENHARIA' ,
	'REPOSIÇÃO ENGENHARIA' ,
	'REPOSIÇÃO ENGENHARIA (antigo)' ,
	'REPOSICAO ESPELHO VIVIX' ,
	'REPOSIÇÃO LOJA' ,
	'REPOSIÇÃO SÉRIE' ,
	'REPOSIÇÃO TEMPERADO' ,
	'REPOSIÇÃO VIVIX' ,
	'REPOSIÇÃO VIVIX - ENGENHARIA' ,
	'REPOSIÇÃO VIVIX - GT'
	)