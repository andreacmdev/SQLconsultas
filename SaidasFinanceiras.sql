(
SELECT
	%(Tipo_Unidade)s AS Tipo_Unidade
	, %(Unidade)s AS Unidade
	, titulos.nu_cta AS chave 
	, DATE(titulos.DT_PAGTO) AS data_pagamento 
	, (titulos.VLR_PAGO*IFNULL(titConta.perc,100))/100 AS vlr_pago 
	, titulos.DS_CPG AS descricao 
	, classificacao.DS_TPD AS classificacao 
	, centroCusto.DS_CCU as centro_custo
	, planoConta.DS_CPC as plano_conta   
	, coalesce(fornecedor.DS_FOR,col.DS_COL) as FornecedorColaborador      
FROM mgcta01014 AS titulos    
LEFT JOIN mgfor01010 AS fornecedor ON (fornecedor.NU_FOR = titulos.NU_FOR) 
LEFT JOIN mgtpd01010 AS classificacao ON (titulos.NU_TPD = classificacao.NU_TPD)  
left join mgtxc01010 titConta on (titulos.NU_CTA=titConta.NU_CTA) 
left join mgccu01010 centroCusto on (titConta.NU_CCU=centroCusto.NU_CCU) 
left join mgcpc01010 planoConta on (titConta.NU_CPC=planoConta.NU_CPC) 
LEFT JOIN mgcta01017 AS pagamentos ON (titulos.NU_CLT = pagamentos.NU_CLT)  
left join mgcol01010 col on col.NU_COL = titulos.NU_COL        
WHERE  
	titulos.DT_PAGTO >= '2024-01-01'
	AND titulos.COD_LANCTO = 2 And titulos.ID_STAT_LANCTO = 2
	order by titulos.DS_CPG 
) 
