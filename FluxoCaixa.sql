select 
%(Tipo_Unidade)s AS Tipo_Unidade,
%(Unidade)s AS Unidade,
datahoraentregue, 
ROUND(coalesce(TotalEntregue,0),2) as TotalEntregue,
ROUND(coalesce(total_recebido,0),2) as TotalRecebido, 
ROUND(coalesce(Total_saida,0),2) as Total_saida,
ROUND((coalesce(total_Recebido,0) - coalesce(total_saida,0)),2) as saldo_diario,
@running_total:= ROUND(@running_total + ((coalesce(total_Recebido,0) - coalesce(total_saida,0))),2) as Acumulado
from (
select DataHoraEntregue, 
ROUND(SUM(
	case 
		when x.TP_PROD in ('1', '4') then QtdEntregue * ValorVenda
		when x.TP_PROD = '2' then MetragemEntregue * ValorVenda
	end
),2) as TotalEntregue
from (
SELECT itens.NU_PVE as CodPedido
			, itens.NU_DPV as CodItem 
			, itens.NU_ROM as CodRomaneio
			, itens.peso*itens.QT_PRO AS PesoEntregue 
			, itens.qt_metragcob AS MetragemEntregue 
			, pro.FAT_CONV1*itens.QT_PRO as MetragemEntregueSerie
			, itens.QT_PRO AS QtdEntregue 
			, date(rom.DT_ROM) as DataHoraEntregue 
			, rom.TIPO_VEICULO as TipoVeiculo
			, rom.TIPO_ENTREGA as TipoEntrega
			, rom.PLACA_VEICULO as PlacaVeiculo
			, rom.NU_CARGA as Carga
			, pedidos.TP_PROD
			, (pedidos.ValorUnitario) as ValorUnitario
			, pedidos.alq_acresc
			, ValorVendaProdutoComDesconto as ValorVenda
		FROM mgrom01011 itens 
		INNER JOIN mgrom01010 rom ON (itens.NU_ROM = rom.NU_ROM)		
		INNER JOIN mgpro01010 pro on (pro.NU_PRO = itens.NU_PRO) 
		left join 
		(
		select produtos.NU_PVE, produtos.NU_DPV, 
				ROUND(if (produtos.qt_metragcob > 0,
					(((produtos.VLR_PRO*(100-coalesce(produtos.alq_desc,0))))/100) * produtos.qt_metragcob * produtos.qt_pro,
					(((produtos.VLR_PRO*(100-coalesce(produtos.alq_desc,0))))/100) * produtos.qt_pro
					)/produtos.qt_pro,2) as ValorUnitario,
					produtos.alq_acresc,
					prod.TP_PROD,
					(((produtos.VLR_PRO*(100-coalesce(produtos.alq_desc,0))))/100) as ValorVendaProdutoComDesconto
		from mgpve01011 produtos
		left join mgpve01010 ped on produtos.NU_PVE = ped.NU_PVE
		left join mgpro01010 prod on prod.NU_PRO = produtos.NU_PRO
		where ped.ID_STATUS in (1,2,4,8,9) 
		) pedidos on pedidos.NU_PVE = itens.NU_PVE and pedidos.NU_DPV = itens.NU_DPV
	WHERE rom.ID_TP_ROM = 2 AND date(rom.DT_ROM)  between '2024-02-01' and '2024-02-29'
) X 
group by DataHoraEntregue
) z left join (
select DataRecebimento, SUM(valor_Recebido) as total_recebido from (
select m2.DT_PAGTO as DataRecebimento, m.VLR_DLT as valor_recebido, m.NU_CLT from mgcta01018 m left join mgcta01014 m2 on m.NU_CLT = m2.NU_CLT 
where date(m2.DT_PAGTO) between '2024-02-01' and '2024-02-29' and m.TP_PAGTO not IN ('4','9')
and m2.cod_lancto = '1' and id_stat_lancto = '2'
group by m2.DT_PAGTO, m.NU_CLT, m.VLR_DLT
) x
group by DataRecebimento
) x on z.DataHoraEntregue = x.DataRecebimento
left join (
SELECT 
	DT_PAGTO as data,
	SUM((titulos.VLR_PAGO*IFNULL(titConta.perc,100))/100) AS total_saida 
FROM mgcta01014 AS titulos 
LEFT JOIN mgfor01010 AS fornecedor ON (fornecedor.NU_FOR = titulos.NU_FOR) 
LEFT JOIN mgtpd01010 AS classificacao ON (titulos.NU_TPD = classificacao.NU_TPD)  
left join mgtxc01010 titConta on (titulos.NU_CTA=titConta.NU_CTA) 
left join mgccu01010 centroCusto on (titConta.NU_CCU=centroCusto.NU_CCU) 
left join mgcpc01010 planoConta on (titConta.NU_CPC=planoConta.NU_CPC) 
left join ( 
	select NU_CLT, MAX(TP_PAGTO) as TP_PAGTO, SUM(VLR_DLT) as VLR_DLT 
	FROM mgcta01018 f 
	GROUP by NU_CLT 
) formas ON (formas.NU_CLT = titulos.NU_CLT) 
LEFT JOIN mgcta01017 AS pagamentos ON (titulos.NU_CLT = pagamentos.NU_CLT)  
WHERE  
	date(titulos.DT_PAGTO) between '2024-02-01' and '2024-02-29'
	AND titulos.COD_LANCTO = 2 And titulos.ID_STAT_LANCTO = 2
	and formas.TP_PAGTO not in ('4', '9')
	group by DT_PAGTO
	order by titulos.DS_CPG 
) y on x.DataRecebimento = y.data
join (select @running_total := 0) r