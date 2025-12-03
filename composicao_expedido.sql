/* ==========================================================
   BASE FINAL DE CONSUMO (com data_entrega, custo e preço)
   ========================================================== */

SELECT
    p.cod_pedido,
    p.data_pedido,
    p.data_entrega,
    p.vlr_tot_pve,
    p.cod_interno_vendido AS produto_vendido,   -- ✅ correção aqui
    p.desc_vendido,
    p.qtde_produto,
    p.custo_unit,
    p.precovenda,
    (p.custo_unit * p.qtde_produto) AS custo_total,
    hier.ferragem,
    hier.desc_ferragem,
    hier.cod_mp           AS componente_final,
    hier.desc_mp,
    hier.unid,
    hier.qt_ferr          AS qt_ferragem_no_produto,
    hier.qt_mp            AS qt_mp_na_ferragem,
    /* consumo final = qtd vendida × ferragens por produto × MP por ferragem */
    (p.qtde_produto * hier.qt_ferr * hier.qt_mp) AS qt_consumo_total
FROM
(
    /* ------------------- PEDIDOS EXPEDIDOS ------------------- */
    SELECT
        pe.NU_PVE         AS cod_pedido,
        pr.DS_COD_INTERNO AS cod_interno_vendido,
        pr.DS_PRO         AS desc_vendido,
        it.QT_PRO         AS qtde_produto,
        pe.DT_PVE         AS data_pedido,
        rom.data_entrega  AS data_entrega,
        pr.NU_CUSTO       AS custo_unit,
        pr.NU_PRECOV      AS precovenda,
        pe.VLR_TOT_PVE
    FROM mgpve01010 pe
    JOIN mgpve01011 it  ON pe.NU_PVE = it.NU_PVE
    JOIN mgpro01010 pr  ON it.NU_PRO = pr.NU_PRO
    /* Subquery de entrega única por pedido */
    LEFT JOIN (
        SELECT 
            r11.NU_PVE, 
            MAX(r10.DT_ROM) AS data_entrega
        FROM mgrom01011 r11
        JOIN mgrom01010 r10 ON r11.NU_ROM = r10.NU_ROM
        GROUP BY r11.NU_PVE
    ) rom ON rom.NU_PVE = pe.NU_PVE
    WHERE pe.ID_STATUS = '4'
      AND pe.DT_PVE >= '2025-01-01'
) p
/* ------------------- HIERARQUIA COMPLETA (KIT → FERRAGEM → MP) ------------------- */
JOIN
(
    /* === BLOCO 1: FERRAGENS QUE COMPÕEM OS KITS === */
    SELECT
        k.cod_kit AS produto_pai,
        k.ferragem,
        k.desc_ferragem,
        k.qt_ferr,
        mp.cod_mp,
        mp.desc_mp,
        mp.unid,
        mp.qt_mp
    FROM (
        /* Relação KIT → FERRAGEM */
        SELECT DISTINCT
            b.DS_COD_INTERNO AS cod_kit,
            g.DS_COD_INTERNO AS ferragem,
            g.DS_PRO         AS desc_ferragem,
            a.QTDE_KIT       AS qt_ferr
        FROM mgpro01011 a
        JOIN mgpro01010 b ON a.NU_PRO = b.NU_PRO
        JOIN mgpro01010 g ON a.NU_PRK = g.NU_PRO
        WHERE b.DS_COD_INTERNO LIKE 'KIT%'
    ) k
    /* Junta com MPs únicas por ferragem */
    LEFT JOIN (
        SELECT DISTINCT
            b.DS_COD_INTERNO AS ferragem,
            g.DS_COD_INTERNO AS cod_mp,
            g.DS_PRO         AS desc_mp,
            h.DS_CUM         AS unid,
            a.QTDE_KIT       AS qt_mp
        FROM mgpro01011 a
        JOIN mgpro01010 b ON a.NU_PRO = b.NU_PRO
        JOIN mgpro01010 g ON a.NU_PRK = g.NU_PRO
        LEFT JOIN mgcum01010 h ON g.NU_CUM = h.NU_CUM
        WHERE b.DS_COD_INTERNO NOT LIKE 'KIT%'
    ) mp ON mp.ferragem = k.ferragem
    UNION ALL
    /* === BLOCO 2: FERRAGENS VENDIDAS DIRETAMENTE === */
    SELECT
        ferr.cod_pai AS produto_pai,
        ferr.ferragem,
        ferr.desc_ferragem,
        1 AS qt_ferr,
        mp.cod_mp,
        mp.desc_mp,
        mp.unid,
        mp.qt_mp
    FROM (
        SELECT DISTINCT
            b.DS_COD_INTERNO AS cod_pai,
            b.DS_COD_INTERNO AS ferragem,
            b.DS_PRO         AS desc_ferragem
        FROM mgpro01010 b
        WHERE b.DS_COD_INTERNO NOT LIKE 'KIT%'
          AND b.DS_COD_INTERNO NOT IN (
              SELECT DISTINCT g.DS_COD_INTERNO
              FROM mgpro01011 a
              JOIN mgpro01010 b2 ON a.NU_PRO = b2.NU_PRO
              JOIN mgpro01010 g  ON a.NU_PRK = g.NU_PRO
              WHERE b2.DS_COD_INTERNO LIKE 'KIT%'
          )
    ) ferr
    LEFT JOIN (
        SELECT DISTINCT
            b.DS_COD_INTERNO AS ferragem,
            g.DS_COD_INTERNO AS cod_mp,
            g.DS_PRO         AS desc_mp,
            h.DS_CUM         AS unid,
            a.QTDE_KIT       AS qt_mp
        FROM mgpro01011 a
        JOIN mgpro01010 b ON a.NU_PRO = b.NU_PRO
        JOIN mgpro01010 g ON a.NU_PRK = g.NU_PRO
        LEFT JOIN mgcum01010 h ON g.NU_CUM = h.NU_CUM
    ) mp ON mp.ferragem = ferr.ferragem
) hier
  ON hier.produto_pai = p.cod_interno_vendido
ORDER BY
    p.cod_pedido,
    p.cod_interno_vendido,
    hier.ferragem,
    hier.cod_mp;