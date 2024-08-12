SELECT DISTINCT
    motivos.DS_MMV AS MotivoDevolucao
FROM
    mgpve01014 devolvidos
LEFT JOIN 
    mgmmv01010 motivos ON devolvidos.NU_MMV = motivos.NU_MMV