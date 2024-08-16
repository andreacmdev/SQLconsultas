SELECT *,
    ROUND(ValorUnitarioTotalComDesconto, 2) AS valorFinal
FROM (
    SELECT 
        %(Tipo_Unidade)s AS Tipo_Unidade,
        %(Unidade)s AS Unidade,
        itensPedido.NU_PVE AS CodPedido,
        itensPedido.NU_DPV AS CodItem,
        itensPedido.NU_CLI AS CodCliente,
        clientes.DS_CLI AS NomeCliente,
        itensPedido.DT_PVE AS DataPedido,
        CASE itensPedido.ID_STATUS 
            WHEN 1 THEN 'Aberto' 
            WHEN 2 THEN 'Em Separacao' 
            WHEN 4 THEN 'Finalizado' 
            WHEN 6 THEN 'Cancelado' 
            WHEN 8 THEN 'Em Producao'
            WHEN 9 THEN 'Pend. Liberacao Financeira'
            ELSE 'Orcamento' 
        END AS StatusPedido,
        itensPedido.VLR_TOT_PVE AS ValorTotalPedido,
        itensPedido.VLR_DESC AS ValorDesconto,
        itensPedido.alq_DESC AS PercentualDesconto,
        itensPedido.vlr_acresc AS ValorAcrescimo,
        itensPedido.alq_ACRESC AS PercentualAcrescimo,
        itensPedido.VLR_FINAL AS ValorFinalPedido,
        CASE itensPedido.ID_TP_PED 
            WHEN 1 THEN 'Serie' 
            WHEN 2 THEN 'Engenharia' 
            WHEN 3 THEN 'Serviço'
        END AS TipoPedido,
        itensPedido.DT_PREVENT AS PrevisaoEntrega,
        rota.ds_rot AS RotaEntrega,
        coes.DS_OES AS Coes,
        usuarios.NOM_USU AS Vendedor,
        itensPedido.DTHORA_PVE AS DataHoraPedido,
        itensPedido.ID_PRODUZIDO AS PedidoPronto,
        itensPedido.NU_PRO AS CodProduto,
        produtos.DS_PRO AS NomeProduto,
        catProdutos.DS_CAT AS CategoriaProduto,
        classeProdutos.DS_CLP AS ClasseProduto,
        subclasseProdutos.DS_SCP AS SubClasseProduto,
        itensPedido.QT_PRO AS QtdProduto,
        itensPedido.VLR_PRO AS ValorUnitarioProduto,
        itensPedido.vlr_desc/itensPedido.QT_PRO AS ValorDescontoUnitario,
        itensPedido.QT_ALTURA AS MedidaAltura,
        itensPedido.QT_LARGURA AS MedidaLargura,
        itensPedido.qt_metrag AS MetragemUnitaria,
        itensPedido.qt_metragcob AS MetragemCobradaUnitaria,
        itensPedido.MetragemCobrada,
        itensPedido.VLR_PRO_TOT AS ValorUnitarioTotal,
        itensPedido.ValorVendaProdutoComDesconto AS ValorUnitarioComDesconto,
        itensPedido.ValorTotalItemComDesconto + COALESCE(itensPedido.vlr_acresc, 0) AS ValorUnitarioTotalComDesconto,
        itensPedido.NU_CUSTO AS CustoUnitarioProduto,
        (1 - (itensPedido.NU_CUSTO / (((itensPedido.VLR_PRO * (100 - itensPedido.alq_DESC)) / 100))) * 100) AS MargemBrutaProduto,
        itensPedido.ID_PAGO AS PedidoPago,
        itensPedido.NU_PEDCLI AS PedidoCliente,
        itensPedido.Origem,
        itensPedido.DT_ENCER AS DataEncerramento
    FROM (
        SELECT 
            produtos.NU_PRO, produtos.QT_PRO, produtos.VLR_PRO,
            produtos.QT_ALTURA, produtos.QT_LARGURA, produtos.qt_metrag,
            produtos.qt_metragcob, produtos.VLR_PRO_TOT, produtos.VLR_TOTAL,
            produtos.NU_CUSTO, produtos.alq_desc, produtos.vlr_desc,
            produtos.alq_acresc, produtos.vlr_acresc,
            produtos.NU_DPV, produtos.NU_PVE,
            IF (produtos.qt_metragcob > 0,
                (((produtos.VLR_PRO * (100 - COALESCE(produtos.alq_desc, 0)))) / 100) * produtos.qt_metragcob * produtos.qt_pro,
                (((produtos.VLR_PRO * (100 - COALESCE(produtos.alq_desc, 0)))) / 100) * produtos.qt_pro
            ) AS ValorTotalItemComDesconto,
            (((produtos.VLR_PRO * (100 - COALESCE(produtos.alq_desc, 0)))) / 100) AS ValorVendaProdutoComDesconto,
            IF (produtos.qt_metragcob IS NULL,
                pro.FAT_CONV1 * produtos.QT_PRO,
                0
            ) AS MetragemCobrada,
            ped.ID_STATUS,
            ped.NU_CLI,
            ped.DT_PVE,
            ped.VLR_TOT_PVE,
            ped.VLR_FINAL,
            ped.ID_TP_PED,
            ped.DT_PREVENT,
            ped.DTHORA_PVE,
            ped.ID_PRODUZIDO,
            ped.NU_CPG,
            ped.NU_ROT,
            ped.NU_OES,
            ped.COD_USR_INS,
            ped.ID_PAGO,
            ped.NU_PEDCLI,
            origem.DS_ORIGEM AS Origem,
            ped.DT_ENCER
        FROM mgpve01011 produtos 
        INNER JOIN mgpve01010 ped ON (ped.NU_PVE = produtos.NU_PVE AND ped.ID_STATUS = 6 AND DATE(ped.DT_ENCER) BETWEEN '2024-08-13' AND '2024-08-13')
        INNER JOIN mgpro01010 pro ON (pro.NU_PRO = produtos.NU_PRO)
        LEFT JOIN mgpxo01010 origem ON origem.NU_PVE = ped.NU_PVE
    ) itensPedido
    INNER JOIN mgcli01010 clientes ON (clientes.NU_CLI = itensPedido.NU_CLI)
    LEFT JOIN mgecl01010 ecl ON (clientes.NU_CLI = ecl.NU_ECL)
    LEFT JOIN mgcid01010 cid ON (ecl.NU_CID = cid.NU_CID)
    LEFT JOIN mgufe01010 ufe ON (cid.NU_UF = ufe.NU_UF)
    LEFT JOIN mgrot01010 rota ON (rota.NU_ROT = itensPedido.NU_ROT)
    LEFT JOIN mgoes01010 coes ON (coes.nu_oes = itensPedido.NU_OES)
    LEFT JOIN mgusu01010 usuarios ON (usuarios.nu_usu = itensPedido.COD_USR_INS)
    LEFT JOIN mgpro01010 produtos ON (produtos.NU_PRO = itensPedido.NU_PRO)
    LEFT JOIN mgcat01010 catProdutos ON (produtos.NU_CAT = catProdutos.NU_CAT)
    LEFT JOIN mgclp01010 classeProdutos ON (produtos.NU_CLP = classeProdutos.NU_CLP)
    LEFT JOIN mgscp01010 subclasseProdutos ON (produtos.NU_SCP = subclasseProdutos.NU_SCP)
) X;
