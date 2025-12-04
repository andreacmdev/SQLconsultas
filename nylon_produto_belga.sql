SELECT 
    p.cod_produto,
    p.desc_produto,
    SUM(p.qt_nylon_total) AS nylon_por_unidade
FROM (
    /* =========================================================
       1) KIT -> FERRAGEM -> MP (NYLON)
       ========================================================= */
    SELECT
        kit.cod_kit       AS cod_produto,
        kit.desc_kit      AS desc_produto,
        (kit.qt_ferr * mp.qt_mp) AS qt_nylon_total
    FROM (
        /* KIT -> Ferragens */
        SELECT 
            pai.DS_COD_INTERNO AS cod_kit,
            pai.DS_PRO         AS desc_kit,
            filho.DS_COD_INTERNO AS ferragem,
            rel.QTDE_KIT         AS qt_ferr
        FROM mgpro01011 rel
        JOIN mgpro01010 pai   ON rel.NU_PRO = pai.NU_PRO
        JOIN mgpro01010 filho ON rel.NU_PRK = filho.NU_PRO
        WHERE pai.DS_COD_INTERNO LIKE 'KIT%'
    ) kit
    JOIN (
        /* Ferragem -> MP (filtrar nylon) */
        SELECT
            pai.DS_COD_INTERNO AS ferragem,
            filho.DS_COD_INTERNO AS cod_mp,
            filho.DS_PRO AS desc_mp,
            rel.QTDE_KIT AS qt_mp
        FROM mgpro01011 rel
        JOIN mgpro01010 pai   ON rel.NU_PRO = pai.NU_PRO
        JOIN mgpro01010 filho ON rel.NU_PRK = filho.NU_PRO
        WHERE filho.DS_PRO LIKE '%NYLON%'
    ) mp ON mp.ferragem = kit.ferragem
    UNION ALL
    /* =========================================================
       2) FERRAGEM -> MP (NYLON)
       ========================================================= */
    SELECT
        ferr.cod_ferragem AS cod_produto,
        ferr.desc_ferragem AS desc_produto,
        mp.qt_mp AS qt_nylon_total
    FROM (
        SELECT 
            pai.DS_COD_INTERNO AS cod_ferragem,
            pai.DS_PRO         AS desc_ferragem
        FROM mgpro01010 pai
        WHERE pai.DS_COD_INTERNO NOT LIKE 'KIT%'
    ) ferr
    JOIN (
        SELECT
            pai.DS_COD_INTERNO AS ferragem,
            rel.QTDE_KIT AS qt_mp,
            filho.DS_PRO AS desc_mp
        FROM mgpro01011 rel
        JOIN mgpro01010 pai   ON rel.NU_PRO = pai.NU_PRO
        JOIN mgpro01010 filho ON rel.NU_PRK = filho.NU_PRO
        WHERE filho.DS_PRO LIKE '%NYLON%'
    ) mp ON mp.ferragem = ferr.cod_ferragem
) p
GROUP BY
    p.cod_produto,
    p.desc_produto
ORDER BY
    p.cod_produto;