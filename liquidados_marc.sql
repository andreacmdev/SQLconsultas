(				
select
%(Tipo_Unidade)s AS Tipo_Unidade,
%(Unidade)s AS Unidade,  								
'Cheque' as tipo_documento,								
tit.DT_PAGTO as data_pagamento,								
tit.NU_CLI as cod_cliente,						
tit.cliente as cliente,									
cheque.nu_dch as id_documento,								
bancos.DS_BAN as banco,									
cheque.nu_agencia as id_agencia,							
cheque.nu_conta as conta,							
cheque.nu_cheque as identificacao,						
cheque.VLR_CHEQUE as valor,						
cheque.DT_CHEQUE as data_vencimento,						
cheque.DT_BAIXA as data_lancamento,
cheque.NU_DSF as dsf,							
case 				
	when cheque.ID_STATUS = 1 then 'Financeiro'								
	when cheque.ID_STATUS = 2 then 'Devolvido Pendente'							
	when cheque.ID_STATUS = 3 then 'Devolvido Pago'					
	when cheque.ID_STATUS = 4 then 'A Liquidar'						
	when cheque.ID_STATUS = 5 then 'Liquidado'						
	when cheque.ID_STATUS = 6 then 'Repassado'				
	when cheque.ID_STATUS = 7 then 'Estornado'					
	when cheque.ID_STATUS = 8 then 'Trocado'					
end																
as situacao,					
cheque.Pendente_Tipo as tipo_pendencia,						
cheque.DT_DEV as data_devolucao,				
cheque.titulo_gerado as titulo_gerado,					
cheque.FLAG_TERCEIROS as id_terceiros,					
cheque.NOME_TERC as nome_terceiros					
from mgcta01016 cheque 						
left join (select titulos.NU_CLI, cli.DS_CLI as cliente, titulos.NU_CLT, MAX(titulos.DT_EMISSAO) as dt_emissao, MAX(titulos.DT_PAGTO) as DT_PAGTO  from mgcta01014 titulos left join mgcli01010 cli on cli.NU_CLI = titulos.NU_CLI group by NU_CLI, NU_CLT) tit on tit.NU_CLT = cheque.NU_CLT_ORIGEM 				
left join mgban01010 bancos on bancos.NU_BAN = cheque.NU_BANCO 																																							
where cheque.DT_BAIXA >= '2026-03-01' and cheque.DT_BAIXA < '2026-04-01'and cheque.ID_STATUS = '5'							
) 														
UNION ALL 						
(						
select  
%(Tipo_Unidade)s AS Tipo_Unidade,
%(Unidade)s AS Unidade,    
'Boleto' as tipo_documento,          
boletos.DT_PAGTO as data_pagamento,      
tit.NU_CLI as cod_cliente,     
clientes.DS_CLI as cliente,       
boletos.NU_DBL as id_documento,      
bancos.DS_BAN as banco,     
'' as id_agencia,     
'' as conta,      
boletos.DS_BOLETO as identificacao,				
boletos.VLR_BOLETO as valor,				
boletos.DT_VENCT as data_vencimento,				
boletos.DT_BAIXA as data_lancamento,
boletos.NU_DSF as dsf,					
case 																			
	when boletos.ID_STATUS = 1 then 'Financeiro'				
	when boletos.ID_STATUS = 2 then 'Devolvido Pendente'			
	when boletos.ID_STATUS = 3 then 'Devolvido Pago'			
	when boletos.ID_STATUS = 4 then 'A Liquidar'				
	when boletos.ID_STATUS = 5 then 'Liquidado'				
	when boletos.ID_STATUS = 6 then 'Repassado'					
	when boletos.ID_STATUS = 7 then 'Estornado'					
	when boletos.ID_STATUS = 8 then 'Trocado'					
end															
as situacao,												
boletos.Pendente_Tipo as tipo_pendencia,							
boletos.DT_DEV as data_devolucao,						
boletos.titulo_gerado as titulo_gerado,							
'N' as terceiros,							
'' as nome_terceiros								
from mgcta01020 boletos																												
left join (select NU_CLI, NU_CLT from mgcta01014 titulos group by NU_CLI, NU_CLT) tit on tit.NU_CLT = boletos.NU_CLT_ORIGEM 				
left join mgcli01010 clientes on clientes.NU_CLI = tit.NU_CLI 					
left join mgban01010 bancos on bancos.NU_BAN = boletos.NU_BAN						
where boletos.DT_BAIXA >= '2026-03-01' and boletos.DT_BAIXA < '2026-04-01' and boletos.ID_STATUS = '5' 						
)