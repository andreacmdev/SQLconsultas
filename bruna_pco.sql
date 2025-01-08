--bruna 
select
	%(Tipo_Unidade)s AS Tipo_Unidade,
	%(Unidade)s AS Unidade,
	pc.NU_PCO,
	pc.NU_FOR ,
	m.DS_FOR ,
	pc.DT_PCO ,
	pc.DT_ENCER 
from mgpco01010 pc 
left join mgfor01010 m on pc.NU_FOR = m.NU_FOR 
where ID_STATUS = '9'