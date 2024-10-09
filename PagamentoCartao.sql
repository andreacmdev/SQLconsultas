select 
	%(Tipo_Unidade)s as Tipo_Unidade,
	%(Unidade)s as Unidade,
	dsf.DT_DSF, 
	card.*, conta.DS_CON as Conta, 
	ROUND(Valor/QtdParcelas,2)  as ValorParcela,
	case   
		when TP_ESPECIE = 4 then 'BOLETO'   
		when TP_ESPECIE = 2 then 'DINHEIRO'   
		when TP_ESPECIE = 3 then 'CARTÃO'  
		when TP_ESPECIE = 0 then 'CHEQUE'  
		when TP_ESPECIE = 1 then 'DUPLICATA'   
	end as tipodsf,
	identificacao
	from (
	select NU_DLT, NU_DSF, NU_CLT_ORIGEM, cartoes.DS_CAR as Cartao, SUBSTRING_INDEX(ident_cartao, "-", 1) as Identificacao, SUM(VLR_CARTAO) as Valor, COUNT(distinct IDENT_CARTAO) as QtdParcelas
	from mgcta01019 recebimentos 
	left join mgcar01010 cartoes on recebimentos.NU_CAR = cartoes.NU_CAR 
	group by NU_DLT, NU_DSF, NU_CLT_ORIGEM, cartoes.DS_CAR, SUBSTRING_INDEX(ident_cartao, "-", 1)
	) card
	left join mgdsf01010 dsf on dsf.NU_DSF = card.NU_DSF
	left join mgcon01010 conta on conta.NU_CON = dsf.NU_CON 
	left join mgban01010 banco on banco.NU_BAN = dsf.NU_BAN 
	where date(dsf.DT_DSF) BETWEEN '2023-09-27' AND CURDATE()
	order by dsf.DT_DSF desc