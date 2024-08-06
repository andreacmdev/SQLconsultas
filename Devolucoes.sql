SELECT
    pedidos.Cliente,
    pedidos.DataPedido AS DataPedido,
    devolvidos.Produto,
    devolvidos.DataDevolucao,
    devolvidos.CodPedido,
    devolvidos.CodProduto,
    devolvidos.QtdDevolvida,
    CASE 
        WHEN pedidos.tipo_pedido = '2' THEN CAST(((pedidos.ValorUnitario * devolvidos.MetragemDevolvida) - (pedidos.CustoUnitario * devolvidos.MetragemDevolvida)) AS DECIMAL(18, 2))
        ELSE CAST(((pedidos.ValorUnitario * devolvidos.QtdDevolvida) - (pedidos.CustoUnitario * devolvidos.QtdDevolvida)) AS DECIMAL(18, 2))
    END AS Valor,
    usuarios.NOM_USU AS UsuarioDevolucao,
    motivos.DS_MMV AS MotivoDevolucao,
    CONVERT(od.DS_OBS_DEV USING utf8) AS Observacao -- Garante que o texto seja tratado corretamente
FROM (
    SELECT
        devolvidos.NU_PVE AS CodPedido,
        devolvidos.NU_PRO AS CodProduto,
        pro.DS_PRO AS Produto,
        devolvidos.QT_ALTURA AS Altura,
        devolvidos.QT_LARGURA AS Largura,
        devolvidos.qt_pdv AS QtdDevolvida,
        devolvidos.qt_pdv * (devolvidos.QT_ALTURA / 1000) * (devolvidos.QT_LARGURA / 1000) AS MetragemDevolvida,
        devolvidos.DT_PDV AS DataDevolucao,
        devolvidos.NU_USU,
        devolvidos.NU_MMV,
        devolvidos.NU_OBS_DEV
    FROM mgpve01014 devolvidos
    LEFT JOIN mgpro01010 pro ON pro.NU_PRO = devolvidos.NU_PRO
    GROUP BY
        devolvidos.NU_PVE,
        devolvidos.NU_PRO,
        devolvidos.QT_ALTURA,
        devolvidos.QT_LARGURA,
        devolvidos.qt_pdv,
        devolvidos.DT_PDV
) devolvidos
LEFT JOIN (
    SELECT
        cli.DS_CLI AS Cliente,
        ped.DT_PVE AS DataPedido,
        pro.NU_PVE,
        pro.nu_pro,
        pro.QT_ALTURA,
        pro.QT_LARGURA,
        SUM(pro.QT_PRO) AS qt_pro,
        (((pro.VLR_PRO * (100 - COALESCE(pro.alq_desc + pro.alq_acresc, 0)))) / 100) AS ValorUnitario,
        ped.ID_TP_PED AS tipo_pedido,
        pro.NU_CUSTO AS CustoUnitario
    FROM mgpve01011 pro
    LEFT JOIN mgpve01010 ped ON pro.NU_PVE = ped.NU_PVE
    LEFT JOIN mgcli01010 cli ON cli.NU_CLI = ped.NU_CLI
    GROUP BY
        pro.NU_PVE,
        pro.nu_pro,
        pro.QT_ALTURA,
        pro.QT_LARGURA,
        ped.DT_PVE
) pedidos ON devolvidos.CodPedido = pedidos.NU_PVE AND devolvidos.CodProduto = pedidos.nu_pro AND devolvidos.Altura = COALESCE(pedidos.QT_ALTURA, 0) AND devolvidos.Largura = COALESCE(pedidos.QT_LARGURA, 0)
LEFT JOIN mgusu01010 usuarios ON devolvidos.NU_USU = usuarios.NU_USU
LEFT JOIN mgmmv01010 motivos ON devolvidos.NU_MMV = motivos.NU_MMV
LEFT JOIN obs_devolucao od ON devolvidos.NU_OBS_DEV = od.NU_OBS_DEV
WHERE devolvidos.DataDevolucao BETWEEN '2024-01-01' AND '2024-07-31';