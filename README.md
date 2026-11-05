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

## Status do projeto

| Cenário | Status |
|---|---|
| Configuração do ambiente (VMs + rede host-only) | ✅ Concluído — [docs/00-ambiente.md](docs/00-ambiente.md) |
| Cenário 1 — Força bruta em FTP | ✅ Concluído — [docs/cenario-1-ftp.md](docs/cenario-1-ftp.md) |
| Cenário 2 — DVWA (web form) | 🚧 Em andamento — [docs/cenario-2-dvwa.md](docs/cenario-2-dvwa.md) |
| Cenário 3 — Password spraying SMB | 🚧 Em andamento — [docs/cenario-3-smb.md](docs/cenario-3-smb.md) |

## Sumário

- [Objetivo](#objetivo)
- [Ambiente de laboratório](#ambiente-de-laboratório)
- [Topologia de rede](#topologia-de-rede)
- [Ferramentas utilizadas](#ferramentas-utilizadas)
- [Documentação detalhada por cenário](#documentação-detalhada-por-cenário)
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
│  IP: 192.168.56.102  │                               │   IP: 192.168.56.101     │
│  Ferramentas:        │                               │  Serviços vulneráveis:   │
│  - Medusa             │                               │  - FTP (21)              │
│  - Nmap               │                               │  - SMB (139/445)         │
│  - Navegador (DVWA)   │                               │  - DVWA (Apache/PHP)     │
└─────────────────────┘                               └─────────────────────────┘
```

> IPs atribuídos via DHCP da rede host-only (`192.168.56.0/24`). Detalhes da
> configuração completa em [docs/00-ambiente.md](docs/00-ambiente.md).

## Ferramentas utilizadas

- **Kali Linux** — distribuição de pentest.
- **Medusa** — ferramenta de força bruta paralela a múltiplos serviços de rede.
- **Nmap** — reconhecimento de portas e serviços abertos.
- **DVWA** — aplicação web intencionalmente vulnerável para testes de login.
- **enum4linux** *(opcional)* — enumeração de usuários/compartilhamentos SMB.

## Documentação detalhada por cenário

A configuração do ambiente e cada cenário de ataque têm documentação própria,
com os comandos exatos executados, decisões tomadas durante o processo e
capturas de tela como evidência:

- 📄 [**docs/00-ambiente.md**](docs/00-ambiente.md) — configuração das VMs e
  da rede host-only, com confirmação de conectividade
- 📄 [**docs/cenario-1-ftp.md**](docs/cenario-1-ftp.md) — força bruta em FTP
  (✅ concluído: credencial `msfadmin:msfadmin` encontrada e validada)
- 📄 [**docs/cenario-2-dvwa.md**](docs/cenario-2-dvwa.md) — automação de login
  no DVWA (🚧 em andamento)
- 📄 [**docs/cenario-3-smb.md**](docs/cenario-3-smb.md) — password spraying em
  SMB (🚧 em andamento)

Os scripts de cada cenário estão em [`scripts/`](scripts/).

## Wordlists

- [`wordlists/usuarios.txt`](wordlists/usuarios.txt) — usuários comuns, incluindo
  os padrões conhecidos do Metasploitable2 (ex.: `msfadmin`).
- [`wordlists/senhas.txt`](wordlists/senhas.txt) — senhas fracas/comuns usadas
  nos testes de FTP e DVWA.

> Estas wordlists são propositalmente pequenas e didáticas. Em auditorias reais
> (autorizadas), listas como `rockyou.txt` (incluída no Kali em
> `/usr/share/wordlists/`) são mais realistas.

## Resultados

| Cenário        | Credencial encontrada | Tempo aproximado | Observações |
|----------------|------------------------|-------------------|-------------|
| FTP            | `msfadmin:msfadmin`   | ~3s (wordlist pequena) | Validado com login manual. Wordlist completa do Metasploit (174×1021) foi testada antes e estimada em 30h+ — trocada por wordlist curta e focada. Detalhes: [docs/cenario-1-ftp.md](docs/cenario-1-ftp.md) |
| DVWA (web-form)| 🚧 em andamento        | —                 | — |
| SMB (spraying) | 🚧 em andamento        | —                 | — |

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
