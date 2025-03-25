-- auditoria deposito não identificado
SELECT 
    '{{ $json["tipo_unidade"] }}' as tipo_unidade,
    '{{ $json["unidade"] }}' as unidade,
    dep.NU_DNI,
    dep.NU_CON,
    conta.DS_CON,
    titulos.ds_obs,
    dep.VLR_DEPOSITO,
    dep.ID_STATUS,
    dep.IDENTIFICACAO,
    dep.DT_REFERENCIA AS hora_referencia, 
    dep.DT_OPERACAO AS hora_operacao,
    DATE(dep.DT_OPERACAO) AS data_operacao, 
    DATE(dep.DT_REFERENCIA) AS data_referencia, 
    titulos.DT_PAGTO
FROM mgdni01010 dep
LEFT JOIN mgcta01014 titulos ON titulos.nu_cta = dep.nu_cta
LEFT JOIN mgcon01010 conta ON dep.NU_CON = conta.NU_CON
WHERE DATE(dep.DT_OPERACAO) = CURRENT_DATE 
AND DATE(dep.DT_REFERENCIA) < DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY);


---------------------------------------------------



select
    '{{ $json["tipo_unidade"] }}' as tipo_unidade,
    '{{ $json["unidade"] }}' as unidade,
    m.NU_CON ,
    m.DT_LANCTO as data_deposito ,
    m.DT_REF as referencia_dep,
    titulos.DT_EMISSAO as emissao_titulo,
    titulos.DT_PAGTO as pagamento_titulo,
    titulos.DT_REF as referencia_titulo,
    m.DS_LANCTO ,
    m.DS_DOCTO ,
    m.VLR_LANCTO ,
    m.AVULSO ,
    titulos.VLR_TIT_ORIG ,
    titulos.VLR_PAGO ,
    titulos.DS_CPG 
FROM mgcon01011 m
left join mgcta01014 titulos on m.nu_cta = titulos.nu_cta 
WHERE DS_DOCTO LIKE '%dep%' 
  AND NU_CON = 2 
  AND DS_LANCTO LIKE '%iden%'