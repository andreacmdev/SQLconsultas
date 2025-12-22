(
SELECT
	 %(Tipo_Unidade)s AS Tipo_Unidade
	, %(Unidade)s AS Unidade
	, titulos.nu_cta AS chave 
	, DATE(titulos.DT_PAGTO) AS data_pagamento 
	, (titulos.VLR_PAGO*IFNULL(titConta.perc,100))/100 AS vlr_pago 
	, titulos.DS_CPG AS descricao 
	, fornecedor.DS_FOR as fornecedor_cliente 
	, classificacao.DS_TPD AS classificacao 
	, centroCusto.DS_NIVEL as nivel_centro_custo
	, centroCusto.DS_CCU as centro_custo
	, planoConta.DS_NIVEL as nivel_plano_conta
	, planoConta.DS_CPC as plano_conta
, CASE formas.TP_PAGTO     
		WHEN 1 and formas.NU_CON is null THEN 'Dinheiro'     
		WHEN 1 and formas.NU_CON is not null THEN 'Conta Interna'    
		WHEN 2 THEN 'Cheque'    
		WHEN 3 THEN 'Cartao' 
		WHEN 4 THEN 'Saldo' 
		WHEN 5 THEN 'Outros' 
		WHEN 6 THEN 'Boleto' 
		WHEN 7 THEN 'Deposito' 
		WHEN 8 THEN 'Duplicata' 
		WHEN 9 THEN 'Saldo de Outro Cliente' 
		ELSE 'Nao Determinado' 
	END AS forma_pagamento 
	, contas.DS_CON as nome_conta   
	, 0 as cod_dlt   
	, 'Saida' AS tipo_de_lancamento 
	, titulos.NU_DOCTO as Documento
	, col.DS_COL as Colaborador      
FROM mgcta01014 AS titulos    
LEFT JOIN mgfor01010 AS fornecedor ON (fornecedor.NU_FOR = titulos.NU_FOR) 
LEFT JOIN mgtpd01010 AS classificacao ON (titulos.NU_TPD = classificacao.NU_TPD)  
left join mgtxc01010 titConta on (titulos.NU_CTA=titConta.NU_CTA) 
left join mgccu01010 centroCusto on (titConta.NU_CCU=centroCusto.NU_CCU) 
left join mgcpc01010 planoConta on (titConta.NU_CPC=planoConta.NU_CPC) 
left join ( 
	select NU_CLT, MAX(TP_PAGTO) as TP_PAGTO, SUM(VLR_DLT) as VLR_DLT , MAX(NU_CON) as NU_CON  
	FROM mgcta01018 f 
	GROUP by NU_CLT 
) formas ON (formas.NU_CLT = titulos.NU_CLT) 
LEFT JOIN mgcta01017 AS pagamentos ON (titulos.NU_CLT = pagamentos.NU_CLT)  
left join mgcol01010 col on col.NU_COL = titulos.NU_COL    
left join mgcon01010 contas on contas.NU_CON = formas.NU_CON       
WHERE  
	titulos.DT_PAGTO >= '2025-11-01'
	AND titulos.COD_LANCTO = 2 And titulos.ID_STAT_LANCTO = 2
	order by titulos.DS_CPG 
) 
 UNION ALL 
