#!/bin/bash

## . ./../env.sh

cluster_init(){
    cluster_clear 2>/dev/null

    program_dir=./programs
    if [ -d ${program_dir} ]; then rm -rf ${program_dir}; fi
    mkdir -p ${program_dir}/nodeos
    cur_path=`pwd`
    bn=`basename $cur_path`
    if [ "$bn" == "chain_A" ]; then
        cp $chain_A_nodeos ${program_dir}/nodeos
    elif [ "$bn" == "chain_B" ]; then
        cp $chain_B_nodeos ${program_dir}/nodeos
    else
        echo "error! you must run this command in directory 'chain_A' or 'chain_B'" && exit
    fi

    now=`date -u +%Y-%m-%dT%H:%M:%S.000`

    src_config=./config.sh
    if [ -f ./config_docker.sh ]; then src_config=./config_docker.sh ;fi
    sed 's/"initial_timestamp": ".*/"initial_timestamp": "'$now'",/g' $src_config > ./config_gen.sh
    . config_gen.sh
    rm config_gen.sh
    if [ -f ./config_docker.sh ]; then rm ./config_docker.sh ;fi

    cName=config.ini
    lName=logging.json
    gName=genesis.json

    path=staging/etc/eosio/node_bios
    mkdir -p $path
    echo "$configbios"  > $path/$cName
    echo "$logging"     > $path/$lName
    echo "$genesis"     > $path/$gName

    for i in `seq -w 00 50`; do
        path=staging/etc/eosio/node_$i
        mkdir -p $path
        c=config$i  && echo "${!c}"     > $path/$cName
        echo "$config_common"          >> $path/$cName
        #echo "produce-time-offset-us=$(($RANDOM*100-1638400))"               >> $path/$cName         ###
        #for j in `seq -w 00 21`; do echo "p2p-peer-address = localhost:99$j" >> $path/$cName ;done   ###
        l=logging && echo "${!l}"       > $path/$lName
        echo "$genesis"                 > $path/$gName
    done
}

pnodes=1
total_nodes=22
delay=0 # 0 or 1 second

cluster_start(){
    $eosio_launcher -p $pnodes -n $total_nodes --nogen -d $delay --nodeos "--max-transaction-time 1000"
}

cluster_clear(){
    $eosio_launcher -k 15 2>/dev/null
    rm *.json *.dot *.ini *.log topology* 2>/dev/null
    rm -rf staging
    rm -rf etc/eosio/node_*
    rm -rf var/lib
}

cluster_down(){
    if [ "$1" == "" ]; then echo "no argument is provided" && return; fi
    $eosio_launcher  --network-name node_  --nodes ${total_nodes}  --down $@  1>/dev/null
}

cluster_up(){
    if [ "$1" == "" ]; then echo "no argument is provided" && return; fi
    $eosio_launcher  --network-name node_  --nodes ${total_nodes} --nodeos "" --bounce $@  1>/dev/null
}

cluster_check(){
    . ./config_port.sh
    echo "node     head_block_num"
    echo "-----------------------"
    echo "bios    " `$cleos -u http://127.0.0.1:${bios_http_port} get info | jq .head_block_num`
    for i in `seq 0 $(($total_nodes-1))`; do
        port=$((${node_http_base_port}+$i))
        echo node "$i  " `$cleos -u http://127.0.0.1:${port} get info | jq .head_block_num`
    done
}

watch_log(){
    if [ "$1" == "" ]; then echo "no argument is provided" && return; fi
    num=$1
    if [ $1 -lt 10 ]; then num=0$1; fi
    tail -f ./var/lib/node_${num}/stderr.txt
}

case "$1"
in
    "init"  )   cluster_init;;
    "start" )   cluster_start;;
    "down"  )   shift && cluster_down $@;;
    "up"    )   shift && cluster_up $@;;
    "check" )   cluster_check;;
    "log"   )   shift && watch_log $@;;
    "clear" )   cluster_clear;;
    *) echo "usage: cluster.sh command [arg]
commands:
    init        initialize the environment
    start       start the blockchain
    down arg    comma-separated list of node numbers, taken down nodes
    up arg      comma-separated list of node numbers, bounce up nodes
    check       check nodes status
    log arg     node number, watch log of one node
    clear       clear environment " ;;
esac
