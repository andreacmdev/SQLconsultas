select %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   cliente.NU_CLI as cod_cliente, cliente.DS_CLI as nome_cliente, condicao.DS_CPG from mgcli01010 cliente
left join mgcli01017 clicond on cliente.NU_CLI = clicond.NU_CLI 
left join mgcpg01010 condicao on clicond.NU_CPG = condicao.NU_CPG
where condicao.DS_CPG = 'ESPECIAL'