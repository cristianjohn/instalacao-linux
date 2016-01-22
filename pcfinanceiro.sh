#!/bin/bash

clear

echo 'Vamos as configurações iniciais para a máquina do financeiro...'
echo '------------------------'

# #$$# INICIO Configurar DATA/HORA
echo 'Data/hora no sistema'
date

yum install -y ntp
ntpdate 0.centos.pool.ntp.org
service ntpd start
chkconfig ntpd on

rm -f /etc/localtime
ln -s /usr/share/zoneinfo/America/Maceio /etc/localtime

echo 'Data/hora agora é BR (Maceió)'
date
# #$$# FIM Configurar DATA/HORA

echo '------------------------'

# #$$# INICIO Criar usuários
echo 'Vamos criar os usuários'

adduser john
echo 'Senha do usuário john'
#passwd john
gpasswd -a john wheel

adduser maksoud
echo 'Senha do usuário maksoud'
#passwd maksoud
gpasswd -a maksoud wheel

adduser correiar
echo 'Senha do usuário correiar'
#passwd correiar
usermod -s /sbin/nologin correiar

echo 'FEITO | OK'
# #$$# FIM Criar usuários

echo '------------------------'

# #$$# INICIO Instalações
echo 'Vou instalar o Apache + MySQL(mariadb) + PHP + phpMyAdmin + vsFTPd'

yum install -y httpd mariadb-server mariadb php php-mysql vim
yum install -y epel-release
yum install -y phpmyadmin vsftpd

echo 'FEITO | OK'
# #$$# FIM Instalações

echo '------------------------'

# #$$# INICIO Configurar Apache
echo 'Vou configurar o Apache'

sed -i 's_DocumentRoot /var/www/html_DocumentRoot /home/correiar_' /etc/httpd/conf/httpd.conf
echo "
<Directory "/home/correiar">
   Options Indexes FollowSymLinks MultiViews

   AllowOverride All
   Order allow,deny
   allow from all

   <RequireAny>
      Require all granted
   </RequireAny>
</Directory>" >> /etc/httpd/conf/httpd.conf

usermod -g apache correiar
chown -R apache:apache /home/correiar
chmod -R g+w /home/correiar

systemctl start httpd.service
systemctl enable httpd.service

echo 'FEITO | OK'
# #$$# FIM Configurar Apache

echo '------------------------'

# #$$# INICIO Configurar php.ini
echo 'Vou configurar o PHP.INI'

sed -i 's/memory_limit = 128M/memory_limit = 384M/' /etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 8M/' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 2M/' /etc/php.ini

sed -i 's_;date.timezone =_date.timezone = America/Maceio_' /etc/php.ini

systemctl restart httpd
echo 'FEITO | OK'
# #$$# FIM Configurar php.ini

echo '------------------------'

# #$$# INICIO Configurar phpMyAdmin (myad)
echo 'Vou configurar o phpMyAdmin (myad)'

#sed -i 's_Alias /phpMyAdmin_Alias /myad_' /etc/httpd/conf.d/phpMyAdmin.conf
#sed -i 's_Alias /phpmyadmin_#Alias /phpmyadmin_' /etc/httpd/conf.d/phpMyAdmin.conf

#sed -i 's_# Apache 2.4\n<RequireAny>\nRequire ip 127.0.0.1\nRequire ip ::1\n</RequireAny>_# Apache 2.4\n<RequireAny>\nRequire all granted\n</RequireAny>_' /etc/httpd/conf.d/phpMyAdmin.conf

echo "# phpMyAdmin - Web based MySQL browser written in php
# 
# Allows only localhost by default
#
# But allowing phpMyAdmin to anyone other than localhost should be considered
# dangerous unless properly secured by SSL

#Alias /phpMyAdmin /usr/share/phpMyAdmin
Alias /myad /usr/share/phpMyAdmin

<Directory /usr/share/phpMyAdmin/>
   AddDefaultCharset UTF-8

   <IfModule mod_authz_core.c>
     # Apache 2.4
     <RequireAny>
       Require all granted
     </RequireAny>
   </IfModule>
   <IfModule !mod_authz_core.c>
     # Apache 2.2
     Order Deny,Allow
     Deny from All
     Allow from 127.0.0.1
     Allow from ::1
   </IfModule>
</Directory>

<Directory /usr/share/phpMyAdmin/setup/>
   <IfModule mod_authz_core.c>
     # Apache 2.4
     <RequireAny>
       Require ip 127.0.0.1
       Require ip ::1
     </RequireAny>
   </IfModule>
   <IfModule !mod_authz_core.c>
     # Apache 2.2
     Order Deny,Allow
     Deny from All
     Allow from 127.0.0.1
     Allow from ::1
   </IfModule>
</Directory>

# These directories do not require access over HTTP - taken from the original
# phpMyAdmin upstream tarball
#
<Directory /usr/share/phpMyAdmin/libraries/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>

<Directory /usr/share/phpMyAdmin/setup/lib/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>

<Directory /usr/share/phpMyAdmin/setup/frames/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>
" > /etc/httpd/conf.d/phpMyAdmin.conf

systemctl restart httpd
echo 'FEITO | OK'
# #$$# FIM Configurar phpMyAdmin (myad)

echo '------------------------'

# #$$# INICIO Configurar MySQL
echo 'Vou configurar o MySQL (mariadb) iniciando o mysql_secure_installation'

systemctl start mariadb
mysql_secure_installation
systemctl enable mariadb.service

echo 'FEITO | OK'
# #$$# FIM Configurar MySQL

echo '------------------------'

# #$$# INICIO Configurar FTP (vsftpd)
echo 'Vou configurar FTP (vsftpd)'

sed -i 's/anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf
sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/listen=NO/listen=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/listen_ipv6=YES/listen_ipv6=NO/' /etc/vsftpd/vsftpd.conf

echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf
echo "john
maksoud" >> /etc/vsftpd/ftpusers 

systemctl restart vsftpd
systemctl enable vsftpd

echo 'FEITO | OK'
# #$$# FIM Configurar FTP (vsftpd)

echo '------------------------'

# #$$# INICIO Bloquear acesso SSH do root
echo 'Vou bloquear acesso via SSH do root'

sed -i 's_#PermitRootLogin yes_PermitRootLogin no_' /etc/ssh/sshd_config
systemctl reload sshd

echo 'FEITO | OK'
# #$$# FIM Bloquear acesso SSH do root

# #$$# INICIO Configurar Firewall
echo 'Vou configurar o Firewall e o selinux '

setenforce 0
sed -i 's_SELINUX=enforcing_SELINUX=disabled_' /etc/sysconfig/selinux
sed -i 's_SELINUX=enforcing_SELINUX=disabled_' /etc/selinux/config

firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=21/tcp --permanent

firewall-cmd --reload

read -p "Quer desativar o firewall S ou N: " desativarFirewall
if [ "$desativarFirewall" == "S" ]; then
   systemctl stop firewalld
   systemctl disable firewalld
   
   echo "Firewall Parado e Desabilitado"
fi
echo 'FEITO | OK'
# #$$# FIM Configurar Firewall


echo 'Ok... tudo aparentemente pronto, vá testar ;)'
