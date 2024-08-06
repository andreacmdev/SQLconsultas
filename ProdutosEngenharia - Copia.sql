select 
	%(Tipo_Unidade)s as Tipo_Unidade,
	%(Unidade)s as Unidade,
	cat.DS_CAT as Categoria,
	cla.DS_CLP as Classe,
	sub.DS_SCP as SubClasse,
	pro.DS_PRO as Produto,
	pro.NU_CUSTO as Custo
from mgpro01010 pro
left join mgcat01010 cat on pro.NU_CAT = cat.NU_CAT 
left join mgclp01010 cla on pro.NU_CLP = cla.NU_CLP 
left join mgscp01010 sub on pro.NU_SCP = sub.NU_SCP 
where TP_PROD = 2 and pro.ID_ATIVO = 'S'