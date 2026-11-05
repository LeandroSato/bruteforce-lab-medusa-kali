# Cenário 2 — Automação de Login no DVWA (Web Form)

> 🚧 Em andamento.

Script usado: [`../scripts/02_dvwa_web_form.sh`](../scripts/02_dvwa_web_form.sh)

## Planejado

1. Instalar o DVWA (via Docker no Kali, já que o Metasploitable2 não vem com
   ele pré-instalado): `docker run --rm -it -p 80:80 vulnerables/web-dvwa`
2. Configurar o DVWA com **Security Level = Low**
3. Inspecionar o formulário de login para confirmar campos e mensagem de erro
4. Executar o Medusa com o módulo `web-form`
5. Validar manualmente a credencial encontrada

As imagens desta etapa serão adicionadas em `../images/cenario-2-dvwa/`.
