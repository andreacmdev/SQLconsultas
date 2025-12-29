WITH base AS (
    SELECT 
        tipo_unidade,
        unidade,
        categoria,
        nome_produto,
        cod_produto,
        classe,
        subclasse,
        fator_conversao,
        NULLIF(REPLACE(custo_unitario, ',', '.'), '')::numeric AS custo_unitario,
        NULLIF(REPLACE(qtd_movimentacao, ',', '.'), '')::numeric AS qtd_movimentacao,
        (
            SELECT SUM(m[1]::numeric)
            FROM regexp_matches(subclasse, '([0-9]+)', 'g') AS m
        ) AS espessura_mm
    FROM estoque_produtos ep
    WHERE 
        data_movimentacao::date >= '2025-01-01'
        AND categoria ILIKE '%chaparia%'
        AND tipo_movimentacao = 'COMPRA'
)
SELECT 
    tipo_unidade,
    unidade,
    categoria,
    nome_produto,
    cod_produto,
    classe,
    subclasse,
    MAX(fator_conversao) AS fator_conversao,
    MAX(espessura_mm) AS espessura_mm,
    MAX(custo_unitario) AS custo_unitario_max,
    SUM(qtd_movimentacao) AS qtd_total_movimentada,
    SUM( 2.5 * espessura_mm / 1000 * qtd_movimentacao )
        AS toneladas_vidro
FROM base
GROUP BY 
    tipo_unidade,
    unidade,
    categoria,
    nome_produto,
    cod_produto,
    classe,
    subclasse
ORDER BY 
    tipo_unidade,
    unidade,
    categoria,
    nome_produto;
