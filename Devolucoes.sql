-- devolvido com custo e lucro perdido
SELECT
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
    pedidos.Cliente,
    pedidos.DataPedido AS DataPedido,
    devolvidos.Produto,
    devolvidos.DataDevolucao,
    CONVERT(devolvidos.CodPedido, CHAR) AS CodPedido,
    CONVERT(devolvidos.CodProduto, CHAR) AS CodProduto,
    devolvidos.QtdDevolvida,
    CASE 
        WHEN pedidos.tipo_pedido = '2' THEN FORMAT((pedidos.ValorUnitario * devolvidos.MetragemDevolvida)- (pedidos.CustoUnitario * devolvidos.MetragemDevolvida), 2, 'de_DE')
        ELSE FORMAT((pedidos.ValorUnitario * devolvidos.QtdDevolvida) - (pedidos.CustoUnitario * devolvidos.QtdDevolvida), 2, 'de_DE')
    END AS ValorDevolvidoLucro,
    CASE 
        WHEN pedidos.tipo_pedido = '2' THEN FORMAT((pedidos.ValorUnitario * devolvidos.MetragemDevolvida), 2, 'de_DE')
        ELSE FORMAT((pedidos.ValorUnitario * devolvidos.QtdDevolvida) , 2, 'de_DE')
    END AS ValorDevolvidoVenda,
    CASE 
        WHEN pedidos.tipo_pedido = '2' THEN FORMAT((pedidos.CustoUnitario * devolvidos.MetragemDevolvida), 2, 'de_DE')
        ELSE FORMAT((pedidos.CustoUnitario * devolvidos.QtdDevolvida), 2, 'de_DE')
    END AS ValorDevolvidoCusto,
    pedidos.VLR_FINAL as ValorFinalPedido, -- Adicionada a coluna VLR_FINAL aqui
    usuarios.NOM_USU AS UsuarioDevolucao,
    motivos.DS_MMV AS MotivoDevolucao,
    od.DS_OBS_DEV AS Observacao,
    CASE 
        WHEN pedidos.tipo_pedido = '1' THEN 'Serie' 
        WHEN pedidos.tipo_pedido = '2' THEN 'Engenharia' 
        WHEN pedidos.tipo_pedido = '3' THEN 'Serviço' 
        ELSE 'Desconhecido'
    END AS TipoPedido
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
        ped.VLR_FINAL, -- Selecionada a coluna VLR_FINAL aqui
        pro.NU_CUSTO AS CustoUnitario
    FROM mgpve01011 pro
    LEFT JOIN mgpve01010 ped ON pro.NU_PVE = ped.NU_PVE
    LEFT JOIN mgcli01010 cli ON cli.NU_CLI = ped.NU_CLI
    GROUP BY
        pro.NU_PVE,
        pro.nu_pro,
        pro.QT_ALTURA,
        pro.QT_LARGURA,
        ped.DT_PVE,
        ped.VLR_FINAL -- Adicionada a coluna VLR_FINAL ao GROUP BY
) pedidos ON devolvidos.CodPedido = pedidos.NU_PVE AND devolvidos.CodProduto = pedidos.nu_pro AND devolvidos.Altura = COALESCE(pedidos.QT_ALTURA, 0) AND devolvidos.Largura = COALESCE(pedidos.QT_LARGURA, 0)
LEFT JOIN mgusu01010 usuarios ON devolvidos.NU_USU = usuarios.NU_USU
LEFT JOIN mgmmv01010 motivos ON devolvidos.NU_MMV = motivos.NU_MMV
LEFT JOIN obs_devolucao od ON devolvidos.NU_OBS_DEV = od.NU_OBS_DEV
WHERE devolvidos.DataDevolucao BETWEEN '2024-08-01' and '2024-10-31'