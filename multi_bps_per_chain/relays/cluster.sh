#!/bin/bash

. ./../../env.sh
. config.sh

cluster_init(){
    cluster_clear

    program_dir=./programs
    if [ -d ${program_dir} ]; then rm -rf ${program_dir}; fi
    mkdir -p ${program_dir}/ibc-relay/chain_A
    mkdir -p ${program_dir}/ibc-relay/chain_B
    cp $chain_A_relay ${program_dir}/ibc-relay/chain_A
    cp $chain_B_relay ${program_dir}/ibc-relay/chain_B

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
    data_relay_chain_A=var/lib/node_relay1_chain_A
    conf_relay_chain_A=staging/etc/eosio/node_relay1_chain_A
    ./programs/ibc-relay/chain_A/nodeos  -d $data_relay_chain_A --config-dir $conf_relay_chain_A --genesis-json staging/etc/eosio/node_relay1_chain_A/genesis.json


    # run following commands in shell 2
    echo "starting relay node of chain B"
    data_relay_chain_B=var/lib/node_relay1_chain_B
    conf_relay_chain_B=staging/etc/eosio/node_relay1_chain_B
    ./programs/ibc-relay/chain_B/nodeos  -d $data_relay_chain_B --config-dir $conf_relay_chain_B --genesis-json staging/etc/eosio/node_relay1_chain_B/genesis.json

}

relay_channel_2(){
    # run following commands in shell 3
    echo "starting relay node of chain A"
    data_relay_chain_A=var/lib/node_relay2_chain_A
    conf_relay_chain_A=staging/etc/eosio/node_relay2_chain_A
    ./programs/ibc-relay/chain_A/nodeos  -d $data_relay_chain_A --config-dir $conf_relay_chain_A --genesis-json staging/etc/eosio/node_relay2_chain_A/genesis.json


    # run following commands in shell 4
    echo "starting relay node of chain B"
    data_relay_chain_B=var/lib/node_relay2_chain_B
    conf_relay_chain_B=staging/etc/eosio/node_relay2_chain_B
    ./programs/ibc-relay/chain_B/nodeos  -d $data_relay_chain_B --config-dir $conf_relay_chain_B --genesis-json staging/etc/eosio/node_relay2_chain_B/genesis.json

}

























