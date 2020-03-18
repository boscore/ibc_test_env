#!/bin/bash

cluster_init(){
    . init.sh
    . config.sh

    cluster_clear

    cName=config.ini
    lName=logging.json

    for i in a b c d; do
        path=staging/etc/eosio/node_bios_chain_${i}
        mkdir -p $path
        echo "$config_bios_common"              > $path/$cName
        r=config_bios_chain_$i && echo "${!r}" >> $path/$cName
        echo "$logging"                         > $path/$lName
    done

    for i in a2b a2c a2d b c d; do
        path=staging/etc/eosio/node_relay_chain_${i}
        mkdir -p $path
        echo "$config_relay_common" > $path/$cName && echo >> $path/$cName
        r=config_relay_chain_$i && echo "${!r}" >> $path/$cName
        echo "$logging_v" > $path/$lName
    done
}

cluster_clear(){
    killall nodeos 2>/dev/null
    rm *.json *.dot *.ini *.log topology* 2>/dev/null
    rm -rf staging
    rm -rf etc/eosio/node_*
    rm -rf var/lib
}

case "$1"
in
    "init"  )   cluster_init;;
    "clear" )   cluster_clear;;
    *) echo "usage: cluster.sh init|clear" ;;
esac


# Please do not execute this function, each of the following command groups can start a node,
# open four bash shells and execute the following four commands in each one.
nodes_managment(){

    ## ---------  start bios node  ---------

    ## set char first,
    ##  char=a  b  c  or  d
    bios_chain_data=var/lib/node_bios_chain_${char}
    bios_chain_conf=staging/etc/eosio/node_bios_chain_${char}
    ./programs/nodeos/chain_${char}/nodeos -e -p eosio -d $bios_chain_data --config-dir $bios_chain_conf

    ## ---------  start relay node  ---------

    ## set char first,
    ## char=a2b a2c a2d  b  c  d
    relay_chain_data=var/lib/node_relay_chain_${char}
    relay_chain_conf=staging/etc/eosio/node_relay_chain_${char}
    ./programs/ibc-relay/chain_${char}/nodeos  -d $relay_chain_data --config-dir $relay_chain_conf
}

