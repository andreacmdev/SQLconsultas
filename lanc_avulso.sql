-- lançamentos avulsos controle de contas
SELECT 
    contas.NU_CON as CONTA,
    conta.DS_CON,
    DT_LANCTO as data_lancamento,
    DS_LANCTO as descrição,
    TP_LANCTO as tipo,
    VLR_LANCTO as valor,
    SLD_ATUAL as saldo_atual,
    DT_REF as data_referencia,
    AVULSO,
    ESTORNADO,
    contas.NU_USU,
    usuario.NOM_USU as usuario,
    contas.DS_ESTORNO 
FROM mgcon01011 contas 
LEFT JOIN mgusu01010 usuario ON contas.NU_USU = usuario.NU_USU 
LEFT JOIN mgcon01010 conta ON contas.NU_CON = conta.NU_CON
WHERE 
    AVULSO = 'S' 
    AND DT_LANCTO >= '2024-07-01'  -- Data inicial: 1º de julho de 2024
    AND DT_LANCTO <= '2025-02-28'  -- Data final: 28 de fevereiro de 2025
ORDER BY contas.DT_LANCTO DESC;