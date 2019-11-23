#!/usr/bin/env bash

. env.sh

set_contracts(){
    cleos=cleos1 && if [ "$1" == "chain_B" ];then cleos=cleos2 ;fi
    ${!cleos} set contract ${contract_chain} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain} && sleep .2
    ${!cleos} set contract ${contract_token} ${ibc_contracts_dir}/ibc.token -x 1000 -p ${contract_token} && sleep .2
}
set_contracts chain_A
set_contracts chain_B

init_contracts(){
    cleos=cleos1
    cleos_p=cleos2
    # -- ibc.chain related --
    lwc_chain_name=$chain_B_name
    lwc_consensus=`get_chain_consensus $chain_B`

    # -- ibc.token related --
    this_chain_name=$chain_A_name
    peerchain_name=$chain_B_name
    peerchain_info=chain_B_info

    if [ "$1" == "chain_B" ];then
        cleos=cleos2
        cleos_p=cleos1

        # -- ibc.chain related --
        lwc_chain_name=$chain_A_name
        lwc_consensus=`get_chain_consensus $chain_A`

        # -- ibc.token related --
        this_chain_name=$chain_B_name
        peerchain_name=$chain_A_name
        peerchain_info=chain_A_info
    fi

    ${!cleos} set account permission ${contract_token} active '{"threshold": 1, "keys":[{"key":"'${token_c_pubkey}'", "weight":1}], "accounts":[{"permission":{"actor":"'${contract_token}'","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p ${contract_token}

    # --- ibc.chain ---
    lwc_chain_id=` ${!cleos_p} get info | jq .chain_id`
    ${!cleos}  push action  ${contract_chain} setglobal "[$lwc_chain_name,$lwc_chain_id,$lwc_consensus]" -p ${contract_chain}
    # cleos get table ${contract_chain} ${contract_chain} global

    # --- ibc.token ---
    ${!cleos} push action ${contract_token} setglobal '['$this_chain_name',true]' -p ${contract_token}
    ${!cleos} push action ${contract_token} regpeerchain '['$peerchain_name','$peerchain_info',"ibc2token555","ibc2chain555","freeaccount1",5,1000,1000,true]' -p ${contract_token}
    # cleos get table ${contract_token} ${contract_token} globals
    # cleos get table ${contract_token} ${contract_token} peerchains
}
init_contracts chain_A
init_contracts chain_B

init_two(){
    $cleos1 push action ${contract_token} regacpttoken \
        '["eosio.token","4,EOS","4,EOSPG","1000000000.0000 EOS","10.0000 EOS","5000.0000 EOS",
        "100000.0000 EOS",1000,"eos organization","https://eos.io","ibc2token555","fixed","0.1000 EOS",0.01,"0.1000 EOS",true]' -p ${contract_token}
    # $cleos1 get table ${contract_token} ${contract_token} accepts
    $cleos1 push action ${contract_token} regpegtoken \
        '["bos","eosio.token","4,BOS","4,BOSPG","1000000000.0000 BOSPG","10.0000 BOSPG","5000.0000 BOSPG",
        "100000.0000 BOSPG",1000,"ibc2token555","0.1000 BOSPG",true]' -p ${contract_token}
    # $cleos1 get table ${contract_token} ${contract_token} stats

    $cleos2 push action ${contract_token} regacpttoken \
        '["eosio.token","4,BOS","4,BOSPG","1000000000.0000 BOS","10.0000 BOS","5000.0000 BOS",
        "100000.0000 BOS",1000,"bos organization","https://boscore.io","ibc2token555","fixed","0.1000 BOS",0.01,"0.1000 BOS",true]' -p ${contract_token}
    # $cleos2 get table ${contract_token} ${contract_token} accepts
    $cleos2 push action ${contract_token} regpegtoken \
        '["eos","eosio.token","4,EOS","4,EOSPG","1000000000.0000 EOSPG","10.0000 EOSPG","5000.0000 EOSPG",
        "100000.0000 EOSPG",1000,"ibc2token555","0.1000 EOSPG",true]' -p ${contract_token}
    # $cleos2 get table ${contract_token} ${contract_token} stats
}
init_two



transfer(){
    $cleos1 transfer -f firstaccount ibc2token555 "10.0000 EOS" "receiver1111@bos notes infomation" -p firstaccount
    $cleos2 transfer -f firstaccount ibc2token555 "10.0000 BOS" "receiver1111@eos notes infomation" -p firstaccount
}
# for i in `seq 10000`; do transfer && sleep 1 ;done

withdraw(){
    $cleos1 push action -f ibc2token555 transfer '["receiver1111","ibc2token555","10.0000 BOSPG" "chainb2acnt1@bos notes infomation"]' -p receiver1111
    $cleos2 push action -f ibc2token555 transfer '["receiver1111","ibc2token555","10.0000 EOSPG" "chaina2acnt1@eos notes infomation"]' -p receiver1111
}

transfer_fail(){
    $cleos1 transfer -f firstaccount ibc2token555 "10.0000 EOS" "nonexistacnt@bos" -p firstaccount
    $cleos2 transfer -f firstaccount ibc2token555 "10.0000 BOS" "nonexistacnt@eos" -p firstaccount
}

withdraw_fail(){
    $cleos1 push action -f ibc2token555 transfer '["receiver1111","ibc2token555","10.0000 BOSPG" "nonexistacnt@bos"]' -p receiver1111
    $cleos2 push action -f ibc2token555 transfer '["receiver1111","ibc2token555","10.0000 EOSPG" "nonexistacnt@eos"]' -p receiver1111
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
    echo --- cleos1 ---
    $cleos1 get table ${contract_chain} ${contract_chain} $1
    echo && echo --- cleos2 ---
    $cleos2 get table ${contract_chain} ${contract_chain} $1
}

get_token_table(){
    echo --- cleos1 ---
    $cleos1 get table ${contract_token} ${contract_token} $1
    echo && echo --- cleos2 ---
    $cleos2 get table ${contract_token} ${contract_token} $1
}

get_token_table_by_scope(){
    echo --- cleos1 ---
    $cleos1 get table ${contract_token} bos $1
    echo && echo --- cleos2 ---
    $cleos2 get table ${contract_token} eos $1
}

#    get_chain_table sections
#    get_chain_table prodsches
#    get_chain_table chaindb
#    get_token_table globals
#    get_token_table peerchainm
#    get_token_table_by_scope cashtrxs
#

# $cleos1 get currency stats ${contract_token} BOSPG


get_account(){
    echo --- cleos1 ---
    $cleos1 get account  $1
    echo && echo --- cleos2 ---
    $cleos2 get account  $1
}
#    get_account ibc2relay555
#    get_account ibc2token555
#    get_account ibc2chain555
#

get_balance(){
    $cleos1 get table ibc2token555 $1 accounts
    $cleos2 get table ibc2token555 $1 accounts
}
#    get_balance receiver1111
#    get_balance receiver1111


get_receiver_b(){
    $cleos1 get currency balance eosio.token receivereos1 "EOS"
    $cleos2 get currency balance eosio.token receiverbos1 "BOS"
}
#    get_receiver_b

pressure(){
    for i in `seq 10000`; do transfer && sleep .5 ;done
    for i in `seq 10000`; do withdraw && sleep .5 ;done

     $cleos1 get table ibc2chain555 ibc2chain555 chaindb -L 9000 |less
}

huge_pressure(){
#    while true; do $cleos1 transfer -f firstaccount ${receiver} "0.0001 EOS" -p firstaccount; done
#    while true; do $cleos2 transfer -f firstaccount ${receiver} "0.0001 BOS" -p firstaccount; done
}

