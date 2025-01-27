-- estoque_aluminio
SELECT
    tipo_unidade,
    unidade,
    categoria,
    SUM(estoque_qtd) AS total_estoque_qtd,
    SUM(estoque_peso) AS total_estoque_peso,
    SUM(custo) AS total_custo
FROM estoque_completo_disponivel_data ecdd
WHERE ecdd.categoria ILIKE '%ALUM%' 
  AND ecdd.categoria ILIKE '%BARRA%'
GROUP BY 
    tipo_unidade,
    unidade,
    categoria;