SELECT 
  %(Tipo_Unidade)s AS Tipo_Unidade,
  %(Unidade)s AS Unidade, 
    'Estoque' as Grupo
	, produtos.NU_PRO 
	, produtos.DS_COD_INTERNO as CodProduto
	, produtos.DS_PRO as NomeProduto
	, categoria.DS_CAT as categoria
	, classe.DS_CLP as Classe
	, subclasse.DS_SCP as Subclasse
	, produtos.NU_CUSTO as CustoUnitario
	, produtos.NU_ESTOQMI as EstoqueMinimo
	, produtos.NU_ESTOQAT  as EstoqueAtual
	, produtos.NU_ESTOQAT+mov.quantidade_movimentada  as EstoqueAtualCorrigido
	, produtos.FAT_CONV1 * produtos.NU_ESTOQAT as EstoqueMetro   
	, produtos.FAT_CONV1 * (produtos.NU_ESTOQAT+mov.quantidade_movimentada) as EstoqueMetroCorrigido   
	, produtos.FAT_CONV2 * (produtos.NU_ESTOQAT+mov.quantidade_movimentada) as EstoquePesoCorrigido
	, produtos.FAT_CONV1 as fator_conversao     
	, produtos.NU_PRECOV as PrecoVenda       
	, (produtos.NU_ESTOQAT * produtos.NU_CUSTO) as PrecoEstoque
	, ((produtos.NU_ESTOQAT + coalesce(mov.quantidade_movimentada,0))  * produtos.NU_CUSTO) as PrecoEstoqueAtualizado
	, mov.quantidade_movimentada
	, mov.Custo
	FROM mgpro01010 produtos LEFT JOIN mgcat01010 categoria ON produtos.NU_CAT=categoria.NU_CAT 
		LEFT JOIN mgclp01010 classe ON produtos.NU_CLP=classe.NU_CLP 
		LEFT JOIN mgscp01010 subclasse ON produtos.NU_SCP=subclasse.NU_SCP 
		left join (
		select 
	mov.NU_PRO as CodProduto,
	produto.DS_PRO as NomeProduto,
	SUM( 
		case 
			when TP_MOV = 2 then QT_MOV 
			else QT_MOV * -1
		end
	) as quantidade_movimentada,
	produto.NU_CUSTO as custo
from mgmov01010 mov 
left join mgpro01010 produto on mov.NU_PRO = produto.NU_PRO 
where DT_MOV > '2025-01-2020'
group by mov.NU_PRO, produto.DS_PRO
		) mov on mov.CodProduto = produtos.NU_PRO
		WHERE categoria.ID_ATIVO = 'S' and COALESCE(classe.ID_ATIVO,'S')  = 'S' and COALESCE(subclasse.ID_ATIVO, 'S') = 'S' and 
		produtos.ID_ATIVO = 'S' and COALESCE(categoria.ID_USOCONSUMO,'N') != "S" and produtos.TP_PROD = 1