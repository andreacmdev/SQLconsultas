SELECT DISTINCT
    pai.DS_COD_INTERNO AS produto_pai,   -- pode ser KIT ou ferragem
    pai.DS_PRO         AS desc_pai,
    fil.DS_COD_INTERNO AS componente,    -- ferragem ou MP
    fil.DS_PRO         AS desc_componente,
    h.DS_CUM           AS unidade_mp,
    rel.QTDE_KIT       AS qt_relacao     -- qt usada dentro do pai
FROM mgpro01011 rel
JOIN mgpro01010 pai ON rel.NU_PRO = pai.NU_PRO
JOIN mgpro01010 fil ON rel.NU_PRK = fil.NU_PRO
LEFT JOIN mgcum01010 h ON fil.NU_CUM = h.NU_CUM
WHERE pai.ID_ATIVO = 'S'
