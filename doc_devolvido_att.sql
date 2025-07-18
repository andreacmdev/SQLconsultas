-- Relatório com vínculo direto por titulo_gerado para capturar ID_PERDA
SELECT  
  boletos.Pendente_Tipo,
  CASE 
        WHEN titulos.ID_PERDA = 'S' THEN 'Sim'
        ELSE 'Não'
  END AS id_perda,
    %(Tipo_Unidade)s AS Tipo_Unidade,
  %(Unidade)s AS Unidade, 
  boletos.DT_EMISSAO AS data_emissao,
  titulos.NU_CLI AS cod_cliente,
  clientes.DS_CLI AS nome_cliente,
  clientes.NU_CPF_CNPJ as CNPJ,
  boletos.VLR_BOLETO AS valor_titulo,
  boletos.DT_VENCT AS data_vencimento,
  '' as Pedido,  
  '' as Romaneio,
  '' as Nota_Fiscal,
  '' as Telefone,
  dsf.NU_DSF,
  'boleto' AS tipo_documento,
  boletos.titulo_gerado ,
  '' as Observações_Unidade,
  '' as Solução_EC
FROM mgcta01020 boletos
LEFT JOIN mgcta01014 titulos ON titulos.NU_CTA = boletos.titulo_gerado
LEFT JOIN mgcli01010 clientes ON clientes.NU_CLI = titulos.NU_CLI
LEFT JOIN mgdsf01010 dsf ON dsf.nu_dsf = boletos.nu_dsf 
LEFT JOIN mgcon01010 con ON con.NU_CON = dsf.NU_CON 
LEFT JOIN mgban01010 banco ON dsf.NU_BAN = banco.NU_BAN
WHERE boletos.ID_STATUS = '2' and titulos.ID_STAT_LANCTO = '1'
UNION ALL
SELECT 
  NULL AS Pendente_Tipo,
    CASE 
  WHEN titulos.ID_PERDA = 'S' THEN 'Sim'
  ELSE 'Não'
END AS id_perda,
  %(Tipo_Unidade)s AS Tipo_Unidade,
  %(Unidade)s AS Unidade, 
  NULL AS data_emissao,
  titulos.NU_CLI AS cod_cliente,
  clientes.DS_CLI AS nome_cliente,
   clientes.NU_CPF_CNPJ as CNPJ,
  cheque.VLR_CHEQUE AS valor_titulo,
  cheque.DT_CHEQUE AS data_vencimento,
   '' as Pedido,  
  '' as Romaneio,
  '' as Nota_Fiscal,
  '' as Telefone,
  dsf.NU_DSF,
    'cheque' AS tipo_documento,
   cheque.titulo_gerado ,   
     '' as Observações_Unidade,
  '' as Solução_EC
FROM mgcta01016 cheque
LEFT JOIN mgcta01014 titulos ON titulos.NU_CTA = cheque.titulo_gerado
LEFT JOIN mgcli01010 clientes ON clientes.NU_CLI = titulos.NU_CLI
LEFT JOIN mgdsf01010 dsf ON dsf.nu_dsf = cheque.nu_dsf 
LEFT JOIN mgcon01010 con ON con.NU_CON = dsf.NU_CON 
LEFT JOIN mgban01010 banco ON dsf.NU_BAN = banco.NU_BAN 
WHERE cheque.ID_STATUS = 2 and titulos.ID_STAT_LANCTO = '1'
  AND clientes.DS_CLI IS NOT NULL
union all
select
 cartao.Pendente_Tipo,
  CASE 
        WHEN titulos.ID_PERDA = 'S' THEN 'Sim'
        ELSE 'Não'
  END AS id_perda,
    %(Tipo_Unidade)s AS Tipo_Unidade,
  %(Unidade)s AS Unidade, 
  NULL AS data_emissao,
  titulos.NU_CLI AS cod_cliente,
  clientes.DS_CLI AS nome_cliente,
  clientes.NU_CPF_CNPJ as CNPJ,
  cartao.VLR_CARTAO AS valor_titulo,
  NULL AS data_vencimento,
  '' as Pedido,  
  '' as Romaneio,
  '' as Nota_Fiscal,
  '' as Telefone,
  dsf.NU_DSF,
  'Cartao' AS tipo_documento,
  cartao.titulo_gerado ,
  '' as Observações_Unidade,
  '' as Solução_EC
from mgcta01019 cartao
LEFT JOIN mgcta01014 titulos ON titulos.NU_CTA = cartao.titulo_gerado
LEFT JOIN mgcli01010 clientes ON clientes.NU_CLI = titulos.NU_CLI
LEFT JOIN mgdsf01010 dsf ON dsf.nu_dsf = cartao.nu_dsf 
LEFT JOIN mgcon01010 con ON con.NU_CON = dsf.NU_CON 
LEFT JOIN mgban01010 banco ON dsf.NU_BAN = banco.NU_BAN 
WHERE cartao.ID_STATUS = 2 and titulos.ID_STAT_LANCTO = '1'




