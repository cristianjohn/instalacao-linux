# 📌 AlmaLinux 10 - Initial Server Setup Script

Este repositório contém um **script shell interativo** para configuração inicial de um servidor **AlmaLinux 10**, especialmente preparado para ambientes com **Nginx**, **MariaDB**, entre outros serviços.

---

## ✅ Funcionalidades do Script

O script executa as principais tarefas de configuração inicial de forma **interativa**, perguntando ao usuário antes de cada etapa.

### Ações disponíveis:

- 🔄 Atualização do sistema
- 🖥️ Configuração de hostname
- 🕒 Configuração de timezone
- 🛠️ Instalação de ferramentas básicas (vim, curl, wget, etc)
- 📦 Instalação do repositório EPEL
- 🔥 Ativação e configuração do Firewalld
- 🚫 Desativação do SELinux (opcional)
- 💾 Criação de partição de SWAP (com tamanho personalizado)
- 👤 Criação de novo usuário com acesso sudo
- 🌐 Instalação do NGINX
- 🗃️ Instalação do MariaDB (com execução do `mysql_secure_installation`)

---

## 🚀 Como usar

### Método recomendado (seguro):

1. **Clone o repositório ou baixe o script manualmente:**

```bash
git clone https://github.com/cristianjohn/instalacao-linux.git
cd instalacao-linux
```

ou

```bash
 wget https://raw.githubusercontent.com/cristianjohn/instalacao-linux/main/almalinux-setup.sh
 ```

2. **Torne o script executável:**

```bash
chmod +x almalinux-setup.sh
```

3. **Revise o conteúdo antes (recomendado):**

```bash
nano almalinux-setup.sh
```

4. **Execute o script:**

```bash
./almalinux-setup.sh
```

---

### ⚠️ Execução direta via cURL (não recomendado em produção):

Se ainda assim desejar:

```bash
curl -s https://raw.githubusercontent.com/cristianjohn/instalacao-linux/main/almalinux-setup.sh | bash -
```

> **Atenção:** Execute por sua conta e risco. Sempre revise o conteúdo de qualquer script antes de rodar dessa forma.

---

## ✅ Pré-requisitos

- Sistema operacional: **AlmaLinux 10** (instalação mínima ou padrão)
- Acesso root ou permissão sudo

---

## ✅ Possíveis futuras melhorias

- Instalação opcional de PHP, Certbot, Fail2Ban, etc.
- Automação de configuração LEMP completa
- Configuração inicial de SSH segura
- Backup automático

---

## ✅ Licença

Este projeto está licenciado sob a **MIT License**.

---

## ✅ Contribuições

Sinta-se à vontade para abrir issues, enviar pull requests ou sugerir melhorias.

---

## ✅ Aviso de segurança

Este script faz alterações importantes no sistema operacional. Use com responsabilidade, principalmente em ambientes de produção.






#### script pcfinanceiro.sh é uma versão antiga