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

# 4. Ferramentas básicas
confirm "Deseja instalar ferramentas básicas (vim, wget, curl, etc)?" && {
    sudo dnf install -y vim nano wget curl net-tools bash-completion htop
}

# 5. EPEL
confirm "Deseja instalar o repositório EPEL?" && {
    sudo dnf install -y epel-release
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

# 8. Swap
confirm "Deseja criar uma partição de SWAP?" && {
    read -p "Digite o tamanho da SWAP (exemplo: 2G): " swapsize
    sudo fallocate -l $swapsize /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "Swap de $swapsize criada e ativada."
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

echo ""
echo "========================="
echo " FINALIZADO!"
echo "Se fez alterações no SELinux ou Hostname, reinicie o servidor."
echo "========================="
