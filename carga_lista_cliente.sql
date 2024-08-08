--clientes + saldo
select 
	mc.tipo_unidade ,
	mc.unidade ,
	mc.codcliente ,
	mc.nome_cliente ,
	mc.nome_fantasia ,
	mc.tipocliente ,
	mc.situacao ,
	mc.bloqueado ,
	mc.motivo_bloqueado ,
	s.total 
from
	mapeamento_clientes as mc
left join
	saldo as s
on 
	mc.nome_cliente  = s.nome 
where 
	mc.unidade = 'DVM PARAIBA'