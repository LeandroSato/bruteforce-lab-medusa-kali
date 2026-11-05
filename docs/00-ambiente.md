# Configuração do Ambiente

Documentação da montagem do laboratório: duas VMs no VirtualBox (Kali Linux
e Metasploitable2), conectadas por uma rede **host-only** isolada.

## 1. VMs importadas e disco do Metasploitable2 anexado

O Metasploitable2 foi baixado em formato VMware (`.vmx`/`.vmdk`). Como o
VirtualBox não importa esse formato diretamente pelo assistente padrão, a VM
foi criada manualmente e o disco `.vmdk` original foi anexado na controladora
SATA.

![Disco do Metasploitable2 anexado](../images/00-ambiente/01-disco-metasploitable-anexado.png)

## 2. Rede Host-Only

Utilizada a rede host-only padrão do VirtualBox (`VirtualBox Host-Only
Ethernet Adapter`, faixa `192.168.56.0/24`), que isola completamente o
tráfego entre as VMs e o host, sem qualquer saída para a internet.

![Rede host-only criada](../images/00-ambiente/02-rede-hostonly-criada.png)

## 3. Placa de rede configurada em cada VM

Tanto o Kali quanto o Metasploitable2 tiveram o Adaptador 1 configurado como
**"Placa de rede exclusiva de hospedeiro (host-only)"**, usando a rede acima.

![VM configurada com adaptador host-only](../images/00-ambiente/03-vm-configurada-hostonly.png)

## 4. Confirmação dos IPs atribuídos

**Metasploitable2** — IP `192.168.56.101`:

![ifconfig no Metasploitable2](../images/00-ambiente/04-ifconfig-metasploitable.png)

**Kali Linux** — IP `192.168.56.102`:

![ip a no Kali](../images/00-ambiente/05-ip-a-kali.png)

## 5. Teste de conectividade

```bash
ping -c 3 192.168.56.101
```

Resultado: `3 packets transmitted, 3 received, 0% packet loss` — as duas VMs
se enxergam corretamente na rede isolada.

![Ping bem-sucedido entre as VMs](../images/00-ambiente/06-ping-sucesso.png)

---

Ambiente pronto para os testes de força bruta. Próximo: [Cenário 1 — FTP](cenario-1-ftp.md).
