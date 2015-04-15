#!/bin/bash
#This script Contains all the functions to install and configure openstack

set -x

#Including Configuration File
. config

networkPart(){
sed -i "/`hostname`/ i $ipaddress controller" /etc/hosts

}

mysqlSetup(){
	export DEBIAN_FRONTEND=noninteractive
	apt-get install -q mariadb-server python-mysqldb -y
	cp /etc/mysql/my.cnf /etc/mysql/my.cnf.bkp
	sed -i "s/127.0.0.1/  $ipaddress /" /etc/mysql/my.cnf 
	# change storage engine to innodb
	sed -i '/tmpdir/ i default-storage-engine = innodb \
                innodb_file_per_table \
                collation-server = utf8_general_ci\
                init-connect = "'"SET NAMES utf8"'" \
		 character-set-server = utf8 ' /etc/mysql/my.cnf 
	#Restart Server
	
	service mysql restart
	mysqladmin -u root password $MYSQL_PASS
	
}

repository(){
apt-get install python-software-properties -y
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/juno main" > /etc/apt/sources.list.d/ubuntu-cloud-archive-juno-trusty.list
apt-get install ubuntu-cloud-keyring
apt-get update
}

rabbitMQ(){
apt-get install rabbitmq-server -y
rabbitmqctl change_password guest $RABBIT_PASS
}



db_C(){
mysql -u $MYSQL_USER -p$MYSQL_PASS << EODs
CREATE DATABASE $service;
GRANT ALL PRIVILEGES ON $service.* TO '$service'@'localhost' \
  IDENTIFIED BY '$SERVICE_PASS';
GRANT ALL PRIVILEGES ON $service.* TO '$service'@'%' \
  IDENTIFIED BY '$SERVICE_PASS';
EODs
}


keystone(){
SERVICE_PASS="$KEYSTONE_PASS"
	db_C
	apt-get install keystone python-keystoneclient -y
	cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.old
	sed -i "s/#admin_token/admin_token=$ADMINTOKEN /g" /etc/keystone/keystone.conf 
	sed -i "s/connection=sqlite:\/\/\/\/var\/lib\/keystone\/keystone.db/connection=mysql:\/\/keystone:keystone@controller\/keystone /g" /etc/keystone/keystone.conf
	sed -i 's/#verbose=false/verbose=true /g' /etc/keystone/keystone.conf
	keystone-manage db_sync
	rm -f /var/lib/keystone/keystone.db
	service keystone restart
}

glance(){
SERVICE_PASS="$GLANCE_PASS"
	db_C
}

nova(){
SERVICE_PASS="$NOVA_PASS"
	db_C
}

neutron(){
SERVICE_PASS="$NEUTRON_PASS"
	db_C
}

cinder(){
SERVICE_PASS="$CINDER_PASS"
	db_C

}

swift(){
SERVICE_PASS="$SWIFT_PASS"
	db_C
}

heat(){
SERVICE_PASS="$HEAT_PASS"
	db_C
}

ceilometer(){
SERVICE_PASS="$CEILOMETER_PASS"
	db_C

}




while :
do
	echo " Which service you need to isntall "
	echo -e "\n"
	echo "keystone,glance,nova,neutron,cinder,swift,heat,ceilometer"
	echo -e "\n"	
	echo " enter 0 for exit"
	echo -e "\n"
	read service

case $service in
  keystone)
	echo "Keystone"	
	;;
  glance)
	echo "glance"
	;;
  nova)
	echo "nova"
	;;
  neutron)
	echo "neutron"
	;;
  cinder)
	echo "Cinder"
	;;
  swift)
	echo "Swift"
	;;
  heat)
	echo "heat"
	;;
  ceilometer)
	echo "Ceilometer"
	;;	
   exit)
	echo " Thank You"
	break

	;;
  default)
	echo " I am unable to understand"
esac
done
#echo "creating Database"




