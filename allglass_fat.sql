SELECT
    concat(CodPedido, CodItem, CodRomaneio) as IdItem
    , CodPedido
    , CodItem
    , CodCliente
    , NomeCliente
    , CondPagamento
    , FormaPagamento
    , DataPedido
    , StatusPedido
    , ValorTotalPedido
    , ValorDesconto
    , PercentualDesconto
    , ValorAcrescimo
    , PercentualAcrescimo
    , ValorFinalPedido
    , TipoPedido
    , PrevisaoEntrega
    , RotaEntrega
    , Coes
    , Representante
    , CodRepresentante
    , DataHoraPedido
    , PedidoPronto
    , CodProduto
    , NomeProduto
    , CategoriaProduto
    , ClasseProduto
    , SubClasseProduto
    , QtdProduto
    , ValorUnitarioProduto
    , MedidaAltura
    , MedidaLargura
    , round(((MedidaAltura/1000) * (MedidaLargura/1000)),2) * QtdProduto as MetragemReal
    , if (MetragemCobradaUnitaria is null,
                pedidos.MetragemCobrada,
                MetragemCobradaUnitaria * QtdProduto    
    ) as MetragemCobrada
    , ValorUnitarioTotal
    , round(ValorUnitarioComDesconto,2) as ValorUnitarioComDesconto
    /* Calculo de Valor do Item do Pedido já com o desconto aplicado*/
    , ValorUnitarioTotalComDesconto
    , CustoUnitarioProduto
    , if (
        TipoProduto = '1',
        CustoUnitarioProduto * QtdProduto,
        CustoUnitarioProduto * QtdProduto * metragemCobradaUnitaria
    ) as CustoUnitarioTotalProduto
    , MargemBrutaProduto
    , TipoProduto
    , CodRomaneio
    , QtdEntregue
    , MetragemEntregue
    , PesoEntregue
    , ValorEntregue
    , DataHoraEntregue
    , ValorPendente
    , ValorPendenteTitulos
    , TitulosPendentesPedido
    , PedidoPago
    , TotalPago
    , TotalDescontoEmTitulo
    , FormaQuitado
    , DataPagamento
    , qtdDevolvida
    , metragemDevolvida
    , VendaDevolvido
    , DataDevolucao
    , EnderecoGPS
    , (
        if (
            pedidos.DataHoraPedido > COALESCE(pedidos.DataHoraEntregue,0),
            if (
                pedidos.DataHoraPedido > COALESCE(pedidos.DataPagamento,0),
                pedidos.DataHoraPedido,
                pedidos.DataPagamento
            ),
            if(
                COALESCE(pedidos.DataDevolucao,0) > pedidos.DataHoraEntregue,
                pedidos.DataDevolucao,
                pedidos.DataHoraEntregue
            )
        )
    ) as lastUpdated
