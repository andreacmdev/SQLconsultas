-- script BI Estoque

WITH cte_datas_base AS (
    SELECT 
        GENERATE_SERIES(
            DATE '2024-01-01', 
            DATE_TRUNC('month', CURRENT_DATE), 
            INTERVAL '1 month'
        )::DATE AS data_base
),
cte_ultima_movimentacao_mes AS (
    SELECT
        ep.tipo_unidade,
        ep.unidade,
        ep.cod_produto,
        d.data_base,
        MAX(ep.data_movimentacao::timestamp) AS ultima_data 
    FROM
        cte_datas_base d
    LEFT JOIN estoque_produtos ep
        ON ep.data_movimentacao::timestamp <= (d.data_base + INTERVAL '1 month' - INTERVAL '1 day') 
    WHERE 
        ep.unidade IN (
    'Oazem',
    'INBRAVIDROS',
    '4D Vidros',
    'BRASILIA',
    'FORTALEZA',
    'VITORIA DE SANTO ANTAO',
    'ALLGLASS TEMPERA',
    'TEMPER PATOS',
    'Alumiaco Recife',
    'GM Recife',
    'Agreste Vidros',
    'GM Salvador',
    'GM Maceio',
    'IDVIDROS',
    'PERFILUX',
    'OLINDA',
    'IRECE',
    'ARAPIRACA',
    'BARROSREIS',
    'GMFEIRA',
    'GM JUAZEIRO',
    'SOBRAL',
    'GM FORTALEZA',
    'DVM PARAIBA',
    'BELGA POLIMEROS',
    'ALLGLASS LOJA',
    'GM FORTALEZA FILIAL',
    'GM MONTESE',
    'CD VIDROS',
    'CD ALUMINIO',
    'PONTO VIDRO',
    'BFVIDROS',
    'CAMACARI',
    'PICOS',
    'RPVDIROS',
    'CAPIMGROSSO',
    'RNVIDROS',
    'GRAVATA',
    'BELO JARDIM',
    'ALAGOINHA',
    'ARCOVERDE',
    'IGARASSU',
    'SALGUEIRO',
    'MANDACARU',
    'ARENAVIDROS',
    'CRUZ DAS ALMAS',
    'ITAPIPOCA',
    'DELMIRO GOUVEIA',
    'SANTA CRUZ',
    'GOIANA',
    'TIANGUA',
    'CABO VIDROS'
)
    GROUP BY
        ep.tipo_unidade, ep.unidade, ep.cod_produto, d.data_base
),
cte_saldos_completos AS (
    SELECT
        u.tipo_unidade
        u.unidade,
        u.cod_produto,
        u.data_base,
        ep.nome_produto,
        ep.categoria,
        ep.classe,
        ep.subclasse,
        ep.saldo_dia AS ultimo_saldo_dia,
        ep.custo_unitario, 
        u.ultima_data
    FROM
        cte_ultima_movimentacao_mes u
    LEFT JOIN estoque_produtos ep
        ON ep.unidade = u.unidade
        AND ep.cod_produto = u.cod_produto
        AND ep.data_movimentacao::timestamp = u.ultima_data
),
cte_preenchimento_ausencias AS (
    SELECT
        tipo_unidade,
        unidade,
        cod_produto,
        data_base,
        nome_produto,
        categoria,
        classe,
        subclasse,
        ultimo_saldo_dia,
        custo_unitario,
        ultima_data,
        COALESCE(
            ultimo_saldo_dia, 
            LAG(ultimo_saldo_dia) OVER (PARTITION BY unidade, cod_produto ORDER BY data_base)
        ) AS saldo_ajustado,
        COALESCE(
            custo_unitario, 
            LAG(custo_unitario) OVER (PARTITION BY unidade, cod_produto ORDER BY data_base)
        ) AS custo_unitario_ajustado
    FROM
        cte_saldos_completos
)
SELECT
    tipo_unidade,
    unidade,
    cod_produto,
    nome_produto,
    categoria,
    classe,
    subclasse,
    data_base + INTERVAL '1 month' AS data_referencia,
    saldo_ajustado AS saldo_dia,
    custo_unitario_ajustado AS custo_unitario,
    ROUND(
        CAST(REPLACE(saldo_ajustado, ',', '.') AS NUMERIC) * 
        CAST(REPLACE(custo_unitario_ajustado, ',', '.') AS NUMERIC),
        2
    ) AS custo_total
