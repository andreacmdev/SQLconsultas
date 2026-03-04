SELECT 
    b.DS_COD_INTERNO AS kit_cod,
    g.DS_COD_INTERNO AS ferragem_cod,
    g.DS_PRO         AS ferragem_desc,
    a.QTDE_KIT       AS qtde_ferragem_por_kit
FROM mgpro01011 a
JOIN mgpro01010 b ON a.NU_PRO = b.NU_PRO    -- KIT
JOIN mgpro01010 g ON a.NU_PRK = g.NU_PRO    -- FERRAGEM
WHERE b.DS_COD_INTERNO LIKE 'KIT%'
