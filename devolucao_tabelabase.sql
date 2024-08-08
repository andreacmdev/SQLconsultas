-- devolucao base
SELECT
    devolvidos.*,
    usuarios.NOM_USU as UsuarioDevolucao,
    motivos.DS_MMV AS MotivoDevolucao,
    od.DS_OBS_DEV as Observacao,
    CASE tipoPedido.ID_TP_PED
        WHEN 1 THEN 'Serie' 
        WHEN 2 THEN 'Engenharia' 
        WHEN 3 THEN 'Serviço'
    END AS TipoPedido
FROM
    mgpve01014 devolvidos
LEFT JOIN 
    mgusu01010 usuarios ON devolvidos.NU_USU = usuarios.NU_USU
LEFT JOIN 
    mgmmv01010 motivos ON devolvidos.NU_MMV = motivos.NU_MMV
LEFT JOIN 
    obs_devolucao od ON devolvidos.NU_OBS_DEV = od.NU_OBS_DEV
LEFT JOIN 
    mgpve01010 tipoPedido ON devolvidos.NU_PVE = tipoPedido.NU_PVE
LEFT JOIN 
    mgpro01010 produtos ON produtos.NU_PRO = devolvidos.NU_PRO
WHERE
    devolvidos.DT_PDV BETWEEN '2024-01-01' AND '2024-07-01';
