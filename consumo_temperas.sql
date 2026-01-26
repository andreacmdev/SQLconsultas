select unidade,
SUM(
  ABS(
    REPLACE(qtd_movimentacao, ',', '.')::numeric
  )
) AS quantidade,
nome_produto,
categoria,
classe,
subclasse,
cod_produto
from estoque_produtos ep 
where data_movimentacao::DATE >= '2026-01-01' and tipo_unidade = 'Tempera'
AND (
  categoria ILIKE '%CHAPAR%'
  OR categoria ILIKE '%CORT%'
  or categoria ilike '%TEMPER%'
)
AND ep.tipo_movimentacao = 'PRODUCAO'
group by unidade, nome_produto, categoria, classe, subclasse, cod_produto