#!/usr/bin/env bash
#
# 02_dvwa_web_form.sh
# Tentativa de automacao de login no formulario web do DVWA usando o
# modulo web-form do Medusa.
#
# IMPORTANTE: este comando, sozinho, NAO funciona nessa versao do DVWA
# (v1.10+), porque o formulario de login tem um token anti-CSRF
# obrigatorio que muda a cada carregamento da pagina. O Medusa (e o
# Hydra, em configuracao padrao) nao conseguem tratar esse token
# dinamico, resultando em erro de protocolo (Medusa) ou falso positivo
# generalizado (Hydra).
#
# Use este script para reproduzir a tentativa inicial e entender a
# limitacao. Para o ataque que de fato funciona, veja:
#   scripts/dvwa_bruteforce_csrf.py
#
# Detalhes completos da investigacao: docs/cenario-2-dvwa.md
#
# USO:
#   ./02_dvwa_web_form.sh <IP_DO_DVWA>
#
set -euo pipefail

TARGET="${1:?Uso: $0 <IP_DO_ALVO>}"
USERS="../wordlists/usuarios.txt"
PASSWORDS="../wordlists/senhas.txt"

echo "[*] Tentando com Medusa (modulo web-form) -- esperado falhar com erro 302"
medusa -h "$TARGET" -U "$USERS" -P "$PASSWORDS" \
  -M web-form \
  -m FORM:"/login.php" \
  -m DENY-SIGNAL:"Login failed" \
  -m FORM-DATA:"post?username=&password=&Login=Login" \
  -t 3 || true

echo ""
echo "[*] Como esperado, o Medusa nao trata o token CSRF dinamico do DVWA."
echo "[*] Use o script Python para o ataque funcional:"
echo "    python3 dvwa_bruteforce_csrf.py"
