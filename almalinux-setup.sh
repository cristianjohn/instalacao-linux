#!/bin/bash

echo "========================="
echo " ALMALINUX 10 SETUP SCRIPT"
echo "========================="
echo ""

# Função para confirmar ações
confirm() {
    read -p "$1 (s/n): " choice
    case "$choice" in
        s|S ) return 0;;
        * ) return 1;;
    esac
}

# 1. Atualização do sistema
confirm "Deseja atualizar o sistema agora?" && sudo dnf update -y

# 2. Hostname
read -p "Digite o hostname desejado: " new_hostname
if [ ! -z "$new_hostname" ]; then
    sudo hostnamectl set-hostname "$new_hostname"
    echo "Hostname configurado para: $new_hostname"
fi

# 3. Timezone
confirm "Deseja configurar o timezone?" && {
    timedatectl list-timezones | less
    read -p "Digite o timezone (ex: America/Sao_Paulo): " timezone
    sudo timedatectl set-timezone "$timezone"
    echo "Timezone configurado para: $timezone"
}

# 4. EPEL
confirm "Deseja instalar o repositório EPEL?" && {
    sudo dnf install -y epel-release
}

# 5. Ferramentas básicas
confirm "Deseja instalar ferramentas básicas (vim, wget, curl, etc)?" && {
    sudo dnf install -y vim nano wget curl net-tools bash-completion htop
}

# 6. Firewalld
confirm "Deseja ativar e configurar o firewall (HTTP, HTTPS, SSH)?" && {
    sudo systemctl enable --now firewalld
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --permanent --add-service=ssh
    sudo firewall-cmd --reload
    echo "Firewall configurado."
}

# 7. SELinux
confirm "Deseja desativar o SELinux? (Requer reboot depois)" && {
    sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    echo "SELinux desativado no próximo reboot."
}

# 8. Swap (com sugestão automática)
confirm "Deseja criar ou recriar a SWAP?" && {

    # Detectar quantidade de RAM em MB
    total_mem=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')

    # Sugerir tamanho de swap com base na RAM
    if [ "$total_mem" -lt 2000 ]; then
        suggested_swap="2G"
    elif [ "$total_mem" -lt 4000 ]; then
        suggested_swap="3G"
    elif [ "$total_mem" -lt 8000 ]; then
        suggested_swap="4G"
    else
        suggested_swap="2G"
    fi

    echo "Memória detectada: ${total_mem} MB (~$((${total_mem}/1024)) GB)"
    echo "Tamanho de SWAP sugerido: $suggested_swap"

    read -p "Digite o tamanho desejado para a SWAP (exemplo: 2G) ou pressione Enter para usar o sugerido [$suggested_swap]: " swapsize
    swapsize=${swapsize:-$suggested_swap}

    # Desativa swap existente se houver
    sudo swapoff -a 2>/dev/null

    # Remove swapfile anterior, se existir
    sudo rm -f /swapfile

    # Cria nova swap
    sudo fallocate -l $swapsize /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile

    # Garante persistência no fstab
    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

    echo "✅ Swap de $swapsize criada e ativada."
}

# 9. Usuário administrativo
confirm "Deseja criar um novo usuário administrador com sudo?" && {
    read -p "Digite o nome do novo usuário: " new_user
    sudo adduser "$new_user"
    sudo passwd "$new_user"
    sudo usermod -aG wheel "$new_user"
    echo "Usuário $new_user criado e adicionado ao grupo sudo."
}

# 10. Instalação do NGINX
confirm "Deseja instalar o NGINX?" && {
    sudo dnf install -y nginx
    sudo systemctl enable --now nginx
    echo "NGINX instalado e iniciado."
}

# 11. Instalação do MariaDB
confirm "Deseja instalar o MariaDB?" && {
    sudo dnf install -y mariadb-server
    sudo systemctl enable --now mariadb
    sudo mysql_secure_installation
    echo "MariaDB instalado e seguro."
}

# 12. Configuração da porta SSH
confirm "Deseja alterar a porta padrão do SSH?" && {
    read -p "Digite a nova porta SSH (exemplo: 2222): " ssh_port

    # Validar se é número
    if [[ "$ssh_port" =~ ^[0-9]+$ ]]; then
        # Faz backup do sshd_config antes
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bkp

        # Altera a porta no sshd_config (se linha existir ou comentada)
        sudo sed -i "/^#Port /c\Port $ssh_port" /etc/ssh/sshd_config
        sudo sed -i "/^Port /c\Port $ssh_port" /etc/ssh/sshd_config

        # Libera nova porta no firewall
        sudo firewall-cmd --permanent --add-port=$ssh_port/tcp
        sudo firewall-cmd --reload

        # Reinicia o SSH
        sudo systemctl restart sshd

        echo "✅ Porta SSH alterada para $ssh_port e liberada no firewall."

        echo "⚠️ Importante: Abra uma nova sessão SSH de teste antes de encerrar a atual, para evitar perda de acesso."
    else
        echo "❌ Valor inválido. Porta SSH não alterada."
    fi
}

# 13. Instalar o QEMU Guest Agent (importante para VMs)
confirm "Deseja instalar o QEMU Guest Agent?" && {
    sudo dnf install -y qemu-guest-agent
    sudo systemctl enable --now qemu-guest-agent
    echo "✅ QEMU Guest Agent instalado e iniciado."
}


echo ""
echo "========================="
echo " FINALIZADO!"
echo "Se fez alterações no SELinux ou Hostname, reinicie o servidor."
echo "========================="
