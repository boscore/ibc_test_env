#!/usr/bin/env bash

## ./init.sh

setup_system_contracts_and_issue_token(){
    char=`echo $1 | cut -c 7`

    cleos=cleos_${char}
    var=chain_${char}_token_sym         && sym=${!var}
    var=chain_${char}_sys_contracts_dir && sys_contracts_dir=${!var}


    # step 1: set contract eosio.bios
    ${!cleos} set contract eosio ${sys_contracts_dir}/eosio.bios -p eosio

    # step 2: create system accounts
    sleep .5
    for account in eosio.token eosio.msig eosio.ram eosio.ramfee eosio.stake \
                   eosio.bpay eosio.vpay eosio.names eosio.saving eosio.rex
    do
        echo -e "\n creating $account \n";
        ${!cleos} create account eosio ${account} EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV -p eosio -x 1000
        sleep .2
    done

    # step 3: set contract
    echo step 3
    ${!cleos} set contract eosio.token ${sys_contracts_dir}/eosio.token -p eosio.token
    ${!cleos} set contract eosio.msig ${sys_contracts_dir}/eosio.msig -p eosio.msig

    # step 4: create and issue token
    echo step 4
    ${!cleos} push action eosio.token create '["eosio", "10000000000.0000 '$sym'"]' -p eosio.token
    ${!cleos} push action eosio.token issue '["eosio",  "1000000000.0000 '$sym'", "memo"]' -p eosio

    #setp 5: setting privileged account for eosio.msig
    ${!cleos} push action eosio setpriv '{"account": "eosio.msig", "is_priv": 1}' -p eosio

    # step 6: set contract eosio.system
    sleep .5
    ${!cleos} set contract eosio ${sys_contracts_dir}/eosio.system -x 1000 -p eosio
    ${!cleos} push action eosio init '[0, "4,'$sym'"]' -p eosio

}
setup_system_contracts_and_issue_token chain_a
setup_system_contracts_and_issue_token chain_b
setup_system_contracts_and_issue_token chain_c
#setup_system_contracts_and_issue_token chain_d

sleep .2
upgrade_consensus(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}

    chain=$1
    consensus=`get_chain_consensus ${!chain}`

    if [ "$consensus" == "batch" ];then
        head_num=`${!cleos} get info |jq .head_block_num`
        target_num=$((head_num+110))
        ${!cleos} push action eosio setupgrade '{"up":{"target_block_num":'${target_num}'}}' -p eosio
    fi
}
upgrade_consensus chain_a
upgrade_consensus chain_b
upgrade_consensus chain_c
#upgrade_consensus chain_d


sleep .2
create_firstaccount(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}
    var=chain_${char}_token_sym && sym=${!var}


    echo "create first user account."
    new_keys
    ${!cleos} system newaccount \
         --stake-net "10000.0000 "$sym --stake-cpu "10000.0000 "$sym --buy-ram "100.0000 "$sym \
         eosio firstaccount $pub_key $pub_key -p eosio --transfer
    ${!cleos} transfer eosio firstaccount "10000000.0000 "$sym
    import_key $pri_key
}
create_firstaccount chain_a
create_firstaccount chain_b
create_firstaccount chain_c
#create_firstaccount chain_d

create_account(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}
    var=chain_${char}_token_sym && sym=${!var}

    name=$2
    new_keys
    ${!cleos} system newaccount \
        --stake-net "10000.0000 "$sym --stake-cpu "10000.0000 "$sym --buy-ram "100.0000 "$sym \
        firstaccount $name $pub_key $pub_key -p firstaccount
    ${!cleos} transfer firstaccount $name "10000.0000 "$sym
    import_key $pri_key
}

create_account_by_pub_key(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}
    var=chain_${char}_token_sym && sym=${!var}

    name=$2
    pub_key=$3
    ${!cleos} system newaccount \
        --stake-net "10000.0000 "$sym --stake-cpu "10000.0000 "$sym --buy-ram "100.0000 "$sym \
        firstaccount $name $pub_key $pub_key -p firstaccount
    ${!cleos} transfer firstaccount $name "10000.0000 "$sym
}