--desbloqueio de cliente
select 
	dc.tipo_unidade ,
	dc.unidade ,
	DATE(dc.data_alteracao  ::timestamp) AS data_alteracao ,
	dc.usuario ,
	dc.cod_cliente ,
	dc.nome_cliente 
from
	desbloqueio_clientes dc 
where 
	DATE(dc.data_alteracao ::timestamp) BETWEEN '2024-06-12' AND '2024-06-12'
	and tipo_unidade  = 'Loja'
order by
	tipo_unidade ,
	unidade ;