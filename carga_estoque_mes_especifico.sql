WITH estoque_filtrado AS (
    SELECT 
        ep.unidade,
        ep.categoria,
        ep.nome_produto,
        CAST(REPLACE(ep.saldo_dia, ',', '.') AS NUMERIC) AS saldo_estoque,
        CAST(REPLACE(ep.custo_unitario, ',', '.') AS NUMERIC) AS custo_unitario,
        ROW_NUMBER() OVER (
            PARTITION BY ep.unidade, ep.nome_produto 
            ORDER BY ep.data_movimentacao DESC
        ) AS rn
    FROM estoque_produtos ep
    WHERE ep.unidade = 'GM FORTALEZA'
    AND ep.data_movimentacao <= '2025-02-01'
)
SELECT 
    ef.unidade,
    ef.categoria,
    SUM(ef.saldo_estoque) AS total_saldo_estoque,
    AVG(ef.custo_unitario) AS media_custo_unitario, -- Média do custo unitário por categoria
    SUM(ef.saldo_estoque * ef.custo_unitario) AS total_valor_estoque
FROM estoque_filtrado ef
WHERE ef.rn = 1
GROUP BY ef.unidade, ef.categoria;