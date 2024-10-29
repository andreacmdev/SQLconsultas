-- pendencia unidades cliente nobre

SELECT 
	%(Tipo_Unidade)s as Tipo_Unidade,
	%(Unidade)s as Unidade,
    titulos.nu_cta AS titulo,
    titulos.VLR_TIT_ORIG,
    titulos.VLR_ACRESC ,          
    titulos.VLR_DESC ,           
    titulos.VLR_PAGO ,        
    titulos.NU_CLI,
    cliente.DS_CLI,
    documento.NU_DBL ,
    documento.DS_BOLETO ,
    documento.VLR_BOLETO ,
    documento.ID_STATUS ,
    documento.DS_OBS ,
    documento.DT_EMISSAO ,
    documento.DT_VENCT ,
    (titulos.VLR_TIT_ORIG + titulos.VLR_ACRESC - titulos.VLR_DESC) AS valor_final,
    ((titulos.VLR_TIT_ORIG + titulos.VLR_ACRESC - titulos.VLR_DESC) - titulos.VLR_PAGO) AS valor_pendente,
    CASE   
        WHEN titulos.ID_STAT_LANCTO = 1 THEN 'PENDENTE'   
    END AS status_titulo
FROM 
    mgcta01014 titulos
LEFT JOIN 
    mgcli01010 cliente ON titulos.NU_CLI = cliente.NU_CLI
left join 
	mgcta01020 documento on titulos.NU_CLI = documento.NU_CLI 
WHERE 
    (cliente.DS_CLI LIKE '%NOBRE%' OR cliente.DS_CLI LIKE '%NÓBRE%')
    AND titulos.ID_STAT_LANCTO = '1'