    -- Nome: preco_medio_mes.sql
    -- Banco: PostgreSQL
    -- Tipo: relatório base para dashboard lovable
    -- Utilização: Script Python (Exportação Excel)
    -- Área: Comercial
    -- Descrição: Gera relatório consolidado de preço médio de cada mês de chaparia e temperado em todas as unidades.
    -- Autor: André Machado
    -- Data Criação: 2026-03
    -- Status: Ativo


  WITH precos AS (
    SELECT
        eg.tipo_unidade,
        eg.unidade,
        eg.cod_produto::text,
        eg.nome_produto,
        eg.categoria_produto,
        eg.classe_produto,
        eg.sub_classe_produto,
		ROUND((eg.valor_entregue / NULLIF(eg.metragem_entregue::numeric, 0::numeric))::numeric, 2) AS preco_m2,
        DATE_TRUNC('month', eg.data_hora_entregue) AS mes
    FROM entregas_geral eg
    WHERE eg.data_hora_entregue::date >= '2025-01-01'
      AND eg.metragem_entregue > '0'
      AND eg.categoria_produto ILIKE ANY (ARRAY['%chaparia%', '%temperado%''])
),
moda_geral AS (
    SELECT
        cod_produto::text,
        preco_m2 AS moda_preco_m2,
        ROW_NUMBER() OVER (PARTITION BY cod_produto::text ORDER BY COUNT(*) DESC) AS rn
    FROM precos
    GROUP BY cod_produto, preco_m2
),
moda_mensal AS (
    SELECT
        cod_produto::text,
        mes,
        preco_m2 AS moda_mes,
        ROW_NUMBER() OVER (PARTITION BY cod_produto::text, mes ORDER BY COUNT(*) DESC) AS rn
    FROM precos
    GROUP BY cod_produto, mes, preco_m2
)
SELECT
    p.tipo_unidade,
    p.unidade,
    p.cod_produto,
    p.nome_produto,
    p.categoria_produto,
    p.classe_produto,
    p.sub_classe_produto,
    mg.moda_preco_m2,
    MAX(CASE WHEN mm.mes = '2025-01-01' THEN mm.moda_mes END) AS "Jan/25",
    MAX(CASE WHEN mm.mes = '2025-02-01' THEN mm.moda_mes END) AS "Fev/25",
    MAX(CASE WHEN mm.mes = '2025-03-01' THEN mm.moda_mes END) AS "Mar/25",
    MAX(CASE WHEN mm.mes = '2025-04-01' THEN mm.moda_mes END) AS "Abr/25",
    MAX(CASE WHEN mm.mes = '2025-05-01' THEN mm.moda_mes END) AS "Mai/25",
    MAX(CASE WHEN mm.mes = '2025-06-01' THEN mm.moda_mes END) AS "Jun/25",
    MAX(CASE WHEN mm.mes = '2025-07-01' THEN mm.moda_mes END) AS "Jul/25",
    MAX(CASE WHEN mm.mes = '2025-08-01' THEN mm.moda_mes END) AS "Ago/25",
    MAX(CASE WHEN mm.mes = '2025-09-01' THEN mm.moda_mes END) AS "Set/25",
    MAX(CASE WHEN mm.mes = '2025-10-01' THEN mm.moda_mes END) AS "Out/25",
    MAX(CASE WHEN mm.mes = '2025-11-01' THEN mm.moda_mes END) AS "Nov/25",
    MAX(CASE WHEN mm.mes = '2025-12-01' THEN mm.moda_mes END) AS "Dez/25",
    MAX(CASE WHEN mm.mes = '2026-01-01' THEN mm.moda_mes END) AS "Jan/26",
    MAX(CASE WHEN mm.mes = '2026-02-01' THEN mm.moda_mes END) AS "Fev/26",
    MAX(CASE WHEN mm.mes = '2026-03-01' THEN mm.moda_mes END) AS "Mar/26"
FROM precos p
JOIN moda_geral mg  ON mg.cod_produto::text = p.cod_produto::text AND mg.rn = 1
JOIN moda_mensal mm ON mm.cod_produto::text = p.cod_produto::text AND mm.rn = 1
GROUP BY
    p.tipo_unidade, p.unidade, p.cod_produto, p.nome_produto,
    p.categoria_produto, p.classe_produto, p.sub_classe_produto,
    mg.moda_preco_m2