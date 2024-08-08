-- movimentação avulsa
SELECT 
    ma.tipo_unidade,
    ma.unidade,
    ma.motivo,
    ma.descricao,
    ma.usuario,
    ma.tipo,
    ma.quantidade,
    REPLACE(CAST(REPLACE(ma.valor, ',', '.') AS NUMERIC)::TEXT, '.', ',') AS valor,
    DATE(ma.data_movimentacao::timestamp) AS data_movimentacao,
    ma.produto
FROM 
    movimentacoes_avulsas ma 
WHERE
    DATE(ma.data_movimentacao::timestamp) BETWEEN '2024-07-15' AND '2024-07-19'
    and ma.unidade = 'Agreste Vidros'