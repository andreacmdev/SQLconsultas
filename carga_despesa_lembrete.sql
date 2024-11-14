-- despesa paga lembrete
 select *,
 TO_CHAR(data_pagamento::DATE, 'YYYY-MM-DD') AS data_formatada
from movimentacoes_financeiras mf 
where 
	mf.tipo_de_lancamento = 'Saida'
and mf.descricao ilike '%lembrete%'
 AND data_pagamento::DATE BETWEEN '2024-11-01' AND '2024-11-12';