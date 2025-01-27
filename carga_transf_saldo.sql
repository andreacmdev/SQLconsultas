-- transferencia de saldo
select 
unidade,
usuario, 
fornecedor as cliente_saida,
(regexp_matches(descricao, 'cliente (\d+) - ([^-]+) -') )[1] AS codigo_cliente_entrada,
(regexp_matches(descricao, 'cliente (\d+) - ([^-]+) -') )[2] AS nome_cliente_entrada,
(regexp_matches(descricao, 'cliente (\d+) - ([^-]+) - ([^-]+)') )[3] AS descricao_transferencia,
valormovimentado,
datasaldo::date
from mov_saldo_fornecedor msf
where tipo_unidade = 'Bodinho' 
and tipo_movimentacao = 'SAIDA'
and tipomovimentacao = 'Cliente'
and descricao like ('%Transf%')
and datasaldo::date >= NOW()::DATE - '3 HOUR'::INTERVAL
order by datasaldo::date desc