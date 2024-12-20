-- scripts BI CD Vidros

select
	pf.tipo_unidade ,
	pf.unidade ,
	pf.nome_cliente ,
	pf.valor_titulo ,
	pf.tipo_documento 
from painel_financeiro pf
where pf.unidade = 'CD VIDROS'
	
	
SELECT DISTINCT 
    ep.unidade,
    ep.categoria,
    CAST(REPLACE(ep.estoque_atual, ',', '.') AS NUMERIC) AS estoque_atual,
    ep.estoque_peso,
    ep.classe,
    ep.subclasse,
    ep.estoque_metro,
    ep.fator_conversao,
    CAST(REPLACE(ep.custo_unitario, ',', '.') AS NUMERIC) AS custo_unitario,
    ROUND(
        CAST(REPLACE(ep.custo_unitario, ',', '.') AS NUMERIC) * 
        CAST(REPLACE(ep.estoque_atual, ',', '.') AS NUMERIC), 2
    ) AS valor_produto
FROM estoque_produtos ep 
WHERE unidade = 'CD VIDROS'
    AND REPLACE(ep.estoque_atual, ',', '.')::NUMERIC != 0.0;

	
	
(
    select 
        dd.tipo_unidade, 
        dd.unidade, 
        dd.cliente, 
        '' as cod_pedido, 
        '' as coes, 
        mc.ramo_atividade, 
        dd.tipo as status_pedido,
        0::NUMERIC as valor_final_pedido, 
        0::numeric as valor_entregue, 
        replace(dd.valortitulo, ',', '.')::numeric as total_devido, 
        0::NUMERIC as Saldo, 
        mc.rota,    
        mc.nome_fantasia,    
        '' as cod_romaneios,    
        '' as datas_entregas,
        dd.observacoes as pedido_cliente,
        dd.emissaotitulo as DataVencimento
    from documentos_devolvidos dd 
    left join mapeamento_clientes mc on dd.unidade = mc.unidade and dd.codcliente = mc.codcliente 
    where dd.unidade = 'CD VIDROS'
) 
union all 
(
    select 
        mb.tipo_unidade, 
        mb.unidade, 
        mb.nome_cliente, 
        mb.cod_pedido, 
        mb.coes, 
        mc.ramo_atividade, 
        mb.status_pedido, 
        ROUND(mb.valor_final_pedido::numeric, 2) as valor_final_pedido, 
        ROUND(mb.valor_entregue::numeric, 2) as valor_entregue, 
        ROUND(
            case    
                when status_pedido = 'Finalizado' then total_titulo    
                when (mb.status_pedido = 'Em Separacao' and cs.tipotitulo = 'VENDA') then total_titulo - (mb.valor_final_pedido - mb.valor_entregue)    
                when (mb.status_pedido = 'Em Separacao' and cs.tipotitulo = 'ESTOQUE') then total_titulo
            end::NUMERIC, 2) as total_devido, 
        (saldo.saldo) as Saldo, 
        rota_entrega,    
        mc.nome_fantasia,    
        mb.cod_romaneios,    
        mb.datas_entregas::text,
        mb.pedido_cliente,
        '' as DataVencimento
    from main_balanco mb 
    left join (
        select 
            unidade, 
            coes, 
            tipotitulo, 
            ativo 
        from coes_sistema cs 
        group by unidade, coes, tipotitulo, ativo
    ) cs on mb.unidade = cs.unidade and mb.coes = cs.coes 
    left join mapeamento_clientes mc on (mb.cod_cliente = mc.codcliente and mb.unidade = mc.unidade)
    left join (
        select 
            unidade, 
            id, 
            sum(replace(total, ',', '.')::numeric) as saldo 
        from saldo where tipo <> 'FORNECEDOR' 
        group by unidade, id 
    ) saldo on saldo.unidade = mc.unidade and saldo.id::numeric = mc.codcliente::numeric 
    where 
        mb.unidade = 'CD VIDROS'
        and status_pedido in ('Em Separacao', 'Finalizado') 
        and cs.ativo = 'S' 
        and status_pagamento = 'Pendente' 
        and mb.datas_entregas not like '%2021%'
) 
union all 
(
    select 
        pf.tipo_unidade, 
        pf.unidade, 
        pf.nome_cliente, 
        '' as cod_pedido, 
        '' as coes, 
        mc.ramo_atividade, 
        pf.tipo_documento as status_pedido,
        0::NUMERIC as valor_final_pedido, 
        0::numeric as valor_entregue, 
        replace(pf.valor_titulo, ',', '.')::numeric as total_devido, 
        0::NUMERIC as Saldo, 
        mc.rota,    
        mc.nome_fantasia,    
        '' as cod_romaneios,    
        pf.data_emissao as emissaotitulo,
        pf.tipo_documento as pedido_cliente,
        (pf.data_vencimento::date)::text as DataVencimento
    from painel_financeiro pf 
    left join mapeamento_clientes mc on pf.unidade = mc.unidade and pf.cod_cliente = mc.codcliente  
    where 
        pf.unidade = 'CD VIDROS'
        and pf.tipo_documento in ('boleto', 'cheque') 
        and pf.data_emissao::date >= '2023-06-01' 
        AND pf.status = '1'
)




select
	MPC.unidade ,
	mpc.fornecedor ,
	sum(mpc.valorpendente) as valor_pendente 
from main_pedido_compras mpc 
where unidade = 'CD VIDROS'
group by mpc.unidade, mpc.fornecedor 



select *
from mapa_cdvidros_contas