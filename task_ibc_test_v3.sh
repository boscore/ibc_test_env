#!/usr/bin/env bash

. env.sh


set_contracts_for_chain_a(){
    cleos=cleos_a
    ${!cleos} set contract ${contract_chain_b} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain_b} && sleep .2
    ${!cleos} set contract ${contract_token}   ${ibc_contracts_dir}/ibc.token -x 1000 -p ${contract_token}   && sleep .2
}
set_contracts_for_chain_a

set_contracts_for_chain_b(){
    cleos=cleos_b
    ${!cleos} set contract ${contract_chain} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain} && sleep .2
    ${!cleos} set contract ${contract_token} ${ibc_contracts_dir}/ibc.token -x 1000 -p ${contract_token} && sleep .2
}
set_contracts_for_chain_b

# get chain id
chain_id_a=` ${cleos_a} get info | jq .chain_id`
chain_id_b=` ${cleos_b} get info | jq .chain_id`



init_contracts_for_chain_a_step1(){
    cleos=cleos_a
    ${!cleos} set account permission ${contract_token} active '{"threshold": 1, "keys":[{"key":"'${token_c_pubkey}'", "weight":1}], "accounts":[{"permission":{"actor":"'${contract_token}'","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p ${contract_token}
    ${!cleos} push action ${contract_token} setglobal '['$chain_a_name',true]' -p ${contract_token}
}
init_contracts_for_chain_a_step1

init_contracts_for_chain_a_step2(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_a

    # -- ibc.chain related --
    var=chain_${char}_name &&   lwc_chain_name=${!var}
    var=chain_id_${char} &&     lwc_chain_id=${!var}
    var=chain_${char} &&        lwc_consensus=`get_chain_consensus ${!var}`

    # -- ibc.token related --
    var=chain_${char}_name && peerchain_name=${!var}
    var=chain_${char}_info && peerchain_info=${var}

    contract_ibc_chain=contract_chain_${char}

    # --- ibc.chain ---
    ${!cleos} push action ${!contract_ibc_chain} setglobal '['$lwc_chain_name,$lwc_chain_id,$lwc_consensus']' -p ${!contract_ibc_chain}
    ${!cleos} push action ${!contract_ibc_chain} relay '["add","ibc2relay555"]' -p ${!contract_ibc_chain}
    # cleos get table ${contract_chain} ${contract_chain} global

    # --- ibc.token ---
    ${!cleos} push action  ${contract_token} regpeerchain '['$peerchain_name','$peerchain_info',"ibc2token555",'${!contract_ibc_chain}',"freeaccount1",5,1000,1000,true]' -p ${contract_token}
    # cleos get table ${contract_token} ${contract_token} globals
    # cleos get table ${contract_token} ${contract_token} peerchains
}
init_contracts_for_chain_a_step2 chain_b


# for chain b
init_contracts(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}

    # -- ibc.chain related --
    lwc_chain_name=$chain_a_name
    lwc_chain_id=$chain_id_a
    lwc_consensus=`get_chain_consensus $chain_a`

    # -- ibc.token related --
    var=chain_${char}_name
    this_chain_name=${!var}
    peerchain_name=$chain_a_name
    peerchain_info=chain_a_info


    ${!cleos} set account permission ${contract_token} active '{"threshold": 1, "keys":[{"key":"'${token_c_pubkey}'", "weight":1}], "accounts":[{"permission":{"actor":"'${contract_token}'","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p ${contract_token}

    # --- ibc.chain ---

    ${!cleos} push action ${contract_chain} setglobal "[$lwc_chain_name,$lwc_chain_id,$lwc_consensus]" -p ${contract_chain}
    ${!cleos} push action ${contract_chain} relay '["add","ibc2relay555"]' -p ${contract_chain}
    # cleos get table ${contract_chain} ${contract_chain} global

    # --- ibc.token ---
    ${!cleos} push action ${contract_token} setglobal '['$this_chain_name',true]' -p ${contract_token}
    ${!cleos} push action ${contract_token} regpeerchain '['$peerchain_name','$peerchain_info',"ibc2token555","ibc2chain555","freeaccount1",5,1000,1000,true]' -p ${contract_token}
    # cleos get table ${contract_token} ${contract_token} globals
    # cleos get table ${contract_token} ${contract_token} peerchains
}
init_contracts chain_b



init_two(){
    $cleos_a push action ${contract_token} regacpttoken \
        '["eosio.token","1000000000.0000 TOA","1.0000 TOA","10000.0000 TOA",
        "1000000.0000 TOA",1000,"organization","https://www.abc.io","ibc2token555","fixed","0.1000 TOA",0.01,"0.1000 TOA",true]' -p ${contract_token}
    # $cleos_a get table ${contract_token} ${contract_token} accepts
    $cleos_a push action ${contract_token} regpegtoken \
        '["chb","eosio.token","1000000000.0000 TOB","1.0000 TOB","100000.0000 TOB",
        "1000000.0000 TOB",1000,"ibc2token555","0.1000 TOB",true]' -p ${contract_token}

    $cleos_b push action ${contract_token} regacpttoken \
        '["eosio.token","1000000000.0000 TOB","1.0000 TOB","100000.0000 TOB",
        "1000000.0000 TOB",1000,"organization","htttp://www.abc.io","ibc2token555","fixed","0.1000 TOB",0.01,"0.1000 TOB",true]' -p ${contract_token}
    $cleos_b push action ${contract_token} regpegtoken \
        '["cha","eosio.token","1000000000.0000 TOA","1.0000 TOA","100000.0000 TOA","1000000.0000 TOA",1000,"ibc2token555","0.1000 TOA",true]' -p ${contract_token}
}
init_two



