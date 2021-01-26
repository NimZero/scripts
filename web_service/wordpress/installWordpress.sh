#!/bin/bash

if [ $USER == "root" ]
then
	if [  $# -eq 2 ]
	then
		path=$1
		name=$2
		apacheConf="/etc/apache2/sites-available/$name.conf"
		if [ ! -d $path ]
		then
			echo "directory doesn't exist, creating..."
			mkdir -p $path
			echo "done."
		fi

		cd $path

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
			
			echo "renaming..."
			mv $(pwd)/wordpress $(pwd)/$name
			echo "done."

			path=$(pwd)/$name

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
			echo "DocumentRoot $path" > $apacheConf
			echo "<Directory $path/>" >> $apacheConf
			echo "	DirectoryIndex index.php" >> $apacheConf
			echo "	AllowOverride None" >> $apacheConf
			echo "	Require all granted" >> $apacheConf
			echo "</Directory>" >> $apacheConf
			echo "" >> $apacheConf
			echo "<Directory $path/wp-admin/>" >> $apacheConf
			echo "	AuthName 'WordPress login'" >> $apacheConf
			echo "	AuthType Basic" >> $apacheConf
			echo "	AuthUserFile wp-pswd" >> $apacheConf
			echo "	Require valid-user" >> $apacheConf
			echo "</Directory>" >> $apacheConf
			echo "done."
			
			a2ensite $name.conf
			systemctl reload apache2

			echo "Before configuring wordpress create a database and a user for it."
		fi
	else
		echo "usage: $0 <path> <name>"
	fi
else
	echo "must be run as root"
fi
