SELECT
    *, 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade
FROM mgcta01019 car
where -- car.OBS = 'IdPagto (API) 2616821791' and car.OBS = 'IdPagto (API) 2283724552'
car.DT_RECEBTO  > '2024-01-01' and car.DT_RECEBTO < '2025-01-01'