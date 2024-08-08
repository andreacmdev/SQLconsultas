-- listar COES
SELECT 
    unidade ,
    ativo,
    coes,
    codcoes
FROM
    coes_sistema cs where unidade = 'GM Recife'
    