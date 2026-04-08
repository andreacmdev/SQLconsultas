    -- Nome: preco_medio_mes.sql
    -- Banco: PostgreSQL
    -- Tipo: relatório base para dashboard lovable
    -- Utilização: Script Python (Exportação Excel)
    -- Área: Comercial
    -- Descrição: Gera relatório consolidado de preço médio de cada mês de chaparia e temperado em todas as unidades.
    -- Autor: André Machado
    -- Data Criação: 2026-03
    -- Status: Ativo

    WITH base AS (
    SELECT
        eg.tipo_unidade,
        eg.unidade,
        eg.cod_produto::text,
        eg.nome_produto,
        eg.categoria_produto,
        eg.classe_produto,
        eg.sub_classe_produto,
        ROUND((eg.valor_entregue / NULLIF(eg.metragem_entregue::numeric, 0::numeric))::numeric, 2) AS preco_m2,
        eg.metragem_entregue::numeric AS metragem,
        eg.valor_entregue::numeric AS valor,
        DATE_TRUNC('month', eg.data_hora_entregue) AS mes
    FROM entregas_geral eg
    WHERE eg.data_hora_entregue::date >= '2025-01-01'
      AND eg.metragem_entregue > '0'
      AND eg.categoria_produto ILIKE ANY (ARRAY['%chaparia%', '%temperado%'])
),
agregado AS (
    SELECT
        unidade,
        cod_produto,
        mes,
        SUM(metragem) AS total_metragem,
        SUM(valor)    AS total_valor,
        (array_agg(preco_m2 ORDER BY count_preco DESC))[1] AS moda_mes
    FROM (
        SELECT unidade, cod_produto, mes, metragem, valor, preco_m2,
               COUNT(*) OVER (PARTITION BY unidade, cod_produto, mes, preco_m2) AS count_preco
        FROM base
    ) x
    GROUP BY unidade, cod_produto, mes
),
moda_geral AS (
    SELECT unidade, cod_produto,
           (array_agg(preco_m2 ORDER BY cnt DESC))[1] AS moda_preco_m2
    FROM (
        SELECT unidade, cod_produto, preco_m2, COUNT(*) AS cnt
        FROM base
        GROUP BY unidade, cod_produto, preco_m2
    ) y
    GROUP BY unidade, cod_produto
)
SELECT
    b.tipo_unidade, b.unidade, b.cod_produto, b.nome_produto,
    b.categoria_produto, b.classe_produto, b.sub_classe_produto,
    mg.moda_preco_m2,
    MAX(CASE WHEN a.mes = '2025-01-01' THEN a.moda_mes END)       AS "Jan/25",
    MAX(CASE WHEN a.mes = '2025-02-01' THEN a.moda_mes END)       AS "Fev/25",
    MAX(CASE WHEN a.mes = '2025-03-01' THEN a.moda_mes END)       AS "Mar/25",
    MAX(CASE WHEN a.mes = '2025-04-01' THEN a.moda_mes END)       AS "Abr/25",
    MAX(CASE WHEN a.mes = '2025-05-01' THEN a.moda_mes END)       AS "Mai/25",
    MAX(CASE WHEN a.mes = '2025-06-01' THEN a.moda_mes END)       AS "Jun/25",
    MAX(CASE WHEN a.mes = '2025-07-01' THEN a.moda_mes END)       AS "Jul/25",
    MAX(CASE WHEN a.mes = '2025-08-01' THEN a.moda_mes END)       AS "Ago/25",
    MAX(CASE WHEN a.mes = '2025-09-01' THEN a.moda_mes END)       AS "Set/25",
    MAX(CASE WHEN a.mes = '2025-10-01' THEN a.moda_mes END)       AS "Out/25",
    MAX(CASE WHEN a.mes = '2025-11-01' THEN a.moda_mes END)       AS "Nov/25",
    MAX(CASE WHEN a.mes = '2025-12-01' THEN a.moda_mes END)       AS "Dez/25",
    MAX(CASE WHEN a.mes = '2026-01-01' THEN a.moda_mes END)       AS "Jan/26",
    MAX(CASE WHEN a.mes = '2026-02-01' THEN a.moda_mes END)       AS "Fev/26",
    MAX(CASE WHEN a.mes = '2026-03-01' THEN a.moda_mes END)       AS "Mar/26",
    MAX(CASE WHEN a.mes = '2025-01-01' THEN a.total_metragem END) AS "Met Jan/25",
    MAX(CASE WHEN a.mes = '2025-02-01' THEN a.total_metragem END) AS "Met Fev/25",
    MAX(CASE WHEN a.mes = '2025-03-01' THEN a.total_metragem END) AS "Met Mar/25",
    MAX(CASE WHEN a.mes = '2025-04-01' THEN a.total_metragem END) AS "Met Abr/25",
    MAX(CASE WHEN a.mes = '2025-05-01' THEN a.total_metragem END) AS "Met Mai/25",
    MAX(CASE WHEN a.mes = '2025-06-01' THEN a.total_metragem END) AS "Met Jun/25",
    MAX(CASE WHEN a.mes = '2025-07-01' THEN a.total_metragem END) AS "Met Jul/25",
    MAX(CASE WHEN a.mes = '2025-08-01' THEN a.total_metragem END) AS "Met Ago/25",
    MAX(CASE WHEN a.mes = '2025-09-01' THEN a.total_metragem END) AS "Met Set/25",
    MAX(CASE WHEN a.mes = '2025-10-01' THEN a.total_metragem END) AS "Met Out/25",
    MAX(CASE WHEN a.mes = '2025-11-01' THEN a.total_metragem END) AS "Met Nov/25",
    MAX(CASE WHEN a.mes = '2025-12-01' THEN a.total_metragem END) AS "Met Dez/25",
    MAX(CASE WHEN a.mes = '2026-01-01' THEN a.total_metragem END) AS "Met Jan/26",
    MAX(CASE WHEN a.mes = '2026-02-01' THEN a.total_metragem END) AS "Met Fev/26",
    MAX(CASE WHEN a.mes = '2026-03-01' THEN a.total_metragem END) AS "Met Mar/26",
    MAX(CASE WHEN a.mes = '2025-01-01' THEN a.total_valor END)    AS "Val Jan/25",
    MAX(CASE WHEN a.mes = '2025-02-01' THEN a.total_valor END)    AS "Val Fev/25",
    MAX(CASE WHEN a.mes = '2025-03-01' THEN a.total_valor END)    AS "Val Mar/25",
    MAX(CASE WHEN a.mes = '2025-04-01' THEN a.total_valor END)    AS "Val Abr/25",
    MAX(CASE WHEN a.mes = '2025-05-01' THEN a.total_valor END)    AS "Val Mai/25",
    MAX(CASE WHEN a.mes = '2025-06-01' THEN a.total_valor END)    AS "Val Jun/25",
    MAX(CASE WHEN a.mes = '2025-07-01' THEN a.total_valor END)    AS "Val Jul/25",
    MAX(CASE WHEN a.mes = '2025-08-01' THEN a.total_valor END)    AS "Val Ago/25",
    MAX(CASE WHEN a.mes = '2025-09-01' THEN a.total_valor END)    AS "Val Set/25",
    MAX(CASE WHEN a.mes = '2025-10-01' THEN a.total_valor END)    AS "Val Out/25",
    MAX(CASE WHEN a.mes = '2025-11-01' THEN a.total_valor END)    AS "Val Nov/25",
    MAX(CASE WHEN a.mes = '2025-12-01' THEN a.total_valor END)    AS "Val Dez/25",
    MAX(CASE WHEN a.mes = '2026-01-01' THEN a.total_valor END)    AS "Val Jan/26",
    MAX(CASE WHEN a.mes = '2026-02-01' THEN a.total_valor END)    AS "Val Fev/26",
    MAX(CASE WHEN a.mes = '2026-03-01' THEN a.total_valor END)    AS "Val Mar/26"
FROM base b
JOIN moda_geral mg ON mg.cod_produto = b.cod_produto AND mg.unidade = b.unidade
JOIN agregado a    ON a.cod_produto  = b.cod_produto AND a.unidade  = b.unidade
GROUP BY
    b.tipo_unidade, b.unidade, b.cod_produto, b.nome_produto,
    b.categoria_produto, b.classe_produto, b.sub_classe_produto,
    mg.moda_preco_m2