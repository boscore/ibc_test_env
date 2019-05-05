#!/bin/bash

. init.sh
. config.sh

cluster_init(){
    cluster_clear

    cName=config.ini
    lName=logging.json

    for i in A B; do
        path=staging/etc/eosio/node_bios_chain_${i}
        mkdir -p $path
        r=config_bios_chain_$i && echo "${!r}" > $path/$cName
        echo "$logging" > $path/$lName
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
    ./programs/nodeos/chain-A/nodeos -e -p eosio -d $data_bios_chain_A --config-dir $conf_bios_chain_A  \
        --plugin eosio::chain_api_plugin --plugin eosio::producer_plugin  \
        --plugin eosio::producer_api_plugin --plugin eosio::history_api_plugin  \
        --contracts-console  --max-transaction-time 1000


    # run following commands in shell 2
    echo "starting bios node of chain B"
    data_bios_chain_B=var/lib/node_bios_chain_B
    conf_bios_chain_B=staging/etc/eosio/node_bios_chain_B
    ./programs/nodeos/chain-B/nodeos -e -p eosio -d $data_bios_chain_B --config-dir $conf_bios_chain_B  \
        --plugin eosio::chain_api_plugin --plugin eosio::producer_plugin  \
        --plugin eosio::producer_api_plugin --plugin eosio::history_api_plugin  \
        --contracts-console  --max-transaction-time 1000


    # run following commands in shell 3
    echo "starting relay node of chain A"
    data_relay_chain_A=var/lib/node_relay_chain_A
    conf_relay_chain_A=staging/etc/eosio/node_relay_chain_A
    ./programs/ibc-relay/chain-A/nodeos  -d $data_relay_chain_A --config-dir $conf_relay_chain_A  \
        --plugin eosio::chain_api_plugin --contracts-console  --max-transaction-time 1000


    # run following commands in shell 4
    echo "starting relay node of chain B"
    data_relay_chain_B=var/lib/node_relay_chain_B
    conf_relay_chain_B=staging/etc/eosio/node_relay_chain_B
    ./programs/ibc-relay/chain-B/nodeos -d $data_relay_chain_B --config-dir $conf_relay_chain_B  \
        --plugin eosio::chain_api_plugin --contracts-console  --max-transaction-time 1000

}

