SELECT
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
    m.NU_PCO,
    m3.ds_for AS fornecedor,
    m.DS_PRO_FORNEC AS descricao_produto,
    m3.NU_FOR,
    ROUND(m.QTDE_PCO) AS qtd_produto,
    REPLACE(ROUND(m.VLR_PCO, 2), '.', ',') AS valor_produto,
    m.NU_NF AS numero_nf_ROM,
    n.DT_ENTREGA AS data_entrega,
    n.NU_NF AS numero_nf_nfp,
    m.QT_ALTURA,
    m.QT_LARGURA,
    m.QT_METRAG_COB,
    CASE 
        WHEN m.QT_METRAG_COB = 0 
        THEN REPLACE(ROUND(m.QTDE_PCO * m.VLR_PCO, 2), '.', ',') 
        ELSE REPLACE(ROUND(m.VLR_PCO * m.QT_METRAG_COB, 2), '.', ',')
    END AS valor_recebido,
    CASE 
        WHEN m.QT_METRAG_COB = 0 
        THEN REPLACE(ROUND(m.QTDE_PCO * m.VLR_PCO, 2), '.', ',') 
        ELSE NULL
    END AS valor_recebido_qtde,
    CASE 
        WHEN m.QT_METRAG_COB != 0 
        THEN REPLACE(ROUND(m.VLR_PCO * m.QT_METRAG_COB, 2), '.', ',')
        ELSE NULL 
    END AS valor_recebido_metragem
FROM
    mgpco01013 m
LEFT JOIN
    mgpco01012 n ON m.NU_NFP = n.NU_NFP
JOIN
    mgpco01011 p ON m.NU_DPC = p.NU_DPC
JOIN
    mgpco01010 m2 ON m.NU_PCO = m2.NU_PCO
JOIN
    mgfor01010 m3 ON m2.NU_FOR = m3.NU_FOR
WHERE 
    n.DT_ENTREGA BETWEEN CURDATE() - INTERVAL 30 DAY AND CURDATE();

