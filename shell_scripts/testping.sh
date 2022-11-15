#!/bin/bash

index=$1
node_count=$2
private_ip_0=$3
private_ip=$4
private_ip_next=$5
public_ip=$6
echo > ./ping_result.txt
if [ $index -eq $(( $node_count - 1 )) ];then 
    ssh -o StrictHostKeyChecking=no vmadmin@$public_ip "ping -c 2 $private_ip_0" > /dev/null 2>&1
    if [ $? -eq 0 ];then 
        echo "ping from $private_ip to $private_ip_next is successfull" >> ./ping_result.txt 
    else 
        echo "ping from $private_ip to $private_ip_next failed" >> ./ping_result.txt
    fi
else 
    ssh -o StrictHostKeyChecking=no vmadmin@$public_ip "ping -c 2 $private_ip_next" > /dev/null 2>&1
    if [ $? -eq 0 ];then 
        echo "ping from $private_ip to $private_ip_next is successfull" >> ./ping_result.txt
    else 
        echo "ping from $private_ip to $private_ip_next failed" >> ./ping_result.txt
    fi
fi