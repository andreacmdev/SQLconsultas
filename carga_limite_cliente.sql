WITH ultimas_alteracoes AS (
    SELECT
        al.tipo_unidade,
        al.unidade,
        al.data_alteracao::date,
        al.nome_cliente,
        al.cod_cliente,
        al.limite_boleto,
        al.limite_cartao,
        al.limite_cheque,
        al.limite_cheque_terceiro,
        al.limite_duplicata,
        al.usuario,
        ROW_NUMBER() OVER (PARTITION BY al.cod_cliente ORDER BY al.data_alteracao DESC) AS rn
    FROM alteracao_limites al
)
SELECT
    tipo_unidade,
    unidade,
    data_alteracao,
    nome_cliente,
    cod_cliente,
    limite_boleto,
    limite_cartao,
    limite_cheque,
    limite_cheque_terceiro,
    limite_duplicata,
    usuario
FROM ultimas_alteracoes
WHERE rn = 1
  AND (
      	COALESCE(NULLIF(limite_boleto, '')::numeric, 0) <> 0 OR
        COALESCE(NULLIF(limite_cartao, '')::numeric, 0) <> 0 OR
        COALESCE(NULLIF(limite_cheque, '')::numeric, 0) <> 0 OR
        COALESCE(NULLIF(limite_cheque_terceiro, '')::numeric, 0) <> 0 OR
        COALESCE(NULLIF(limite_duplicata, '')::numeric, 0) <> 0
  )
ORDER BY unidade;