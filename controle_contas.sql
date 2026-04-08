select     %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade, conta.NU_CON as cod_conta , conta.DS_CON as conta , mov.DT_LANCTO , mov.DS_LANCTO , mov.DS_DOCTO , mov.TP_LANCTO , mov.VLR_LANCTO , mov.SLD_ATUAL , usu.DS_LOGIN as usuario , mov.nu_cta as titulo, mov.ESTORNADO  from mgcon01011 mov
left join mgcon01010 conta on conta.NU_CON = mov.NU_CON 
left join mgusu01010 usu on mov.NU_USU = usu.NU_USU 