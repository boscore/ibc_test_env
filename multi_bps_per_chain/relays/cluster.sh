#!/bin/bash

. ./../../env.sh
. config.sh

cluster_init(){
    cluster_clear

    program_dir=./programs
    if [ -d ${program_dir} ]; then rm -rf ${program_dir}; fi
    mkdir -p ${program_dir}/ibc-relay/chain_a
    mkdir -p ${program_dir}/ibc-relay/chain_b
    cp $chain_a_relay ${program_dir}/ibc-relay/chain_a
    cp $chain_b_relay ${program_dir}/ibc-relay/chain_b

    cName=config.ini
    lName=logging.json

    for i in A B; do
        path=staging/etc/eosio/node_relay1_chain_${i}
        mkdir -p $path
        echo "$config_relay_common" > $path/$cName && echo >> $path/$cName
        r=config_relay1_chain_$i && echo "${!r}" >> $path/$cName
        echo "$logging_v" > $path/$lName
    done

    for i in A B; do
        path=staging/etc/eosio/node_relay2_chain_${i}
        mkdir -p $path
        echo "$config_relay_common" > $path/$cName && echo >> $path/$cName
        r=config_relay2_chain_$i && echo "${!r}" >> $path/$cName
        echo "$logging_v" > $path/$lName
    done

     for i in A B; do
         cp ../chain_${i}/staging/etc/eosio/node_00/genesis.json  staging/etc/eosio/node_relay1_chain_${i}/genesis.json
         cp ../chain_${i}/staging/etc/eosio/node_00/genesis.json  staging/etc/eosio/node_relay2_chain_${i}/genesis.json
     done
}

cluster_clear(){
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


# Please do not execute bellow functions directly
relay_channel_1(){
    # run following commands in shell 1
    echo "starting relay node of chain A"
    data_relay_chain_a=var/lib/node_relay1_chain_a
    conf_relay_chain_a=staging/etc/eosio/node_relay1_chain_a
    ./programs/ibc-relay/chain_a/nodeos  -d $data_relay_chain_a --config-dir $conf_relay_chain_a --genesis-json staging/etc/eosio/node_relay1_chain_a/genesis.json


    # run following commands in shell 2
    echo "starting relay node of chain B"
    data_relay_chain_b=var/lib/node_relay1_chain_b
    conf_relay_chain_b=staging/etc/eosio/node_relay1_chain_b
    ./programs/ibc-relay/chain_b/nodeos  -d $data_relay_chain_b --config-dir $conf_relay_chain_b --genesis-json staging/etc/eosio/node_relay1_chain_b/genesis.json

}

relay_channel_2(){
    # run following commands in shell 3
    echo "starting relay node of chain A"
    data_relay_chain_a=var/lib/node_relay2_chain_a
    conf_relay_chain_a=staging/etc/eosio/node_relay2_chain_a
    ./programs/ibc-relay/chain_a/nodeos  -d $data_relay_chain_a --config-dir $conf_relay_chain_a --genesis-json staging/etc/eosio/node_relay2_chain_a/genesis.json


    # run following commands in shell 4
    echo "starting relay node of chain B"
    data_relay_chain_b=var/lib/node_relay2_chain_b
    conf_relay_chain_b=staging/etc/eosio/node_relay2_chain_b
    ./programs/ibc-relay/chain_b/nodeos  -d $data_relay_chain_b --config-dir $conf_relay_chain_b --genesis-json staging/etc/eosio/node_relay2_chain_b/genesis.json

}

























