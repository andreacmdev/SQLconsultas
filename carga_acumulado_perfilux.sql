WITH total_descontos AS (
    SELECT 
        p.unidade,
        SUM(REPLACE(p.valor_desconto, ',', '.')::numeric) AS total_desconto_mes
    FROM 
        pedidos p
    WHERE 
        p.unidade = 'PERFILUX'
        AND p.valor_desconto ~ '^[0-9]+([,.][0-9]+)?$'
        AND date_trunc('month', p.data_pedido) = date_trunc('month', CURRENT_DATE)
    GROUP BY 
        p.unidade
),
total_lucros_devolvidos AS (
    SELECT 
        dd.unidade,
       ROUND(SUM(dd.lucrodevolvido), 2) AS total_lucro_devolvido_mes
    FROM 
        dre_devolucoes dd
    WHERE 
        dd.unidade = 'PERFILUX'
        AND dd.lucrodevolvido > 0
        AND date_trunc('month', dd.data_devolucao) = date_trunc('month', CURRENT_DATE)
    GROUP BY 
        dd.unidade
)
SELECT 
    COALESCE(d.unidade, l.unidade) AS unidade,
    COALESCE(d.total_desconto_mes, 0) AS total_desconto_mes,
    COALESCE(l.total_lucro_devolvido_mes, 0) AS total_lucro_devolvido_mes
FROM 
    total_descontos d
FULL OUTER JOIN total_lucros_devolvidos l ON d.unidade = l.unidade;