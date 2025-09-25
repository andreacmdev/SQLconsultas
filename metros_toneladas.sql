select
	p.tipo_unidade,
	p.unidade,
	p.tipo_pedido ,
	p.categoria_produto,
	p.classe_produto,
	p.sub_classe_produto,
	p.custo_unitario_produto,
	p.custo_unitario_total_produto,
	p.valor_unitario_total_com_desconto,
	p.metragem_real,
	p.metragem_cobrada
from pedidos p
where unidade in ('BRASILIA', 'FORTALEZA', '4D Vidros')
and p.data_hora_pedido >= '01-01-2025' and categoria_produto in ('LAMINADO', 'CHAPARIA ESPELHO', 'CHAPARIA LAMINADO', 'CHAPARIA LAM REFLETIVO', 'CHAPARIA LAMINADO REFLETIVO', 'CHAPARIA REFLETIVO')



SELECT
    p.tipo_unidade,
    p.unidade,
    p.tipo_pedido,
    p.categoria_produto,
    p.classe_produto,
    p.sub_classe_produto,
    p.custo_unitario_produto,
    p.custo_unitario_total_produto,
    p.valor_unitario_total_com_desconto,
    p.metragem_real,
    p.metragem_cobrada::numeric AS metragem_cobrada_num,
    v.espessura_mm,
    v.peso_por_metro,
    (v.peso_por_metro * p.metragem_cobrada::numeric) AS peso_total_kg,
    (v.peso_por_metro * p.metragem_cobrada::numeric / 1000) AS peso_total_ton
FROM pedidos p
CROSS JOIN LATERAL (
    SELECT
        SUM(x) AS espessura_mm,
        SUM(x) * 2.5 AS peso_por_metro
    FROM (
        SELECT trim(y)::numeric AS x
        FROM regexp_split_to_table(replace(lower(p.sub_classe_produto),'mm',''), '\+') AS y
    ) sub
) v
WHERE p.unidade IN ('BRASILIA', 'FORTALEZA', '4D Vidros')
  AND p.data_hora_pedido >= '2025-01-01'
  AND p.categoria_produto IN (
    'LAMINADO',
    'CHAPARIA ESPELHO',
    'CHAPARIA LAMINADO',
    'CHAPARIA LAM REFLETIVO',
    'CHAPARIA LAMINADO REFLETIVO',
    'CHAPARIA REFLETIVO'
  );




SELECT
    p.unidade,
    p.categoria_produto,
    SUM(p.metragem_cobrada::numeric) AS total_metros,
    -- Peso total em kg
    SUM(v.peso_por_metro * p.metragem_cobrada::numeric) AS total_kg,
    -- Peso total em toneladas
    SUM(v.peso_por_metro * p.metragem_cobrada::numeric) / 1000 AS total_ton,   
    -- Receita total
    SUM(p.valor_unitario_total_com_desconto::numeric) AS receita_total,
    -- Custo total
    SUM(p.custo_unitario_total_produto::numeric) AS custo_total,
    -- Valor agregado (lucro)
    SUM(p.valor_unitario_total_com_desconto::numeric - p.custo_unitario_total_produto::numeric) AS valor_agregado
FROM pedidos p
CROSS JOIN LATERAL (
    SELECT SUM(x::numeric) * 2.5 AS peso_por_metro
    FROM regexp_split_to_table(
        replace(lower(p.sub_classe_produto), 'mm',''), '\+'
    ) AS x
) v
WHERE p.unidade IN ('BRASILIA', 'FORTALEZA', '4D Vidros')
  AND p.data_hora_pedido >= '2025-01-01'
  AND p.categoria_produto IN (
    'LAMINADO',
    'CHAPARIA ESPELHO',
    'CHAPARIA LAMINADO',
    'CHAPARIA LAM REFLETIVO',
    'CHAPARIA LAMINADO REFLETIVO',
    'CHAPARIA REFLETIVO'
  )
GROUP BY p.unidade, p.categoria_produto
ORDER BY p.unidade, p.categoria_produto;


SELECT 
    p.unidade, 
    p.categoria_produto, 
    DATE_TRUNC('month', p.data_hora_pedido) AS mes,  -- agrupa por mês
    SUM(p.metragem_cobrada::numeric) AS total_metros,
    SUM(v.peso_por_metro * p.metragem_cobrada::numeric) AS total_kg,
    SUM(v.peso_por_metro * p.metragem_cobrada::numeric) / 1000 AS total_ton,
    SUM(p.valor_unitario_total_com_desconto::numeric) AS receita_total,
    SUM(p.custo_unitario_total_produto::numeric) AS custo_total,
    SUM(p.valor_unitario_total_com_desconto::numeric - p.custo_unitario_total_produto::numeric) AS valor_agregado
FROM pedidos p
CROSS JOIN LATERAL (
    SELECT SUM(x::numeric) * 2.5 AS peso_por_metro
    FROM regexp_split_to_table(replace(lower(p.sub_classe_produto), 'mm',''), '\+') AS x
) v
WHERE p.unidade IN ('BRASILIA', 'FORTALEZA', '4D Vidros')
  AND p.data_hora_pedido >= '2025-01-01'
  AND p.categoria_produto IN (
      'LAMINADO', 'CHAPARIA ESPELHO', 'CHAPARIA LAMINADO', 
      'CHAPARIA LAM REFLETIVO', 'CHAPARIA LAMINADO REFLETIVO', 'CHAPARIA REFLETIVO'
  )
GROUP BY p.unidade, p.categoria_produto, DATE_TRUNC('month', p.data_hora_pedido)
ORDER BY p.unidade, p.categoria_produto, mes;