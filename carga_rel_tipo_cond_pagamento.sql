select
	tipo_unidade ,
    unidade,
    cond_pagamento,
    COUNT(*) AS Total
FROM pedidos
 	WHERE data_pedido::date BETWEEN '2024-01-01' AND '2024-04-30'
GROUP BY tipo_unidade , unidade, cond_pagamento
ORDER BY tipo_unidade , unidade, cond_pagamento;