FROM
    cte_preenchimento_ausencias
WHERE
    data_base <= CURRENT_DATE
ORDER BY
    cod_produto,
    data_referencia;







-------------------------------------------------------------------------------------------------

WITH estoque_filtrado AS (
    SELECT
        tipo_unidade,
        unidade,
        cod_produto,
        nome_produto,
        categoria,
        classe,
        subclasse,
        TO_CHAR(TO_DATE(data_movimentacao, 'YYYY-MM-DD'), 'YYYY-MM') AS mes_movimentacao,
        CAST(REPLACE(estoque_atual, ',', '.') AS NUMERIC) AS estoque_numerico
    FROM
        estoque_produtos
    WHERE
        TO_DATE(data_movimentacao, 'YYYY-MM-DD') >= DATE '2024-03-01' AND unidade IN (
    'Oazem',
    'INBRAVIDROS',
    '4D Vidros',
    'BRASILIA',
    'FORTALEZA',
    'VITORIA DE SANTO ANTAO',
    'ALLGLASS TEMPERA',
    'TEMPER PATOS',
    'Alumiaco Recife',
    'GM Recife',
    'Agreste Vidros',
    'GM Salvador',
    'GM Maceio',
    'IDVIDROS',
    'PERFILUX',
    'OLINDA',
    'IRECE',
    'ARAPIRACA',
    'BARROSREIS',
    'GMFEIRA',
    'GM JUAZEIRO',
    'SOBRAL',
    'GM FORTALEZA',
    'DVM PARAIBA',
    'BELGA POLIMEROS',
    'ALLGLASS LOJA',
    'GM FORTALEZA FILIAL',
    'GM MONTESE',
    'CD VIDROS',
    'CD ALUMINIO',
    'PONTO VIDRO',
    'BFVIDROS',
    'CAMACARI',
    'PICOS',
    'RPVDIROS',
    'CAPIMGROSSO',
    'RNVIDROS',
    'GRAVATA',
    'BELO JARDIM',
    'ALAGOINHA',
    'ARCOVERDE',
    'IGARASSU',
    'SALGUEIRO',
    'MANDACARU',
    'ARENAVIDROS',
    'CRUZ DAS ALMAS',
    'ITAPIPOCA',
    'DELMIRO GOUVEIA',
    'SANTA CRUZ',
    'GOIANA',
    'ALAGOAS VIDROS',
    'CABO VIDROS')
),
meses_zerados_por_produto AS (
    SELECT
        tipo_unidade,
        unidade,
        cod_produto,
        -- Lista distinta dos meses em que o estoque foi zero
        ARRAY_AGG(DISTINCT mes_movimentacao ORDER BY mes_movimentacao)
            FILTER (WHERE estoque_numerico = 0) AS meses_estoque_zero
    FROM
        estoque_filtrado
    GROUP BY
        tipo_unidade,
        unidade,
        cod_produto
),
produtos_distintos AS (
    SELECT DISTINCT
        tipo_unidade,
        unidade,
        cod_produto,
        nome_produto,
        categoria,
        classe,
        subclasse
    FROM
        estoque_produtos
)
SELECT
    pd.tipo_unidade,
    pd.unidade,
    pd.cod_produto,
    pd.nome_produto,
    pd.categoria,
    pd.classe,
    pd.subclasse,
    COALESCE(ARRAY_TO_STRING(mz.meses_estoque_zero, ', '), '') AS meses_estoque_zero
FROM
    produtos_distintos pd
LEFT JOIN
    meses_zerados_por_produto mz
    ON pd.tipo_unidade = mz.tipo_unidade
    AND pd.unidade = mz.unidade
    AND pd.cod_produto = mz.cod_produto
ORDER BY
    pd.tipo_unidade,
    pd.unidade,
    pd.cod_produto