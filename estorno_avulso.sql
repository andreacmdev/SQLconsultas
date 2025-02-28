select 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,  
	contas.NU_CON as CONTA,
	conta.DS_CON ,
	DT_LANCTO as data_lancamento,
	DS_LANCTO as descrição,
	TP_LANCTO as tipo,
	VLR_LANCTO as valor,
	SLD_ATUAL as saldo_atual,
	DT_REF as data_referencia,
	AVULSO,
	ESTORNADO,
	contas.NU_USU,
	usuario.NOM_USU as usuario,
	contas.DS_ESTORNO 
from mgcon01011 contas 
left join mgusu01010 usuario on contas.NU_USU = usuario.NU_USU 
left join mgcon01010 conta on contas.NU_CON = conta.NU_CON
where AVULSO = 'S' 
order by contas.DT_LANCTO desc