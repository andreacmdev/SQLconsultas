WITH ultimas_alteracoes AS (
    SELECT 
        cod_cliente,
        unidade,
        data_alteracao,
        limite_cheque,
        limite_cheque_terceiro,
        limite_boleto,
        limite_duplicata,
        ROW_NUMBER() OVER (
            PARTITION BY cod_cliente, unidade 
            ORDER BY data_alteracao DESC
        ) AS rn
    FROM 
        alteracao_limites
)
SELECT
    pf.tipo_unidade,
    pf.unidade,
    pf.cod_cliente,
    pf.nome_cliente,
    al.data_alteracao,
    pf.tipo_documento,
    SUM(CAST(REPLACE(pf.valor_titulo, ',', '.') AS NUMERIC)) AS valor_titulo,
    al.limite_cheque,
    al.limite_cheque_terceiro,
    al.limite_boleto,
    al.limite_duplicata,
    mc.ramo_atividade
FROM 
    painel_financeiro pf
LEFT JOIN 
    ultimas_alteracoes al 
    ON pf.cod_cliente = al.cod_cliente 
    AND pf.unidade = al.unidade
    AND al.rn = 1  -- Pega apenas o registro mais recente
LEFT JOIN 
    mapeamento_clientes mc 
    ON pf.cod_cliente = mc.codcliente 
    AND pf.unidade = mc.unidade
WHERE 
    pf.tipo_documento IN ('boleto', 'cheque')
GROUP BY 
    pf.tipo_unidade,
    pf.unidade,
    pf.cod_cliente,
    pf.nome_cliente,
    al.data_alteracao,
    pf.tipo_documento,
    pf.valor_titulo ,
    al.limite_cheque,
    al.limite_cheque_terceiro,
    al.limite_boleto,
    al.limite_duplicata,
    mc.ramo_atividade;