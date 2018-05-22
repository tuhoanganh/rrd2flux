#!/bin/bash
echo "#############################" 
echo "########## IfCheck ##########"  
echo "#############################"  
sh ./both/migrate_ifcheck.sh  

echo "#############################"  
echo "########### ping4 ###########"  
echo "#############################"  
sh ./both/migrate_ping4.sh  

echo "#############################"  
echo "########### Delay ###########"  
echo "#############################"  
sh ./both/migrate_delay.sh  

echo "#############################"  
echo "########### Jitter ##########"  
echo "#############################"  
sh ./both/migrate_jitter.sh  

echo "#############################"  
echo "########## pktLoss ##########"  
echo "#############################"  
sh ./both/migrate_pktloss.sh  

echo "#############################"  
echo "########### CPU MX ##########"  
echo "#############################"  
sh ./mx/migrate_cpu_mx.sh  

echo "#############################"  
echo "######### Memory MX #########"  
echo "#############################"  
sh ./mx/migrate_memory_mx.sh  

echo "#############################"  
echo "####### Temperature MX ######"  
echo "#############################"  
sh ./mx/migrate_temperature_mx.sh  

echo "#############################"  
echo "########### CPU ACX #########"  
echo "#############################"  
sh ./acx/migrate_cpu_acx.sh  

echo "#############################"  
echo "######## Memory ACX #########"  
echo "#############################"  
sh ./acx/migrate_memory_acx.sh  

echo "#############################"  
echo "###### Temperature ACX ######"  
echo "#############################"  
sh ./acx/migrate_temperature_acx.sh  
