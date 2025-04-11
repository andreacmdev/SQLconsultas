select 
	eg.tipo_unidade, 
	eg.unidade, 
	eg.cod_cliente, 
	eg.nome_cliente, 
	eg.rota, eg.carga, 
	eg.cod_romaneio, 
	eg.data_hora_entregue, 
	ROUND(sum(valor_entregue),2) as Entregue, 
	pp.status_pagamento 
from entregas_geral eg
	left join (
		select 
			unidade, 
			cod_pedido, 
			status_pagamento 
		from pagamentos_pedidos pp 
		where 
			status_pagamento = 'Pendente'
		group by unidade, cod_pedido, status_pagamento 
	) pp on pp.unidade = eg.unidade and pp.cod_pedido = eg.cod_pedido 
where 
	CONCAT(eg.unidade,'_',carga,'_',placa_veiculo) = '{{2.carga_id}}' 
	and pp.status_pagamento is not null 
	and eg.nome_cliente not in ('DOUGLAS RENATO MARCOLAN','DIEGO MONTEIRO MARCOLAN','DAVID MARCOLAN',
	'DAVID MARCOLAN','DAVID OAZEM MARCOLAN','DIEGO H. MONTEIRO MARCOLAN C. DE V. LTDA - PAULISTA',
	'DIEGO HENRIQUE MARCOLAN COMERCIO DE VIDROS LTDA','DIEGO HENRIQUE MONTEIRO MARCOLAN - GM GLASS',
	'DIEGO HENRIQUE MONTEIRO MARCOLAN COMERCIO DE VIDROS LTDA','DIEGO HENRIQUE MONTEIRO MARCOLAN COMÉRCIO DE VIDROS LTDA')
group by tipo_unidade, eg.unidade, nome_cliente, rota, carga, cod_romaneio, 
data_hora_entregue, pp.status_pagamento, eg.cod_cliente