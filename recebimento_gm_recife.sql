select
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
    m.NU_PCO,
    m.DS_COD_PRO_FORNEC AS cod_fornecedor,
    m.DS_PRO_FORNEC AS descricao_prod,
    SUM(m.QTDE_PCO) AS qtd_produto_total, -- Soma a quantidade total do produto
    ROUND(m.VLR_PCO, 2) AS valor_produto, -- Arredonda o valor do produto para 2 casas decimais
    m.NU_NF AS numero_nf_ROM, -- Número da nota fiscal
    n.DT_ENTREGA AS data_entrega, -- Data de entrega
    n.NU_NF AS numero_nf_nfp, -- Número da nota fiscal da outra tabela
    ROUND(SUM(m.QTDE_PCO * m.VLR_PCO), 2) AS valor_recebido -- Cálculo do valor recebido com arredondamento
FROM
    mgpco01013 m
JOIN
    mgpco01012 n ON m.NU_NFP = n.NU_NFP
JOIN
    mgpco01011 p ON m.NU_DPC = p.NU_DPC
WHERE
    n.DT_ENTREGA BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND CURDATE()
GROUP BY
    m.DS_COD_PRO_FORNEC,
    m.DS_PRO_FORNEC,
    m.VLR_PCO,
    m.NU_NF,
    n.DT_ENTREGA,
    n.NU_NF,
    n.VLR_NF,
    p.DS_PRO_FORNEC,
    p.QTDE_PCO,
    p.VLR_PCO,
    m.NU_PCO;