SELECT 
	  %(Tipo_Unidade)s AS Tipo_Unidade
	, %(Unidade)s AS Unidade
	, concat(coalesce(centroCusto.DS_NIVEL,'0'),'.',COALESCE(planoConta.DS_NIVEL,0)) as nivel
	, titulos.DT_PAGTO AS data_pagamento 
	, ROUND((titulos.VLR_PAGO*IFNULL(titConta.perc,100))/100,2) AS Valor 
	, centroCusto.DS_CCU as centro_custo
	, classificacao.DS_TPD AS classificacao 	
	, planoConta.DS_CPC as plano_conta
	, titulos.DS_CPG AS descricao 
FROM mgcta01014 AS titulos    
LEFT JOIN mgtpd01010 AS classificacao ON (titulos.NU_TPD = classificacao.NU_TPD)  
left join mgtxc01010 titConta on (titulos.NU_CTA=titConta.NU_CTA) 
left join mgccu01010 centroCusto on (titConta.NU_CCU=centroCusto.NU_CCU) 
left join mgcpc01010 planoConta on (titConta.NU_CPC=planoConta.NU_CPC) 
WHERE  
	date(titulos.DT_PAGTO) between date('2024-01-01') and CURRENT_DATE
	AND titulos.COD_LANCTO = 2 And titulos.ID_STAT_LANCTO = 2
	and classificacao.DS_TPD not in ('PAGAMENTO DE ADIANTAMENTO', 'DEVOLUÇÃO DE SALDO', 'PEDIDO DE COMPRAS')