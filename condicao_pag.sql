select 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,  
	cond.NU_CPG,
	cond.DS_CPG,
	cond.ID_ATIVO,
	cond.CPG_BLOQUEADA_AO_GERAR_ROMANEIO_DE_PEDIDOS_PENDENTES
from mgcpg01010 cond
where cond.ID_ATIVO = 'S'