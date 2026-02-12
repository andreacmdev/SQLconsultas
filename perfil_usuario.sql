select
	%(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,  
	usu.NOM_USU ,
	usu.DS_LOGIN ,
	perfil.DS_PFL ,
	usu.ID_ATIVO 
from mgusu01010 usu
left join mgpfl01010 perfil on usu.NU_PFL = perfil.NU_PFL 
where perfil.DS_PFL like '%Admi%'