select 
	%(Tipo_Unidade)s as Tipo_Unidade,
	%(Unidade)s as Unidade,
	titulos.DT_PAGTO as DataEntrada, 
	titulos.NU_CLT as ChavePagamento, 
	titulos.NU_CLI as CodCliente, 
	cli.DS_CLI as Cliente,
	titulos.VLR_PAGO as Valor,
	case 
		WHEN 1 and formaPag.NU_CON is null and titulos.DS_OBS like ('%Stone%') THEN 'Conta Interna'     
		WHEN 1 and formaPag.NU_CON is null THEN 'Dinheiro'   
		when formaPag.TP_PAGTO = 1 then 'BANCO'
		when formaPag.TP_PAGTO = 2 then 'CHEQUES'
		when formaPag.TP_PAGTO = 4 then 'SALDO'
		when formaPag.TP_PAGTO = 5 then 'OUTROS'
		when formaPag.TP_PAGTO = 6 then 'BOLETO'
		when formaPag.TP_PAGTO = 7 then 'DEPOSITO'
	end as TipoPagamento
	from mgcta01014 titulos 
	left join mgcli01010 cli on cli.NU_CLI = titulos.NU_CLI 
	left join mgcta01018 formaPag on formaPag.NU_CLT = titulos.NU_CLT 
	where NU_TPD = 300
	and titulos.NU_CLI is not null 
	and ID_STAT_LANCTO = 2
	order by date(DT_PAGTO) desc 
