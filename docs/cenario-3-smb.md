# Cenário 3 — Password Spraying em SMB

> 🚧 Em andamento.

Script usado: [`../scripts/03_smb_password_spray.sh`](../scripts/03_smb_password_spray.sh)

## Planejado

1. Enumeração de usuários e compartilhamentos via Nmap (`smb-enum-users`,
   `smb-enum-shares`)
2. Geração de uma wordlist reduzida de senhas comuns
3. Password spraying com Medusa (`-M smbnt`)
4. Comparação do comportamento com o ataque de força bruta clássico do
   Cenário 1

As imagens desta etapa serão adicionadas em `../images/cenario-3-smb/`.
