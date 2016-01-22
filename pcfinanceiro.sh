#!/bin/bash

clear

echo 'Vamos as configurações iniciais para a máquina do financeiro...'
echo '------------------------'

# #$$# INICIO Configurar DATA/HORA
echo 'Data/hora no sistema'
date

yum install ntp
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
passwd john

adduser maksoud
echo 'Senha do usuário maksoud'
passwd maksoud

adduser correiar
echo 'Senha do usuário correiar'
passwd correiar

echo 'FEITO | OK'

# #$$# FIM Criar usuários

echo '------------------------'

# #$$# INICIO Instalações
echo 'Vou instalar o Apache + MySQL(mariadb) + PHP + phpMyAdmin + vsFTPd'

yum install -y httpd mariadb-server mariadb php php-mysql
yum install epel-release
yum install phpmyadmin vsftpd

echo 'FEITO | OK'

# #$$# FIM Instalações

echo '------------------------'

# #$$# INICIO Configurar Apache
echo 'Vou configurar o Apache'

systemctl enable httpd.service

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

systemctl start httpd.service

echo 'FEITO | OK'

# #$$# FIM Configurar Apache

echo '------------------------'

# #$$# INICIO Configurar php.ini
echo 'Vou configurar o PHP.INI'

sed -i 's/memory_limit = 128M/memory_limit = 384M/' /etc/httpd/conf/httpd.conf
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/httpd/conf/httpd.conf
sed -i 's/post_max_size = 8M/post_max_size = 8M/' /etc/httpd/conf/httpd.conf
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 2M/' /etc/httpd/conf/httpd.conf

sed -i 's_;date.timezone =_date.timezone = America/Maceio_' /etc/httpd/conf/httpd.conf

systemctl restart httpd

echo 'FEITO | OK'

# #$$# FIM Configurar php.ini

echo '------------------------'

# #$$# INICIO Configurar phpMyAdmin (myad)

# #$$# FIM Configurar phpMyAdmin (myad)

echo '------------------------'

# #$$# INICIO Configurar MySQL

# #$$# FIM Configurar MySQL

echo '------------------------'

# #$$# INICIO Configurar FTP (vsftpd)

# #$$# FIM Configurar FTP (vsftpd)

echo '------------------------'

# #$$# INICIO Bloquear acesso SSH do root

# #$$# FIM Bloquear acesso SSH do root

read -p "Senha do root para o MySQL: " mysqlPassword
read -p "Informe ela novamente(root MySQL): " mysqlPasswordRetype


chkconfig mysql-server on
chkconfig httpd on

/etc/init.d/mysqld restart

while [[ "$mysqlPassword" = "" && "$mysqlPassword" != "$mysqlPasswordRetype" ]]; do
  echo -n "Please enter the desired mysql root password: "
  stty -echo
  read -r mysqlPassword
  echo
  echo -n "Retype password: "
  read -r mysqlPasswordRetype
  stty echo
  echo
  if [ "$mysqlPassword" != "$mysqlPasswordRetype" ]; then
    echo "Passwords do not match!"
  fi
done

/usr/bin/mysqladmin -u root password $mysqlPassword


clear
echo 'Okay.... apache, php and mysql is installed, running and set to your desired password'
