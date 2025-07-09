select
	%(Tipo_Unidade)s AS Tipo_Unidade,
	%(Unidade)s AS Unidade,  
	dsf.NU_DSF as numero,
	CASE 
        WHEN dsf.ID_STATUS = 1 THEN 'ABERTO'     
     	when dsf.ID_STATUS = 3 then 'A CONCILIAR'
     	else 'finalizado'
    END AS status,   
	dsf.DT_DSF as data_emissao,
	banco.DS_BAN as instituicao_financeira,
	conta.DS_CON as conta_credito,
	case
		when dsf.TP_DSF = 0 then 'Antecipacao'
		when dsf.TP_DSF = 2 then 'Deposito'
	end as tipo_dsf,
	case
		when dsf.TP_ESPECIE = 3  then 'Cartao'
		when dsf.TP_ESPECIE = 4  then 'Boleto'
		when dsf.TP_ESPECIE = 2  then 'Dinheiro'
		when dsf.TP_ESPECIE = 0  then 'Cheque'
		else 'duplicata'
	end as especie,
	dsf.DS_OBS as observacao,
	dsf.VALOR_BRUTO as valor_bruto,
	dsf.VALOR_LIQUIDO as valor_liquido,
	dsf.NU_USU_INC as usuario_inserc,
	usuario_INC.DS_LOGIN as usuario_insercao,
	usuario_FIN.DS_LOGIN as usuario_finalizacao
from mgdsf01010 dsf
left join mgcon01010 conta on dsf.NU_CON = conta.NU_CON
left join mgban01010 banco on conta.NU_BAN = banco.NU_BAN
left join mgusu01010 usuario_INC on dsf.NU_USU_INC = usuario_INC.NU_USU
left join mgusu01010 usuario_FIN on dsf.NU_USU_FIN = usuario_FIN.DS_LOGIN
where dsf.ID_STATUS in ('1', '3') 
and dsf.TP_DSF in ('0', '2')