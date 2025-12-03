WITH 
meses_ref AS (
    SELECT 
        TO_CHAR(DATE_TRUNC('month', CURRENT_DATE - INTERVAL '3 month'), 'YYYY-MM') AS mes1_ref, -- JULHO
        TO_CHAR(DATE_TRUNC('month', CURRENT_DATE - INTERVAL '2 month'), 'YYYY-MM') AS mes2_ref, -- AGOSTO
        TO_CHAR(DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month'), 'YYYY-MM') AS mes3_ref, -- SETEMBRO
        TO_CHAR(DATE_TRUNC('month', CURRENT_DATE - INTERVAL '3 month'), 'TMMonth/YYYY') AS mes1_nome,
        TO_CHAR(DATE_TRUNC('month', CURRENT_DATE - INTERVAL '2 month'), 'TMMonth/YYYY') AS mes2_nome,
        TO_CHAR(DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month'), 'TMMonth/YYYY') AS mes3_nome
),

-- 1) Vendas mensais por unidade e categoria (TEMPERADO unificado e BOX)
vendas_categorizadas AS (
    SELECT 
        p.unidade,
        CASE 
            WHEN p.categoria_produto IN ('TEMPERADO', 'TEMPERADO ESPECIAL') THEN 'TEMPERADO'
            WHEN p.categoria_produto ILIKE '%BOX%' THEN 'BOX'
            ELSE NULL
        END AS categoria_agrupada,
        TO_CHAR(p.data_pedido, 'YYYY-MM') AS mes_referencia,
        ROUND(SUM(p.valor_unitario_total_com_desconto::numeric), 2) AS valor_final_vendido
    FROM pedidos p
    WHERE 
        p.unidade IN ('Alumiaco Recife', 'GM Recife', 'OLINDA', 'Agreste Vidros', 'DVM PARAIBA')
        AND p.data_pedido >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '3 month')  -- Julho em diante
        AND p.data_pedido < DATE_TRUNC('month', CURRENT_DATE)                        -- até final de Setembro
    GROUP BY 
        p.unidade, categoria_agrupada, TO_CHAR(p.data_pedido, 'YYYY-MM')
),

-- 2) Vendas mensais TOTAL por unidade (todas as categorias)
vendas_total AS (
    SELECT 
        p.unidade,
        'TOTAL' AS categoria_agrupada,
        TO_CHAR(p.data_pedido, 'YYYY-MM') AS mes_referencia,
        ROUND(SUM(p.valor_unitario_total_com_desconto::numeric), 2) AS valor_final_vendido
    FROM pedidos p
    WHERE 
        p.unidade IN ('Alumiaco Recife', 'GM Recife', 'OLINDA', 'Agreste Vidros', 'DVM PARAIBA')
        AND p.data_pedido >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '3 month')  -- Julho
        AND p.data_pedido < DATE_TRUNC('month', CURRENT_DATE)                        -- Setembro
    GROUP BY 
        p.unidade, TO_CHAR(p.data_pedido, 'YYYY-MM')
),

-- 3) União das linhas (categorias + total)
vendas_unidas AS (
    SELECT * FROM vendas_categorizadas WHERE categoria_agrupada IN ('TEMPERADO','BOX')
    UNION ALL
    SELECT * FROM vendas_total
)

-- 4) Pivot final (3 meses + média)
SELECT
    v.unidade,
    v.categoria_agrupada,
    ROUND(COALESCE(SUM(CASE WHEN v.mes_referencia = m.mes1_ref THEN v.valor_final_vendido END), 0), 2) AS "Mes_1",
    ROUND(COALESCE(SUM(CASE WHEN v.mes_referencia = m.mes2_ref THEN v.valor_final_vendido END), 0), 2) AS "Mes_2",
    ROUND(COALESCE(SUM(CASE WHEN v.mes_referencia = m.mes3_ref THEN v.valor_final_vendido END), 0), 2) AS "Mes_3",
    ROUND((
        COALESCE(SUM(CASE WHEN v.mes_referencia = m.mes1_ref THEN v.valor_final_vendido END), 0) +
        COALESCE(SUM(CASE WHEN v.mes_referencia = m.mes2_ref THEN v.valor_final_vendido END), 0) +
        COALESCE(SUM(CASE WHEN v.mes_referencia = m.mes3_ref THEN v.valor_final_vendido END), 0)
    ) / 3, 2) AS "Media_3_Meses",
    m.mes1_nome AS "Mes_1_Label",
    m.mes2_nome AS "Mes_2_Label",
    m.mes3_nome AS "Mes_3_Label"
FROM vendas_unidas v
CROSS JOIN meses_ref m
GROUP BY 
    v.unidade, v.categoria_agrupada,
    m.mes1_ref, m.mes2_ref, m.mes3_ref,
    m.mes1_nome, m.mes2_nome, m.mes3_nome
ORDER BY v.unidade,
         CASE 
            WHEN v.categoria_agrupada = 'TEMPERADO' THEN 1
            WHEN v.categoria_agrupada = 'BOX' THEN 2
            WHEN v.categoria_agrupada = 'TOTAL' THEN 3
            ELSE 4
         END;