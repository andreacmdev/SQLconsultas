-- Relatório com vínculo direto por titulo_gerado para capturar ID_PERDA
SELECT  
   %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
  boletos.DS_BOLETO AS nu_documento,
  boletos.DT_EMISSAO AS data_emissao,
  'Devolvido Pendente' AS status, 
  boletos.DT_VENCT AS data_vencimento,
  boletos.VLR_BOLETO AS valor_titulo,
  titulos.NU_CLI AS cod_cliente,
  clientes.DS_CLI AS nome_cliente,
  dsf.NU_DSF AS n_dsf,
  dsf.TP_DSF AS tipo_dsf,
  boletos.Pendente_Tipo,
  'boleto' AS tipo_documento,
  dsf.NU_BAN AS cod_banco,
  dsf.NU_CON AS cod_conta,
  banco.DS_BAN AS inst_financeira,
  boletos.titulo_gerado ,
  CASE 
  WHEN titulos.ID_PERDA = 'S' THEN 'Sim'
  ELSE 'Não'
END AS id_perda
FROM mgcta01020 boletos
LEFT JOIN mgcta01014 titulos ON titulos.NU_CTA = boletos.titulo_gerado
LEFT JOIN mgcli01010 clientes ON clientes.NU_CLI = titulos.NU_CLI
LEFT JOIN mgdsf01010 dsf ON dsf.nu_dsf = boletos.nu_dsf 
LEFT JOIN mgcon01010 con ON con.NU_CON = dsf.NU_CON 
LEFT JOIN mgban01010 banco ON dsf.NU_BAN = banco.NU_BAN
WHERE boletos.ID_STATUS = '2' 
UNION ALL
SELECT 
      %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
  cheque.NU_CHEQUE AS nu_documento,
  NULL AS data_emissao,
  'Devolvido Pendente' AS status, 
  NULL AS data_vencimento,
  cheque.VLR_CHEQUE AS valor_titulo,
  titulos.NU_CLI AS cod_cliente,
  clientes.DS_CLI AS nome_cliente,
  dsf.NU_DSF AS n_dsf,
  dsf.TP_DSF AS tipo_dsf,
  NULL AS Pendente_Tipo,
  'cheque' AS tipo_documento,
  dsf.NU_BAN AS cod_banco,
  dsf.NU_CON AS cod_conta,
  banco.DS_BAN AS inst_financeira,
  cheque.titulo_gerado ,
  CASE 
  WHEN titulos.ID_PERDA = 'S' THEN 'Sim'
  ELSE 'Não'
END AS id_perda
FROM mgcta01016 cheque
LEFT JOIN mgcta01014 titulos ON titulos.NU_CTA = cheque.titulo_gerado
LEFT JOIN mgcli01010 clientes ON clientes.NU_CLI = titulos.NU_CLI
LEFT JOIN mgdsf01010 dsf ON dsf.nu_dsf = cheque.nu_dsf 
LEFT JOIN mgcon01010 con ON con.NU_CON = dsf.NU_CON 
LEFT JOIN mgban01010 banco ON dsf.NU_BAN = banco.NU_BAN 
WHERE cheque.ID_STATUS = 2 
  AND clientes.DS_CLI IS NOT NULL;
