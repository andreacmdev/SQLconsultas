SELECT distinct
	p.tipo_unidade ,
	p.unidade ,
    p.cod_cliente,
    p.nome_cliente ,
    p.coes ,
    mc.ramo_atividade
FROM pedidos p
JOIN mapeamento_clientes mc ON p.unidade = mc.unidade  AND p.cod_cliente = mc.codcliente
WHERE TO_TIMESTAMP(p.last_updated, 'YYYY-MM-DD HH24:MI:SS') >= NOW() - INTERVAL '2 hour'
  AND p.coes ILIKE '%TRANS%'
  AND mc.ramo_atividade != 'INTERCOMPANY';