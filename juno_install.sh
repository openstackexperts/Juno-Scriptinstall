#!/bin/bash
#This script is to install openstack controller
. config
. controller_prep


while :
do
	echo "###########################################"
	echo -e "\n Which services you need to isntall \n "
	echo -e "For initial system preparation (sys-prepare) \n"
	echo -e "(keystone ,glance ,nova ,neutron ,cinder ,swift ,heat ,ceilometer) \n"
	echo -e " enter exit for exit \n"
	echo "###########################################"
	read service

case $service in

  sys-prepare) 
	networkPart
	repository 
	rabbitMQ
	mysqlSetup
	
	;;
  keystone)
	echo "Installing Keystone"
	keystone	
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
  *)
	echo " I am unable to understand"
esac
done
#echo "creating Database"
