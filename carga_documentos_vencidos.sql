-- documentos vencidos < 7 dias
SELECT 
    pf.unidade,
    pf.tipo_unidade,
    pf.tipo_documento,
    pf.nu_documento,
    pf.cod_cliente,
    pf.nome_cliente,
    pf.status,
    pf.data_emissao,
    pf.data_vencimento,
    pf.tipo 
FROM painel_financeiro pf 
WHERE pf.unidade NOT IN 
    ('3D Vidros',
     'EUNAPOLIS',
     'PORTO SEGURO',
     'Alumiaco JP',
     'ARARIPINA',
     'BACABAL',
     'CAUCAIA',
     'CODO',
     'CONQUISTA',
     'COSTADOSCORAIS',
     'CVIDROS',
     'FMVIDROS', 
     'JUAZEIRO DO NORTE', 
     'LAUROFREITAS',''
     'PALMARES', 
     'PARNAMIRIM',
     'RN NATAL', 
     'SAO LUIS',
     'TEIXEIRA DE FREITAS')
AND tipo_documento IN 
    ('cartao',
     'boleto',
     'cheque')
AND TO_DATE(pf.data_vencimento, 'YYYY-MM-DD') < CURRENT_DATE - INTERVAL '7 days';