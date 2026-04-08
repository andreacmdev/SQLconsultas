SELECT
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,  
    m.NU_PCO                                    AS cod_pedido_compra,
    REPLACE(UPPER(TRIM(m.NU_NF)), 'ROM', '')    AS cod_romaneio,
    m.NU_NF                                     AS nu_nf_original,
    m3.DS_FOR                                   AS fornecedor,
    m3.NU_FOR                                   AS cod_fornecedor,
    m.DS_PRO_FORNEC                             AS descricao_produto,
    ROUND(m.QTDE_PCO)                           AS qtd_produto,
    m.NU_PRO                                    AS cod_produto,
    n.DT_ENTREGA                                AS data_recebimento_loja,
    CASE
        WHEN m.QT_METRAG_COB = 0
        THEN ROUND(m.QTDE_PCO * m.VLR_PCO, 2)
        ELSE ROUND(m.VLR_PCO * m.QT_METRAG_COB, 2)
    END AS valor_recebido,
    m.QT_ALTURA,
    m.QT_LARGURA,
    m.QT_METRAG_COB                             AS metragem_cobrada,
    cat.DS_CAT                                  AS categoria_produto
FROM mgpco01013 m
LEFT JOIN mgpco01012 n
    ON m.NU_NFP = n.NU_NFP
JOIN mgpco01011 p
    ON m.NU_DPC = p.NU_DPC
JOIN mgpco01010 m2
    ON m.NU_PCO = m2.NU_PCO
JOIN mgfor01010 m3
    ON m2.NU_FOR = m3.NU_FOR
LEFT JOIN mgpro01010 pro
    ON m.NU_PRO = pro.NU_PRO
LEFT JOIN mgcat01010 cat
    ON pro.NU_CAT = cat.NU_CAT
WHERE
    n.DT_ENTREGA >= '2026-01-01'
    AND cat.DS_CAT LIKE '%TEMPERADO%'
    AND n.DT_ENTREGA <= CURDATE()
    AND (
        m.NU_NF LIKE 'ROM%'
        OR m.NU_NF REGEXP '^[0-9]+$'
    )