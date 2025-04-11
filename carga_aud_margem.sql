select 
	p.tipo_unidade,
	p.unidade,
	p.cod_cliente ,
	p.nome_cliente ,
	p.cod_pedido ,
	p.nome_produto ,
	p.categoria_produto,
	p.classe_produto,
	p.cod_cliente,
	p.coes,
	p.cond_pagamento,
	P.valor_unitario_total_com_desconto as valor_unitario ,
	p.custo_unitario_total_produto ,
	p.data_hora_pedido ,
	ROUND(p.margem_bruta_produto::numeric) as margem,
	mc.ramo_atividade ,
	p.valor_total_pedido,
	p.qtd_produto,
	p.metragem_cobrada::numeric
from pedidos p
left join mapeamento_clientes mc on p.cod_cliente = mc.codcliente and p.unidade = mc.unidade 
where p.margem_bruta_produto::NUMERIC < '29'
and p.categoria_produto ilike '%chapa%'
and TO_TIMESTAMP(last_updated, 'YYYY-MM-DD HH24:MI:SS') >= NOW() - INTERVAL '400 minutes'
and p.coes != 'TRANSFERENCIA ENTRE LOJAS'
and mc.ramo_atividade != 'INTERCOMPANY'


