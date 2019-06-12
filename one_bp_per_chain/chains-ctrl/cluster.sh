#!/bin/bash

cluster_init(){
    . init.sh
    . config.sh

    cluster_clear

    cName=config.ini
    lName=logging.json

    for i in A B; do
        path=staging/etc/eosio/node_bios_chain_${i}
        mkdir -p $path
        echo "$config_bios_common"              > $path/$cName
        r=config_bios_chain_$i && echo "${!r}" >> $path/$cName
        echo "$logging"                         > $path/$lName
    done

    for i in A B; do
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
    # run following commands in shell 1
    echo "starting bios node of chain A"
    data_bios_chain_A=var/lib/node_bios_chain_A
    conf_bios_chain_A=staging/etc/eosio/node_bios_chain_A
    ./programs/nodeos/chain_A/nodeos -e -p eosio -d $data_bios_chain_A --config-dir $conf_bios_chain_A


    # run following commands in shell 2
    echo "starting bios node of chain B"
    data_bios_chain_B=var/lib/node_bios_chain_B
    conf_bios_chain_B=staging/etc/eosio/node_bios_chain_B
    ./programs/nodeos/chain_B/nodeos -e -p eosio -d $data_bios_chain_B --config-dir $conf_bios_chain_B


    # run following commands in shell 3
    echo "starting relay node of chain A"
    data_relay_chain_A=var/lib/node_relay_chain_A
    conf_relay_chain_A=staging/etc/eosio/node_relay_chain_A
    ./programs/ibc-relay/chain_A/nodeos  -d $data_relay_chain_A --config-dir $conf_relay_chain_A


    # run following commands in shell 4
    echo "starting relay node of chain B"
    data_relay_chain_B=var/lib/node_relay_chain_B
    conf_relay_chain_B=staging/etc/eosio/node_relay_chain_B
    ./programs/ibc-relay/chain_B/nodeos -d $data_relay_chain_B --config-dir $conf_relay_chain_B
}

