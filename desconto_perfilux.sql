select titulo.VLR_TIT_ORIG , titulo.VLR_ACRESC , titulo.VLR_PAGO , titulo.VLR_DESC as desconto_mes from mgcta01014 titulo
where titulo.DT_EMISSAO  >= '2025-12-01' and COD_LANCTO = '1'