(SELECT 
	 %(Tipo_Unidade)s AS Tipo_Unidade
	, %(Unidade)s AS Unidade
	, titulos.nu_clt AS chave 
	, DATE(pagamentos.data_lancto) AS data_pagamento 
	, formas.vlr_dlt AS vlr_pago 
	, pagamentos.obs AS descricao 
	, clientes.DS_CLI as fornecedor_cliente 
	, tipoPagamento.ds_tpd AS classificacao 
	, centroCusto.DS_NIVEL as nivel_centro_custo 
	, centroCusto.DS_CCU as centro_custo 
	, planoConta.DS_NIVEL as nivel_plano_conta 
	, planoConta.DS_CPC as plano_conta 
	,	CASE formas.TP_PAGTO       
		WHEN 1 and formas.NU_CON is null THEN 'Dinheiro'       
		WHEN 1 and formas.NU_CON is not null THEN 'Conta Interna'    
		WHEN 2 THEN 'Cheque' 
		WHEN 3 THEN 'Cartao' 
		WHEN 4 THEN 'Saldo' 
		WHEN 5 THEN 'Outros' 
		WHEN 6 THEN 'Boleto' 
		WHEN 7 THEN 'Deposito' 
		WHEN 8 THEN 'Duplicata' 
		WHEN 9 THEN 'Saldo de Outro Cliente' 
		ELSE 'Nao Determinado' 
	END AS forma_pagamento 
	, contas.DS_CON AS nome_conta 
	, formas.NU_DLT AS cod_dlt 
	, 'Entrada' AS tipo_de_lancamento
	, titulos.NU_DOCTO as Documento   
	, '' as Colaborador   
FROM mgcta01017 pagamentos 
LEFT JOIN mgcta01014 titulos ON (titulos.NU_CLT = pagamentos.NU_CLT) 
LEFT JOIN mgcta01018 formas ON (formas.NU_CLT = pagamentos.NU_CLT) 
LEFT JOIN mgcli01010 clientes ON (titulos.NU_CLI = clientes.NU_CLI) 
LEFT JOIN mgtpd01010 tipoPagamento ON (tipoPagamento.NU_TPD = titulos.NU_TPD)  
left join mgtxc01010 titConta on (titulos.NU_CTA=titConta.NU_CTA) 
left join mgccu01010 centroCusto on (titConta.NU_CCU=centroCusto.NU_CCU) 
left join mgcpc01010 planoConta on (titConta.NU_CPC=planoConta.NU_CPC)  
left join mgcon01010 contas on contas.NU_CON = formas.NU_CON   
WHERE (pagamentos.data_lancto  >= '2025-11-01' and titulos.ID_STAT_LANCTO <> '4'    
	AND pagamentos.TP_LANCTO = 'E' ) GROUP BY formas.NU_DLT ) 
UNION ALL 
(
SELECT 
 	%(Tipo_Unidade)s AS Tipo_Unidade
	, %(Unidade)s AS Unidade
	, titulos.nu_clt AS chave  
	, DATE(pagamentos.data_lancto) AS data_pagamento  
	, formas.vlr_dlt AS vlr_pago  
	, pagamentos.obs AS descricao  
	, clientes.DS_CLI as fornecedor_cliente  
	, tipoPagamento.ds_tpd AS classificacao  
	, centroCusto.DS_NIVEL as nivel_centro_custo  
	, centroCusto.DS_CCU as centro_custo  
	, planoConta.DS_NIVEL as nivel_plano_conta    
	, planoConta.DS_CPC as plano_conta     
	,	CASE formas.TP_PAGTO        
		WHEN 1 and formas.NU_CON is null THEN 'Dinheiro'        
		WHEN 1 and formas.NU_CON is not null THEN 'Conta Interna'       
		WHEN 2 THEN 'Cheque'     
		WHEN 3 THEN 'Cartao'  
		WHEN 4 THEN 'Saldo'  
		WHEN 5 THEN 'Outros'  
		WHEN 6 THEN 'Boleto'  
		WHEN 7 THEN 'Deposito'  
		WHEN 8 THEN 'Duplicata'  
		WHEN 9 THEN 'Saldo de Outro Cliente'  
		ELSE 'Nao Determinado'  
	END AS forma_pagamento  
	, contas.DS_CON AS nome_conta  
	, formas.NU_DLT AS cod_dlt  
	, 'Entrada Avulsa' AS tipo_de_lancamento  
	, titulos.NU_DOCTO as Documento   
	, '' as Colaborador       
FROM mgcta01017 pagamentos   
LEFT JOIN mgcta01014 titulos ON (titulos.NU_CLT = pagamentos.NU_CLT)   
LEFT JOIN mgcta01018 formas ON (formas.NU_CLT = pagamentos.NU_CLT)   
LEFT JOIN mgcli01010 clientes ON (titulos.NU_CLI = clientes.NU_CLI)   
LEFT JOIN mgtpd01010 tipoPagamento ON (tipoPagamento.NU_TPD = titulos.NU_TPD)    
left join mgtxc01010 titConta on (titulos.NU_CTA=titConta.NU_CTA)   
left join mgccu01010 centroCusto on (titConta.NU_CCU=centroCusto.NU_CCU)    
left join mgcpc01010 planoConta on (titConta.NU_CPC=planoConta.NU_CPC)  
left join mgcon01010 contas on contas.NU_CON = formas.NU_CON    
WHERE (pagamentos.data_lancto  >= '2025-11-01'
	AND pagamentos.TP_LANCTO = 'E' and titulos.ID_STAT_LANCTO = '2' 
	and titulos.COD_LANCTO = '1' and titulos.TITULO_AVULSO = 'S' 
	) GROUP BY formas.NU_DLT  
) 
