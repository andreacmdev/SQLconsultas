select * from (
select 	
	 %(Tipo_Unidade)s as Tipo_Unidade
	,  %(Unidade)s as Unidade 
	, produtos.DS_PRO as NomeProduto
	, produtos.NU_CAT as CodCategoria
	, categoria.DS_CAT as categoria
	, classe.DS_CLP as Classe
	, subclasse.DS_SCP as subclasse
	, produtos.NU_CUSTO as CustoUnitario
	, produtos.NU_ESTOQAT  as EstoqueAtual
	, categoria.ID_ATIVO as Categoria_ativo
	, classe.ID_ATIVO as Classe_ativo
	, subclasse.ID_ATIVO as subClasse_ativo
	, produtos.ID_ATIVO as produto_ativo
	, categoria.ID_USOCONSUMO
	, produtos.ID_GER_ESTQ 
	, produtos.DS_COD_INTERNO
	, mov.UltimaMovimentacao
	FROM mgpro01010 produtos 
	LEFT JOIN mgcat01010 categoria ON produtos.NU_CAT=categoria.NU_CAT 
	LEFT JOIN mgclp01010 classe ON produtos.NU_CLP=classe.NU_CLP 
	LEFT JOIN mgscp01010 subclasse ON produtos.NU_SCP=subclasse.NU_SCP 
	left join ( 
		select MAX(NU_MOV) as CodMovimentacao, NU_PRO as CodProduto, MAX(DT_MOV) as UltimaMovimentacao
		from mgmov01010 mov group by NU_PRO
		order by MAX(DT_MOV) desc 
	) mov on mov.CodProduto = produtos.nu_pro
		WHERE 
		-- categoria.ID_ATIVO = 'S' and 
		-- COALESCE(classe.ID_ATIVO,'S')  = 'S' and 
		-- COALESCE(subclasse.ID_ATIVO, 'S') = 'S' and 
		produtos.ID_ATIVO = 'S' and 
		COALESCE(categoria.ID_USOCONSUMO,'N') != 'S'and 
		produtos.TP_PROD = 1 and 
		produtos.ID_GER_ESTQ <> 2
) x  
where classe_ativo = 'N' or subclasse_ativo = 'N' or categoria_ativo = 'N'