/* #, greatest(COALESCE(CAST(pedidos.DataHoraPedido as DATETIME),0), COALESCE(pedidos.DataHoraEntregue,0), COALESCE(pedidos.DataPagamento)) as lastUpdated */
FROM
(SELECT 
        /* Dados do Pedido */ 
        pedidos.NU_PVE AS CodPedido
        , itensPedido.NU_DPV as CodItem
        , pedidos.NU_CLI AS CodCliente 
        , clientes.DS_CLI AS NomeCliente 
        , condPagamento.DS_CPG AS CondPagamento 
        , FormaPagamento as FormaPagamento
        , pedidos.DT_PVE AS DataPedido 
        /* Conversao de Status do Pedido, de numero para Texto */ 
        , CASE pedidos.ID_STATUS 
            WHEN 1 THEN "Aberto" 
            WHEN 2 THEN "Em Separacao" 
            WHEN 4 THEN "Finalizado" 
            WHEN 6 THEN "Cancelado" 
            WHEN 8 THEN "Em Producao" 
            ELSE "Orcamento" 
        END AS StatusPedido 
        /* Valores do Pedido */ 
        , pedidos.VLR_TOT_PVE AS ValorTotalPedido 
        , pedidos.VLR_DESC AS ValorDesconto 
        , itensPedido.alq_DESC AS PercentualDesconto 
        , itensPedido.vlr_acresc AS ValorAcrescimo 
        , itensPedido.alq_ACRESC AS PercentualAcrescimo 
        , pedidos.VLR_FINAL AS ValorFinalPedido 
        /* Tipo do pedido, se serie ou Engenharia */ 
        , CASE pedidos.ID_TP_PED 
            WHEN 1 THEN 'Serie' 
            WHEN 2 THEN 'Engenharia' 
        END AS TipoPedido 
        , pedidos.DT_PREVENT AS PrevisaoEntrega 
        , rota.ds_rot AS RotaEntrega 
        , coes.DS_OES AS Coes
        , usuarios.nu_usu as CodRepresentante 
        , usuarios.NOM_USU AS Representante 
        , pedidos.DTHORA_PVE AS DataHoraPedido 
        , pedidos.ID_PRODUZIDO AS PedidoPronto 
        /* Itens do Pedido (Produto) */ 
        , itensPedido.NU_PRO AS CodProduto 
        , produtos.DS_PRO as NomeProduto 
        , catProdutos.DS_CAT as CategoriaProduto 
        , classeProdutos.DS_CLP as ClasseProduto
        , subclasseProdutos.DS_SCP as SubClasseProduto  
        , itensPedido.QT_PRO as QtdProduto  
        , itensPedido.VLR_PRO AS ValorUnitarioProduto 
        , itensPedido.vlr_desc/itensPedido.QT_PRO as ValorDescontoUnitario
        , itensPedido.QT_ALTURA AS MedidaAltura 
        , itensPedido.QT_LARGURA AS MedidaLargura       
        , itensPedido.qt_metrag AS MetragemUnitaria 
        , itensPedido.qt_metragcob AS MetragemCobradaUnitaria 
        , itensPedido.MetragemCobrada
        , itensPedido.VLR_PRO_TOT AS ValorUnitarioTotal 
        , itensPedido.ValorVendaProdutoComDesconto AS ValorUnitarioComDesconto
        , itensPedido.ValorTotalItemComDesconto + itensPedido.vlr_acresc AS ValorUnitarioTotalComDesconto   
        , itensPedido.NU_CUSTO AS CustoUnitarioProduto 
        /* Calculo de margem bruta do produto. Sobre o valor do produto com desconto. Resultado porcentagem com dois digitos */ 
        , (1 - (itensPedido.NU_CUSTO/(((itensPedido.VLR_PRO*(100-itensPedido.alq_DESC)))/100)))*100 AS MargemBrutaProduto 
        , produtos.TP_PROD AS TipoProduto 
        /* Informacoes da Entrega */ 
        , itensRomaneio.NU_ROM AS CodRomaneio 
        , itensRomaneio.QtdEntregue 
        , if (produtos.TP_PROD = 1, itensRomaneio.MetragemEntregueSerie, itensRomaneio.MetragemEntregue) as MetragemEntregue 
        , itensRomaneio.PesoEntregue        
        /* valor entregue */ 
        , IF( 
            itensPedido.QT_PRO = itensRomaneio.QtdEntregue 
            , itensPedido.VLR_TOTAL 
            , IF( 
                produtos.TP_PROD = 1 
                , itensRomaneio.qtdEntregue*itensPedido.ValorVendaProdutoComDesconto 
                , itensRomaneio.MetragemEntregue*itensPedido.ValorVendaProdutoComDesconto 
            ) 
            ) AS ValorEntregue 
        , itensRomaneio.DataHoraEntregue        
        /* Informacoes de Pagamento desse pedido */ 
        , (pedidos.VLR_FINAL - pagamentos.TotalPago) AS ValorPendente 
        , (
            SELECT SUM(titulos.VLR_TIT_ORIG) AS ValorPendenteTitulos
            FROM mgcta01014 titulos  
            INNER JOIN mgpxt01010 pedxtit ON ( pedxtit.nu_cta  = titulos.nu_cta)
            where pedxtit.NU_PVE =  pedidos.NU_PVE
            AND titulos.COD_LANCTO = 1
            AND titulos.ID_STAT_LANCTO = 1
        ) as ValorPendenteTitulos
        , (
            SELECT COUNT(titulos.NU_CTA) as QtdTitulosPendentes
            FROM mgcta01014 titulos  
            INNER JOIN mgpxt01010 pedxtit ON ( pedxtit.nu_cta  = titulos.nu_cta)
            where pedxtit.NU_PVE =  pedidos.NU_PVE
            AND titulos.COD_LANCTO = 1
            AND titulos.ID_STAT_LANCTO = 1
            ) as TitulosPendentesPedido     
        , (
                IF( 
                    (SELECT COUNT(titulos.NU_CTA) as QtdTitulosPendentes
                        FROM mgcta01014 titulos  
                        INNER JOIN mgpxt01010 pedxtit ON ( pedxtit.nu_cta  = titulos.nu_cta)
                        where pedxtit.NU_PVE = pedidos.NU_PVE
                        AND titulos.COD_LANCTO = 1
                        AND titulos.ID_STAT_LANCTO = 1) > 0,  0, 1)) as PedidoPago
        , pagamentos.TotalPago as TotalPago
        , pagamentos.totalDescontoTitulo as TotalDescontoEmTitulo
        , pagamentos.FormaPagamento as FormaQuitado 
        , pagamentos.DataPagamento as DataPagamento
        /* Devoluções dos produtos */ 
        , if (itensPedido.qtdDevolvida > itensRomaneio.QtdEntregue,
                    itensRomaneio.QtdEntregue,
                    itensPedido.qtdDevolvida
                ) as qtdDevolvida
        , if (itensPedido.metragemDevolvida > itensRomaneio.metragemEntregue,
                    itensRomaneio.metragemEntregue,
                    itensPedido.metragemDevolvida
                ) as metragemDevolvida 
        , if (itensPedido.metragemDevolvida > 0,
                    if ( itensPedido.metragemDevolvida >= itensRomaneio.metragemEntregue,
                                 itensRomaneio.metragemEntregue * itensPedido.ValorVendaProdutoComDesconto,
                             itensPedido.metragemDevolvida * itensPedido.ValorVendaProdutoComDesconto                            
                        )                   
                    , if (itensPedido.qtdDevolvida > itensRomaneio.QtdEntregue,
                                itensRomaneio.QtdEntregue * itensPedido.ValorVendaProdutoComDesconto,
                                itensPedido.qtdDevolvida * itensPedido.ValorVendaProdutoComDesconto
                            )                   
            ) as VendaDevolvido
        , itensPedido.DataDevolucao                 
        /* Informações Geográficas do clientes */
        , CONCAT('Brasil', ',', ufe.DS_UF, ',', cid.DS_CID, ',', ecl.DS_BAIRRO, ',', ecl.DS_LOGR, ',', ecl.NU_LOGR, ',', ecl.NU_CEP) AS EnderecoGPS 
    /* Unindo AS tabelas de itens do pedido de produtos e servicos para ser usado no join de pedidos */ 
    FROM ( 
        (SELECT produtos.NU_PRO, produtos.QT_PRO, produtos.VLR_PRO 
            , produtos.QT_ALTURA, produtos.QT_LARGURA, produtos.qt_metrag 
            , produtos.qt_metragcob, produtos.VLR_PRO_TOT, produtos.VLR_TOTAL 
            , produtos.NU_CUSTO, produtos.alq_desc, produtos.vlr_desc
            , produtos.alq_acresc, produtos.vlr_acresc
            , produtos.NU_DPV, produtos.NU_PVE
            , devolvidos.qt_pdv as qtdDevolvida
            , devolvidos.qt_pdv*(devolvidos.QT_ALTURA/1000)*(devolvidos.QT_LARGURA/1000) as metragemDevolvida
            ,   if (produtos.qt_metragcob > 0,
                (((produtos.VLR_PRO*(100-produtos.alq_desc)))/100) * produtos.qt_metragcob * produtos.qt_pro,
                (((produtos.VLR_PRO*(100-produtos.alq_desc)))/100) * produtos.qt_pro
            ) as ValorTotalItemComDesconto      
            , (((produtos.VLR_PRO*(100-produtos.alq_desc)))/100) as ValorVendaProdutoComDesconto
            ,   if (produtos.qt_metragcob is null,
                            pro.FAT_CONV1*produtos.QT_PRO,
                            0
                ) as MetragemCobrada
            , devolvidos.DT_PDV as DataDevolucao
            , ped.ID_STATUS
        FROM mgpve01011 produtos 
        INNER JOIN mgpve01010 ped ON (ped.NU_PVE = produtos.NU_PVE)
        INNER JOIN mgpro01010 pro ON (pro.NU_PRO = produtos.NU_PRO)
        LEFT JOIN mgpve01014 devolvidos on (
            devolvidos.NU_PVE = produtos.NU_PVE AND
            devolvidos.NU_PRO = produtos.NU_PRO AND
            devolvidos.QT_ALTURA = IFNULL(produtos.QT_ALTURA,0) AND
                devolvidos.QT_LARGURA = IFNULL(produtos.QT_LARGURA,0)
        ) 
        WHERE ped.DT_PVE >= '2024-07-01' AND ped.ID_STATUS in (1,2,4,8) )
        UNION ALL 
        (SELECT servicos.NU_PRO, servicos.QT_PRO, servicos.VLR_PRO 
            , servicos.QT_ALTURA, servicos.QT_LARGURA, servicos.qt_metrag 
            , servicos.qt_metragcob, servicos.VLR_PRO_TOT, servicos.vlr_total 
            , servicos.NU_CUSTO, servicos.alq_desc, servicos.vlr_desc
            , servicos.alq_acresc, servicos.vlr_acresc  
            , servicos.NU_DPV, servicos.NU_PVE 
            , null, null
            ,   if (servicos.qt_metragcob > 0,
                (((servicos.VLR_PRO*(100-servicos.alq_desc)))/100) * servicos.qt_metragcob * servicos.qt_pro,
                (((servicos.VLR_PRO*(100-servicos.alq_desc)))/100) * servicos.qt_pro
            ) as ValorTotalItemComDesconto
            , (((servicos.VLR_PRO*(100-servicos.alq_desc)))/100) as ValorVendaProdutoComDesconto 
            ,null
            , null
            , ped2.ID_STATUS
        FROM mgpve01012 servicos 
        INNER JOIN mgpve01010 ped2 ON ped2.NU_PVE = servicos.NU_PVE 
        WHERE ped2.DT_PVE > '2024-07-01' and ped2.ID_STATUS in (1,2,4,8)) 
        ) itensPedido 
    /* Unindo informacoes da entrega, nao precisa do detalhe, entao pega os valores totais de peso, quantidade e metragem */
    LEFT JOIN 
        (SELECT itens.NU_DPV, itens.NU_ROM
            , itens.peso*itens.QT_PRO AS PesoEntregue 
            , itens.qt_metragcob AS MetragemEntregue 
            , pro.FAT_CONV1*QT_PRO as MetragemEntregueSerie
            , itens.QT_PRO AS QtdEntregue 
            , rom.DT_ROM as DataHoraEntregue
        FROM mgrom01011 itens 
        INNER JOIN mgrom01010 rom ON (itens.NU_ROM = rom.NU_ROM) 
        INNER JOIN mgpro01010 pro on (pro.NU_PRO = itens.NU_PRO)
        WHERE rom.ID_TP_ROM = 2
  AND rom.DT_ROM >= '2025-01-01'
  AND rom.DT_ROM <  '2025-02-01'     
        ) itensRomaneio ON (itensPedido.NU_DPV = itensRomaneio.NU_DPV) 
    /* Join com a tabela principal de pedidos */ 
    INNER JOIN mgpve01010 pedidos ON (itensPedido.NU_PVE = pedidos.NU_PVE) 
    /* Condicao de Pagamento */ 
    LEFT JOIN mgcpg01010 condPagamento ON (condPagamento.NU_CPG = pedidos.NU_CPG) 
    /* Dados dos clientes */ 
    INNER JOIN mgcli01010 clientes ON (clientes.NU_CLI = pedidos.NU_CLI) 
    /* Logradouro */
    LEFT JOIN mgecl01010 ecl ON (clientes.NU_CLI = ecl.NU_ECL) 
    /* Cidade */
    LEFT JOIN mgcid01010 cid ON (ecl.NU_CID = cid.NU_CID)
    /* Estado */
    LEFT JOIN mgufe01010 ufe ON (cid.NU_UF = ufe.NU_UF)
    /* Informacao da rota */ 
    LEFT JOIN mgrot01010 rota ON (rota.NU_ROT = pedidos.NU_ROT) 
    /* Informacao de COES (Unidade do sistema para diferenciar tipos de operação) */ 
    LEFT JOIN mgoes01010 coes ON (coes.nu_oes = pedidos.NU_OES) 
    /* Dados do usuario do sistema */ 
    LEFT JOIN mgusu01010 usuarios ON (usuarios.nu_usu = pedidos.COD_USR_INS) 
    /* Detalhes dos Produtos */ 
    LEFT JOIN mgpro01010 produtos ON (produtos.NU_PRO = itensPedido.NU_PRO) 
    LEFT JOIN mgcat01010 catProdutos ON (produtos.NU_CAT = catProdutos.NU_CAT) 
    LEFT JOIN mgclp01010 classeProdutos ON (produtos.NU_CLP = classeProdutos.NU_CLP) 
    LEFT JOIN mgscp01010 subclasseProdutos ON (produtos.NU_SCP = subclasseProdutos.NU_SCP) 
    /* Join com dados sobre o pagamento. Multiplos pagamentos para cada pedido, entao extrai apenas o Total Pago e a Forma do pagamento */ 
    LEFT JOIN ( 
                select sum(pag.TotalPago) as TotalPago, sum(pag.TotalDescontoTitulo) as TotalDescontoTitulo, pag.NU_PVE
                , MAX(pag.DataPagamento) as dataPagamento
                , GROUP_CONCAT(formaPagamento) as formaPagamento
                from
                (
                    SELECT titulos.VLR_PAGO AS TotalPago
                            , (titulos.VLR_DESC - titulos.VLR_ACRESC) as TotalDescontoTitulo
                            , pedxtit.NU_PVE 
                            , titulos.DT_PAGTO as DataPagamento                         
                                , CASE pagTit.TP_PAGTO  
                                    WHEN 1 THEN "Dinheiro" 
                                    WHEN 2 THEN "Cheque" 
                                    WHEN 3 THEN "Cartao" 
                                    WHEN 4 THEN "Saldo" 
                                    WHEN 5 THEN "Outros" 
                                    WHEN 6 THEN "Boleto" 
                                    WHEN 7 THEN "Deposito" 
                                    WHEN 8 THEN "Duplicata" 
                                    WHEN 9 THEN "Saldo de Outro Cliente" 
                                    WHEN 11 THEN "Saldo" 
                                    ELSE "Varias Formas" 
                                END AS formaPagamento 
                            FROM mgpxt01010 pedxtit 
                            inner JOIN mgcta01014 titulos ON (titulos.nu_cta = pedxtit.nu_cta)
                            inner join mgcta01018 pagTit ON (titulos.NU_CLT = pagTit.NU_CLT)
                            AND titulos.COD_LANCTO = 1
                            AND titulos.ID_STAT_LANCTO = 2
                            GROUP BY pedxtit.NU_PVE, pedxtit.nu_cta
                ) pag group by pag.NU_PVE        
        ) pagamentos ON pagamentos.NU_PVE = pedidos.NU_PVE      
    ) pedidos