# get_balance <chain name> <contract> <account>
get_balance(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}
    b=`${!cleos} get currency balance $2 $3 | tr '\n' '  '`
    printf "chain: %s\t contract: %s\t account: %s\t balance: %s\n" $1 $2 $3 "$b"
}

# get_accounts_balance <chain name> <contract> <accounts>
get_accounts_balance(){
    chain=$1
    contract=$2
    shift 2
    for a in $@; do get_balance $chain $contract $a;done
}

get_all_balances(){
    echo ----------- chain A -------------
    accounts="firstaccount receiver1111 chaina2acnt1 chaina2acnt2 ${contract_token} ibc2hub55555 ibc2relay555"
    get_accounts_balance chain_a eosio.token       $accounts  && echo
    get_accounts_balance chain_a ${contract_token} $accounts  && echo

    echo ----------- chain B -------------
    accounts="firstaccount receiver1111 chainb2acnt1 chainb2acnt2 ${contract_token}"
    get_accounts_balance chain_b eosio.token       $accounts  && echo
    get_accounts_balance chain_b ${contract_token} $accounts  && echo
}
get_all_balances




transferxx(){
    $cleos_a transfer -f firstaccount ibc2token555 "1.0000 TOA" "receiver1111@chb notes infomation" -p firstaccount
    $cleos_b transfer -f firstaccount ibc2token555 "1.0000 TOB" "receiver1111@cha notes infomation" -p firstaccount
}



transfer(){
    $cleos_a transfer -f firstaccount receiver1111 "1.0000 TOA" "receiver1111@chb notes infomation" -p firstaccount
    $cleos_b transfer -f firstaccount receiver1111 "1.0000 TOB" "receiver1111@cha notes infomation" -p firstaccount
}



# for i in `seq 10000`; do transfer && sleep 1 ;done

withdraw(){
    $cleos_a push action -f ibc2token555 transfer '["receiver1111","ibc2token555","1.0000 TOB" "chainb2acnt1@chb notes infomation"]' -p receiver1111
    $cleos_b push action -f ibc2token555 transfer '["receiver1111","ibc2token555","1.0000 TOA" "chaina2acnt1@cha notes infomation"]' -p receiver1111
}

transfer_fail(){
    $cleos_a transfer -f firstaccount ibc2token555 "1.0000 TOA" "nonexistacnt@chb" -p firstaccount
    $cleos_b transfer -f firstaccount ibc2token555 "1.0000 TOB" "nonexistacnt@cha" -p firstaccount
}

withdraw_fail(){
    $cleos_a push action -f ibc2token555 transfer '["receiver1111","ibc2token555","1.0000 TOB" "nonexistacnt@chb"]' -p receiver1111
    $cleos_b push action -f ibc2token555 transfer '["receiver1111","ibc2token555","1.0000 TOA" "nonexistacnt@cha"]' -p receiver1111
}


whole(){
    for i in `seq 10`; do transfer && sleep .2 ;done
    for i in `seq 2`; do transfer_fail && sleep .2 ;done
    for i in `seq 10`; do withdraw && sleep .2 ;done
    for i in `seq 2`; do transfer_fail && sleep .2 ;done
#    echo 'sleep 15 seconds ...' && sleep 15
#    for i in `seq 5`; do transfer && sleep .2 ;done
}

# for i in `seq 10000`; do transfer && withdraw && sleep .5 ;done

get_chain_table(){
    echo --- cleos_a ---
    $cleos_a get table ${contract_chain} ${contract_chain} $1
    echo && echo --- cleos_b ---
    $cleos_b get table ${contract_chain} ${contract_chain} $1
}

get_token_table(){
    echo --- cleos_a ---
    $cleos_a get table ${contract_token} ${contract_token} $1
    echo && echo --- cleos_b ---
    $cleos_b get table ${contract_token} ${contract_token} $1
}

get_token_table_by_scope(){
    echo --- cleos_a ---
    $cleos_a get table ${contract_token} bos $1
    echo && echo --- cleos_b ---
    $cleos_b get table ${contract_token} eos $1
}

#    get_chain_table sections
#    get_chain_table prodsches
#    get_chain_table chaindb
#    get_token_table globals
#    get_token_table peerchainm
#    get_token_table_by_scope cashtrxs
#

# $cleos_a get currency stats ${contract_token} TOB


get_account(){
    echo --- cleos_a ---
    $cleos_a get account  $1
    echo && echo --- cleos_b ---
    $cleos_b get account  $1
}
#    get_account ibc2relay555
#    get_account ibc2token555
#    get_account ibc2chain555
#

get_balance(){
    $cleos_a get table ibc2token555 $1 accounts
    $cleos_b get table ibc2token555 $1 accounts
}
#    get_balance receiver1111
#    get_balance receiver1111


get_receiver_b(){
    $cleos_a get currency balance eosio.token receivereos1 "TOA"
    $cleos_b get currency balance eosio.token receiverbos1 "TOB"
}
#    get_receiver_b

pressure(){
    for i in `seq 10000`; do transfer && sleep .5 ;done
    for i in `seq 10000`; do withdraw && sleep .5 ;done

     $cleos_a get table ibc2chain555 ibc2chain555 chaindb -L 9000 |less
}

huge_pressure(){
#    while true; do $cleos_a transfer -f firstaccount ${receiver} "0.0001 TOA" -p firstaccount; done
#    while true; do $cleos_b transfer -f firstaccount ${receiver} "0.0001 TOB" -p firstaccount; done
}

