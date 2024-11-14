SELECT *,
       ROUND((1 - (CAST(REPLACE(valor_liquido, ',', '.') AS NUMERIC) / CAST(REPLACE(valor_bruto, ',', '.') AS NUMERIC))) * 100, 2) AS taxa_dsf
from
	valores_dsf vd
where
	DATE(data_dsf ::timestamp) BETWEEN current_date - 1
  and (1 - (CAST(REPLACE(valor_liquido, ',', '.') AS NUMERIC) / CAST(REPLACE(valor_bruto, ',', '.') AS NUMERIC))) * 100 > 6;