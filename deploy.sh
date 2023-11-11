#!/bin/bash

  sudo apt update 
# Comprobar si esta instalado  git 
echo Comprobar si esta instalado  

if dpkg -l | grep -q git ; then 
   echo " 	[*] Git Instalado"
else
  sudo apt install git -y
  echo " 	[*] Git instalado"  
fi

#
# 	 comprobar si esta instalado MariaDB
#

echo Comprobar si esta installado MariaDB 

if dpkg -l | grep -q mariadb-server; then 
  echo " 	[*] MariaDB instalado $?" 
else 
  echo " 	[x] MariaDB no esta instalado $?"
  echo "Instalado MariaDB... "
  sudo apt install -y mariadb-server > /dev/null 2>&1
  echo " 	[*] MariaDB Instalado"

#
# 	Activar los servicios 
#

  sudo systemctl start mariadb > /dev/null 2>&1
  sudo systemctl enable mariadb > /dev/null 2>&1
  sudo systemctl status mariadb | grep -i "active (running)" > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo "El servicio de MariaDB está en ejecución."
    sleep 1
    echo Configurar la bases de datos .. 
  
    mysql -e "
    CREATE DATABASE devopstravel;
    CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
    GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
    FLUSH PRIVILEGES;
  "
#
#  	Comprobra si exite el archivo  .sql 
# 	si no se encuentra de descargar desde el repositorio 
#
    sleep 1
    echo "Comprobra si esta el sql... "
    if [ ! -e bootcamp-devops-2023/app-295devops-travel/database/devopstravel.sql ]; then 
	echo "descargado el sql..."
	git clone --branch clase2-linux-bash https://github.com/roxsross/bootcamp-devops-2023.git
    fi
  fi
  sleep 1 
  echo " 	 [*] 	Agrego la bases de datos" 
  mysql < bootcamp-devops-2023/app-295devops-travel/database/devopstravel.sql
fi 

#
# 	Instalado el PHP y apache2
#

if dpkg -s apache2 > /dev/null 2>&1; then
  echo -e " 	 [*] 	El apache esta instalado"
else 
  echo "Instalado el apache ...."
  sudo apt install apache2 -y > /dev/null 2>&1
  sudo apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl > /dev/null 2>&1
    
  sudo systemctl start apache2 > /dev/null 2>&1
  sudo systemctl enable apache2 > /dev/null 2>&1
  sudo systemctl status apache2 | grep -i "active (running)" > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
      echo "El servicio de Apache2 está en ejecución."
  else
      echo "El servicio de Apache2 no está en ejecución."
  fi

  version=$(php -v | grep -oP '(?<=PHP )([0-9]+\.[0-9]+\.[0-9]+)')
  echo " 	 [*] Instalado php ${version}"
 #
 # 	Actualizar apache2 para leer el index.php
 #
  if [ -e /etc/apache2/mods-enabled/dir.conf ]; then 
      cp /etc/apache2/mods-enabled/dir.conf /etc/apache2/mods-enabled/dir.conf.bak
      sed -i "/<IfModule mod_dir.c>/,/<\/IfModule>/ s/\(DirectoryIndex\s*\)\(.*\)/\1$2 "index.php"/" /etc/apache2/mods-enabled/dir.conf
      echo "La fichero actualizado de DirectoryIndex en Apache en php"
  fi

fi


 sudo systemctl reload apache2
 #
 # 	Comprobar si esta actualizado el repositorio
 #

 if [ -e bootcamp-devops-2023/ ]; then
   cd bootcamp-devops-2023/ || exit 1 
   echo "Esta Actualizado el repositorio..."
   git pull 
   sudo cp -r app-295devops-travel/* /var/www/html/
else 
  echo "Clonado el repositorio "
  sudo cp -r app-295devops-travel/* /var/www/html/
fi 


 sudo systemctl reload apache2

