SELECT 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade, 
    resumo.DS_OES,
    resumo.DS_CAT,
    resumo.DS_PRO,
    resumo.DS_SCP,
    -- ✅ m2 já numérico
    SUM(resumo.MetragemEntregueSerie) AS m2,
    resumo.ANO,
    resumo.MES
FROM (
    SELECT
        pedidos.DS_OES,
        pedidos.NU_PVE,
        pedidos.DS_CAT,
        itens.peso * itens.QT_PRO AS PesoEntregue,
        itens.qt_metragcob AS MetragemEntregue,
        -- 🔥 AQUI ESTÁ A CORREÇÃO
        CAST(
            CASE 
                WHEN pedidos.tp_prod = 1 
                THEN (pro.qt_altura * pro.qt_largura * itens.QT_PRO) / 1000000
                ELSE itens.qt_metragcob
            END 
        AS DECIMAL(18,4)) AS MetragemEntregueSerie,
        pedidos.tp_prod,
        itens.QT_PRO AS QtdEntregue,
        DATE(rom.DT_ROM) AS DataHoraEntregue,
        pedidos.DS_SCP,
        pedidos.DS_PRO,
        YEAR(rom.DT_ROM) AS ANO,
        MONTH(rom.DT_ROM) AS MES
    FROM mgrom01011 itens
    INNER JOIN mgrom01010 rom 
        ON itens.NU_ROM = rom.NU_ROM                
    INNER JOIN mgpro01010 pro 
        ON pro.NU_PRO = itens.NU_PRO 
    LEFT JOIN (
        SELECT 
            produtos.NU_PVE,
            produtos.NU_DPV,
            subclasse.DS_SCP,
            prod.DS_PRO,
            ROUND(
                IF (
                    produtos.qt_metragcob > 0,
                    (((produtos.VLR_PRO * (100 - COALESCE(produtos.alq_desc,0))) / 100) * produtos.qt_metragcob * produtos.qt_pro),
                    (((produtos.VLR_PRO * (100 - COALESCE(produtos.alq_desc,0))) / 100) * produtos.qt_pro)
                ) / produtos.qt_pro,
            2) AS ValorUnitario,

            ROUND(
                IF (
                    produtos.qt_metragcob > 0,
                    produtos.NU_CUSTO * produtos.qt_metragcob * produtos.qt_pro,
                    produtos.NU_CUSTO * produtos.qt_pro
                ) / produtos.qt_pro,
            2) AS CustoUnitario,
            produtos.alq_acresc,
            prod.TP_PROD,
            (((produtos.VLR_PRO * (100 - COALESCE(produtos.alq_desc,0))) / 100)) AS ValorVendaProdutoComDesconto,
            produtos.NU_CUSTO AS ValorCustoProduto,
            coes.DS_OES,
            categoria.DS_CAT 
        FROM mgpve01011 produtos
        LEFT JOIN mgpve01010 ped 
            ON produtos.NU_PVE = ped.NU_PVE
        LEFT JOIN mgpro01010 prod 
            ON prod.NU_PRO = produtos.NU_PRO
        LEFT JOIN mgoes01010 coes 
            ON coes.NU_OES = ped.NU_OES 
        LEFT JOIN mgcat01010 categoria 
            ON categoria.NU_CAT = prod.NU_CAT 
        LEFT JOIN mgscp01010 subclasse 
            ON prod.NU_SCP = subclasse.NU_SCP
        WHERE ped.ID_STATUS IN (1,2,4,8,9)
          AND ped.DT_PVE >= '2023-06-01'
    ) pedidos 
        ON pedidos.NU_PVE = itens.NU_PVE 
       AND pedidos.NU_DPV = itens.NU_DPV
    LEFT JOIN mgcli01010 cliente 
        ON cliente.NU_CLI = itens.nu_cli
    WHERE rom.ID_TP_ROM = 2 
      -- AND pedidos.DS_CAT LIKE '%CHAPARIA%' 
      AND pedidos.DS_OES NOT LIKE '%REP%' 
      AND pedidos.DS_OES NOT LIKE '%inativo%'
      -- AND pedidos.DS_OES NOT LIKE '%transf%'
      AND pedidos.DS_CAT NOT LIKE '%TEMPER%'
      AND pedidos.DS_CAT NOT LIKE '%BOX%'
      AND rom.DT_ROM >= '2026-01-01'
) resumo
GROUP BY 
    resumo.DS_OES,
    resumo.DS_CAT,
    resumo.DS_SCP,
    resumo.DS_PRO,
    resumo.ANO,
    resumo.MES;
