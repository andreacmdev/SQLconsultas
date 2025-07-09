SELECT 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
    titulo.nu_cta AS titulo,
    titulo.NU_FOR AS cod_fornecedor,
    'ALLGLASS TEMPERA' AS fornecedor,
    titulo.DS_CPG AS descricao,
    SUBSTRING(
        titulo.DS_CPG,
        LOCATE('Romaneio Externo ', titulo.DS_CPG) + LENGTH('Romaneio Externo '),
        LOCATE(' ', titulo.DS_CPG, LOCATE('Romaneio Externo ', titulo.DS_CPG) + LENGTH('Romaneio Externo ')) 
            - (LOCATE('Romaneio Externo ', titulo.DS_CPG) + LENGTH('Romaneio Externo '))
    ) AS cod_romaneio,
    titulo.VLR_PAGO AS valor_pago
FROM mgcta01014 titulo
WHERE titulo.NU_FOR = '1'
AND titulo.DS_CPG LIKE '%Romaneio Externo %'