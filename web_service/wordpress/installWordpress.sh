#!/bin/bash

if [ $USER == "root" ]
then
	if [  $# -eq 1 ]
	then
		path=$1
		if [ ! -d $path ]
		then
			echo "directory doesn't exist, creating..."
			mkdir -p $path
			echo "done."
		fi

		cd $path

		path=$(pwd)/wordpress

		if [ -d $path ]
		then
			echo "$path already exists aborting..."
		else
			echo "downloading wordpress..."
			wget -q https://wordpress.org/latest.tar.gz
			echo "done."

			echo "extracting..."
			tar -xzf latest.tar.gz
			echo "done."

			echo "removing archive.."
			rm latest.tar.gz
			echo "done."

			echo "changing owner..."
			chown -R -f www-data:www-data $path
			echo "done."

			echo "create user and password to access /wp-admin"
			echo "enter user: "
			read user
			echo "enter password: "
			read pswd
			echo "creating user file..."
			htpasswd -cb /etc/apache2/wp-pswd $user $pswd
			echo "done."

			echo "creating apache configuration..."
			echo "DocumentRoot $path" > /etc/apache2/sites-available/wordpress.conf
			echo "<Directory $path/>" >> /etc/apache2/sites-available/wordpress.conf
			echo "	DirectoryIndex index.php" >> /etc/apache2/sites-available/wordpress.conf
			echo "	AllowOverride None" >> /etc/apache2/sites-available/wordpress.conf
			echo "	Require all granted" >> /etc/apache2/sites-available/wordpress.conf
			echo "</Directory>" >> /etc/apache2/sites-available/wordpress.conf
			echo "" >> /etc/apache2/sites-available/wordpress.conf
			echo "<Directory $path/wp-admin/>" >> /etc/apache2/sites-available/wordpress.conf
			echo "	AuthName 'WordPress login'" >> /etc/apache2/sites-available/wordpress.conf
			echo "	AuthType Basic" >> /etc/apache2/sites-available/wordpress.conf
			echo "	AuthUserFile wp-pswd" >> /etc/apache2/sites-available/wordpress.conf
			echo "	Require valid-user" >> /etc/apache2/sites-available/wordpress.conf
			echo "</Directory>" >> /etc/apache2/sites-available/wordpress.conf
			echo "done."

			echo "You need to enable wordpress.conf in apache2, before configuring wordpress create a database and a user for it."
		fi
	else
		echo "specifier le chemin d'instalation."
	fi
else
	echo "must be run as root"
fi
