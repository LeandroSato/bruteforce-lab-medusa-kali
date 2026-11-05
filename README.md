# Ataques de Força Bruta com Medusa em Laboratório Controlado

Projeto prático do curso **Cibersegurança — Santander/DIO**, demonstrando ataques de
força bruta contra serviços FTP, formulário web (DVWA) e SMB, utilizando **Kali Linux**
e a ferramenta **Medusa**, em um ambiente 100% isolado e controlado com VirtualBox.

> ⚠️ **Aviso legal e ético**: todos os testes deste repositório foram realizados
> exclusivamente em máquinas virtuais vulneráveis criadas para fins educacionais
> (Metasploitable 2 e DVWA), em uma rede virtual isolada (host-only), sem qualquer
> conexão com a internet ou com sistemas de terceiros. Realizar ataques de força
> bruta contra sistemas que não sejam seus ou sem autorização explícita é **crime**
> (no Brasil, pode se enquadrar na Lei 12.737/2012 e no Marco Civil da Internet).
> Use este material **apenas em ambientes próprios e isolados**, para fins de
> aprendizado e auditoria autorizada.

## Sumário

- [Objetivo](#objetivo)
- [Ambiente de laboratório](#ambiente-de-laboratório)
- [Topologia de rede](#topologia-de-rede)
- [Ferramentas utilizadas](#ferramentas-utilizadas)
- [Cenário 1 — Força bruta em FTP](#cenário-1--força-bruta-em-ftp)
- [Cenário 2 — Automação de login no DVWA (web form)](#cenário-2--automação-de-login-no-dvwa-web-form)
- [Cenário 3 — Password spraying em SMB](#cenário-3--password-spraying-em-smb)
- [Wordlists](#wordlists)
- [Resultados](#resultados)
- [Medidas de mitigação](#medidas-de-mitigação)
- [Aprendizados](#aprendizados)
- [Referências](#referências)

## Objetivo

Simular, em ambiente controlado, três formas comuns de ataque de força bruta —
contra um serviço de rede (FTP), uma aplicação web (DVWA) e um serviço de
compartilhamento de arquivos (SMB) — para:

1. Entender na prática como esses ataques funcionam;
2. Praticar o uso do Medusa e de ferramentas de reconhecimento (Nmap, enum4linux);
3. Documentar todo o processo de forma reprodutível;
4. Propor contramedidas reais para cada cenário.

## Ambiente de laboratório

| Componente          | Detalhe                                              |
|---------------------|-------------------------------------------------------|
| Hipervisor          | VirtualBox                                            |
| Máquina atacante    | Kali Linux (versão mais recente)                       |
| Máquina alvo        | Metasploitable 2 (vulnerável por padrão)               |
| Aplicação web alvo  | DVWA — Damn Vulnerable Web Application (nível **low**) |
| Modo de rede        | Host-only (rede interna, sem saída para a internet)    |

### Por que rede host-only?

A rede *host-only* garante que o tráfego de ataque fique restrito à máquina
host e às VMs, sem risco de atingir outros dispositivos da rede local ou da
internet — requisito básico de segurança para qualquer exercício de pentest.

## Topologia de rede

```
┌─────────────────────┐        Rede Host-Only        ┌─────────────────────────┐
│   Kali Linux (atk)   │ <───────────────────────────>│  Metasploitable 2 (alvo) │
│  IP: 192.168.56.10   │                               │   IP: 192.168.56.20      │
│  Ferramentas:        │                               │  Serviços vulneráveis:   │
│  - Medusa             │                               │  - FTP (21)              │
│  - Nmap               │                               │  - SMB (139/445)         │
│  - Navegador (DVWA)   │                               │  - DVWA (Apache/PHP)     │
└─────────────────────┘                               └─────────────────────────┘
```

> Substitua os IPs acima pelos reais do seu ambiente (verifique com `ifconfig`/`ip a`
> em cada VM).

## Ferramentas utilizadas

- **Kali Linux** — distribuição de pentest.
- **Medusa** — ferramenta de força bruta paralela a múltiplos serviços de rede.
- **Nmap** — reconhecimento de portas e serviços abertos.
- **DVWA** — aplicação web intencionalmente vulnerável para testes de login.
- **enum4linux** *(opcional)* — enumeração de usuários/compartilhamentos SMB.

## Cenário 1 — Força bruta em FTP

Script: [`scripts/01_ftp_bruteforce.sh`](scripts/01_ftp_bruteforce.sh)

1. Reconhecimento da porta 21 com Nmap:
   ```bash
   nmap -p 21 -sV 192.168.56.20
   ```
2. Execução do Medusa contra o serviço FTP:
   ```bash
   medusa -h 192.168.56.20 -U wordlists/usuarios.txt -P wordlists/senhas.txt -M ftp -t 3 -f
   ```
   - `-h` → host alvo
   - `-U` / `-P` → wordlists de usuários e senhas
   - `-M ftp` → módulo do serviço
   - `-t 3` → 3 threads simultâneas (evitar sobrecarga)
   - `-f` → para no primeiro par válido encontrado
3. Validação manual do acesso encontrado (login real via `ftp 192.168.56.20`).

📸 *Capturas de tela sugeridas: `images/01-nmap-ftp.png`, `images/02-medusa-ftp-sucesso.png`*

## Cenário 2 — Automação de login no DVWA (web form)

Script: [`scripts/02_dvwa_web_form.sh`](scripts/02_dvwa_web_form.sh)

1. Configurar o DVWA com **Security Level = Low** (menu *DVWA Security*).
2. Inspecionar o formulário de login (`Ctrl+U` na página) para confirmar os
   nomes dos campos (`username`, `password`, `Login`) e a mensagem exibida
   em caso de falha (ex.: `Login failed`).
3. Executar o Medusa com o módulo `web-form`:
   ```bash
   medusa -h 192.168.56.20 -U wordlists/usuarios.txt -P wordlists/senhas.txt \
     -M web-form \
     -m FORM:"/dvwa/login.php:username=^USER^&password=^PASS^&Login=Login:F=Login failed" \
     -t 3
   ```
4. Validar manualmente qualquer credencial reportada como válida, logando
   diretamente no navegador — formulários web geram falsos positivos com
   frequência (cookies/tokens CSRF podem interferir no resultado).

📸 *Capturas de tela sugeridas: `images/03-dvwa-login-page.png`, `images/04-medusa-webform.png`*

## Cenário 3 — Password spraying em SMB

Script: [`scripts/03_smb_password_spray.sh`](scripts/03_smb_password_spray.sh)

**Diferença entre brute force e password spraying:**

| Técnica            | Estratégia                                              | Risco de lockout |
|---------------------|----------------------------------------------------------|-------------------|
| Força bruta clássica| Muitas senhas × 1 usuário                                 | Alto              |
| Password spraying   | Poucas senhas (as mais comuns) × muitos usuários          | Baixo             |

1. Enumeração de usuários e compartilhamentos via Nmap:
   ```bash
   nmap -p 139,445 --script smb-enum-users,smb-enum-shares 192.168.56.20
   ```
2. Spraying com Medusa usando uma wordlist reduzida de senhas:
   ```bash
   medusa -h 192.168.56.20 -U wordlists/usuarios.txt -P senhas_spray.txt -M smbnt -t 3 -f
   ```

📸 *Capturas de tela sugeridas: `images/05-smb-enum.png`, `images/06-medusa-smb-sucesso.png`*

## Wordlists

- [`wordlists/usuarios.txt`](wordlists/usuarios.txt) — usuários comuns, incluindo
  os padrões conhecidos do Metasploitable2 (ex.: `msfadmin`).
- [`wordlists/senhas.txt`](wordlists/senhas.txt) — senhas fracas/comuns usadas
  nos testes de FTP e DVWA.

> Estas wordlists são propositalmente pequenas e didáticas. Em auditorias reais
> (autorizadas), listas como `rockyou.txt` (incluída no Kali em
> `/usr/share/wordlists/`) são mais realistas.

## Resultados

> Preencha esta seção com o que você observou ao rodar os scripts no seu
> laboratório — tempo de execução, credenciais encontradas (ex.:
> `msfadmin:msfadmin` no FTP do Metasploitable2), comportamento do DVWA, etc.

| Cenário        | Credencial encontrada | Tempo aproximado | Observações |
|----------------|------------------------|-------------------|-------------|
| FTP            |                        |                   |             |
| DVWA (web-form)|                        |                   |             |
| SMB (spraying) |                        |                   |             |

## Medidas de mitigação

- **Política de senhas fortes**: exigir senhas longas, com complexidade mínima,
  e bloquear senhas presentes em listas conhecidas (ex.: `rockyou.txt`).
- **Bloqueio de conta (account lockout)**: travar temporariamente a conta após
  N tentativas inválidas (mitiga força bruta clássica, mas não necessariamente
  password spraying bem distribuído no tempo).
- **Rate limiting / throttling**: limitar o número de tentativas por IP/tempo
  no serviço (FTP, SSH, formulário web).
- **Autenticação multifator (MFA)**: mesmo com a senha correta, o atacante não
  consegue autenticar sem o segundo fator.
- **CAPTCHA em formulários web**: dificulta automação de tentativas de login.
- **Desabilitar serviços e contas padrão não utilizados** (ex.: contas de
  teste, FTP anônimo).
- **Monitoramento e alertas (SIEM/IDS)**: detectar picos de tentativas de
  login falhas e alertar a equipe de segurança.
- **Segmentação de rede e firewall**: restringir quais origens podem acessar
  serviços sensíveis (FTP, SMB) a hosts/IPs necessários.
- **Atualização de software**: Metasploitable2 e DVWA são vulneráveis *por
  design*; em sistemas de produção, manter patches atualizados é essencial.

## Aprendizados

- Força bruta clássica é ruidosa e facilmente detectável por qualquer
  monitoramento básico de logs de autenticação.
- Password spraying é mais furtivo, pois distribui as tentativas entre muitos
  usuários em vez de concentrar em um só — por isso é uma técnica real usada
  em ataques contra ambientes corporativos (ex.: Office 365, VPNs).
- Formulários web exigem atenção extra na automação: cookies de sessão,
  tokens CSRF e mensagens de erro customizadas podem exigir ajustes finos no
  comando do Medusa.
- A defesa mais eficaz não é uma única medida, mas a combinação de política de
  senha forte + MFA + bloqueio de conta + monitoramento.

## Referências

- [Medusa — Documentação oficial](http://www.foofus.net/jmk/medusa/medusa.html)
- [Kali Linux — Site oficial](https://www.kali.org/)
- [DVWA — Damn Vulnerable Web Application](http://www.dvwa.co.uk/)
- [Nmap — Manual oficial](https://nmap.org/book/)
- Slide da aula: *Criando um Ataque Brute Force de senhas com Medusa e Kali Linux* (DIO)

---

Projeto desenvolvido como parte do bootcamp de **Cibersegurança — Santander Code
Girls/DIO**, para fins exclusivamente educacionais.
