# -*- coding: utf-8 -*-
"""
Created on Thu Sep 26 12:33:28 2024

@author: andre
"""

import mysql.connector
import pandas as pd
import threading
import warnings
import os
from unidecode import unidecode
import concurrent.futures

warnings.simplefilter('ignore')
Query = pd.DataFrame()
disabled = []
parametros = r"C:\Users\andre\OneDrive\Documentos\Development\Alumiaço\Python\RELATÓRIOS\1 - PARAMETROS"
caminho_scripts = r"C:\Users\andre\OneDrive\Documentos\Development\Alumiaço\Python\RELATÓRIOS\SCRIPTS"

# Defina a unidade desejada aqui (ou deixe como None para processar todas as unidades)
UNIDADE_DESEJADA = None  # Exemplo: "Unidade_A" ou None para todas

# Função para carregar as conexões das unidades
def carregarConexoesUnidades():
    connections = pd.read_excel(r"{}\connections.xlsx".format(parametros), usecols=['Status', 'unidade', 'tipo_unidade', 'host', 'name', 'port', 'user', 'senha'])
    return connections

# Função para testar a conexão com o banco de dados
def test_connection(Status, unidade, tipo_unidade, host, name, port, user, senha):
    if Status == 'S':
        try:
            connection = mysql.connector.connect(
                host=host,
                port=port,
                user=user,
                password=senha,
                database=name
            )
            connection.close()
        except mysql.connector.Error:
            disabled.append(unidade)
    elif Status == 'N':
        disabled.append(unidade)

# Função para executar a query em uma unidade e retornar o DataFrame
def ProdutosNaoContabilizados(conn):
    Variaveis = {
        'Unidade': conn['unidade'],
        'Tipo_Unidade': conn['tipo_unidade'],
    }

    print("CONECTANDO NA UNIDADE: ", conn['unidade'])

    try:
        mydbConn = mysql.connector.connect(
            host=conn['host'],
            port=conn['port'],
            user=conn['user'],
            password=conn['senha'],
            database=conn['name']
        )

        with open(r"{}\contas_internas.sql".format(caminho_scripts), 'r', encoding="utf8") as f:
            mycursor = mydbConn.cursor()
            mycursor.execute(f.read(), Variaveis)
            myresult = mycursor.fetchall()
            df = pd.DataFrame(myresult, columns=mycursor.column_names)

        mydbConn.close()
        return df
    except Exception as e:
        print("ERRO DE CONEXAO NA UNIDADE: ", conn['unidade'])
        return pd.DataFrame()  # Retorna DataFrame vazio em caso de erro

# Defina a unidade desejada aqui (ou deixe como None para processar todas as unidades)
UNIDADE_DESEJADA = "GM Maceio"  # Exemplo: "GM Maceio" ou None para todas

# Carrega as conexões das unidades
databases = carregarConexoesUnidades()

# Filtra as unidades com base na unidade desejada
if UNIDADE_DESEJADA:
    databases = databases[databases['unidade'] == UNIDADE_DESEJADA]  # Filtra a unidade especificada

# Testa as conexões das unidades
threads = []
for index, d in databases.iterrows():
    Status, unidade, tipo_unidade, host, name, port, user, senha = d
    t = threading.Thread(target=test_connection, args=(Status, unidade, tipo_unidade, host, name, port, user, senha))
    threads.append(t)
    t.start()

for t in threads:
    t.join()

# Remove as unidades sem conexão
mask = databases['unidade'].isin(disabled)
connected = databases.drop(databases[mask].index)

print("Unidades sem conexão:", disabled)

# Executa as queries em paralelo usando ThreadPoolExecutor
with concurrent.futures.ThreadPoolExecutor() as executor:
    results = list(executor.map(ProdutosNaoContabilizados, [row for _, row in connected.iterrows()]))

# Concatena os resultados em um único DataFrame
Query = pd.concat(results, ignore_index=True)

# Caminho para o diretório onde o arquivo Excel será salvo
output_dir = r"C:\Users\andre\OneDrive\Documentos\Development\Alumiaço\Python\RELATÓRIOS\OUTPUTS"

# Verifica se o diretório existe, e se não, cria-o
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Caminho completo para o arquivo Excel
path = os.path.join(output_dir, f"contas_internas['unidade']{pd.Timestamp.now().strftime('%y%m%d-%H%M%S')}.xlsx")

# Converte os dados do DataFrame usando unidecode
def clean_text(value):
    if isinstance(value, str):
        return unidecode(value)
    return value

Query = Query.applymap(clean_text)

# Salva o DataFrame como um arquivo Excel
Query.to_excel(path, index=False, header=True)

print("Arquivo Excel salvo com sucesso em:", path)