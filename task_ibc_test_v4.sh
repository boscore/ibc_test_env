#!/usr/bin/env bash

. env.sh

##
## let's assume chain_a be the hub of the multi-chain ibc system
## so we neet to create three account for deploying light-client contract(ibc.chain) for chain b c and d seperately.
##

set_contracts_for_chain_a(){
    cleos=cleos_a
    ${!cleos} set contract ${contract_chain_b} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain_b} && sleep .2
    ${!cleos} set contract ${contract_chain_c} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain_c} && sleep .2
    ${!cleos} set contract ${contract_chain_d} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain_d} && sleep .2
    ${!cleos} set contract ${contract_token} ${ibc_contracts_dir}/ibc.token -x 1000 -p ${contract_token} && sleep .2
}
set_contracts_for_chain_a


set_contracts(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}

    ${!cleos} set contract ${contract_chain} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain} && sleep .2
    ${!cleos} set contract ${contract_token} ${ibc_contracts_dir}/ibc.token -x 1000 -p ${contract_token} && sleep .2
}
set_contracts chain_b
set_contracts chain_c
#set_contracts chain_d


chain_id_a=` ${cleos_a} get info | jq .chain_id`
chain_id_b=` ${cleos_b} get info | jq .chain_id`
chain_id_c=` ${cleos_c} get info | jq .chain_id`
#chain_id_d=` ${cleos_d} get info | jq .chain_id`


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
init_contracts_for_chain_a_step2 chain_c
#init_contracts_for_chain_a_step2 chain_d


# for chain b c d
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
init_contracts chain_c
#init_contracts chain_d


reg_tokens(){
    ## ---------  register tokens on chain_a  ---------

    $cleos_a push action ${contract_token} regacpttoken \
        '["eosio.token","1000000000.0000 TOA","1.0000 TOA","10000.0000 TOA",
        "1000000.0000 TOA",1000,"organization","https://www.abc.io","ibc2token555","fixed","0.1000 TOA",0.01,"0.1000 TOA",true]' -p ${contract_token}
    # $cleos_a get table ${contract_token} ${contract_token} accepts
    $cleos_a push action ${contract_token} regpegtoken \
        '["chb","eosio.token","1000000000.0000 TOB","1.0000 TOB","100000.0000 TOB",
        "1000000.0000 TOB",1000,"ibc2token555","0.1000 TOB",true]' -p ${contract_token}
    $cleos_a push action ${contract_token} regpegtoken \
        '["chc","eosio.token","1000000000.0000 TOC","1.0000 TOC","100000.0000 TOC",
        "1000000.0000 TOC",1000,"ibc2token555","0.1000 TOC",true]' -p ${contract_token}
#    $cleos_a push action ${contract_token} regpegtoken \
#        '["chd","eosio.token","1000000000.0000 TOD","1.0000 TOD","100000.0000 TOD",
#        "1000000.0000 TOD",1000,"ibc2token555","0.1000 TOD",true]' -p ${contract_token}
    $cleos_a push action ${contract_token} regacpttoken \
        '['${contract_token}',"1000000000.0000 TOB","1.0000 TOB","10000.0000 TOB",
        "1000000.0000 TOB",1000,"organization","https://www.abc.io","ibc2token555","fixed","0.1000 TOB",0.01,"0.1000 TOB",true]' -p ${contract_token}
    $cleos_a push action ${contract_token} regacpttoken \
        '['${contract_token}',"1000000000.0000 TOC","1.0000 TOC","10000.0000 TOC",
        "1000000.0000 TOC",1000,"organization","https://www.abc.io","ibc2token555","fixed","0.1000 TOC",0.01,"0.1000 TOC",true]' -p ${contract_token}
#    $cleos_a push action ${contract_token} regacpttoken \
#        '['${contract_token}',"1000000000.0000 TOD","1.0000 TOD","10000.0000 TOD",
#        "1000000.0000 TOD",1000,"organization","https://www.abc.io","ibc2token555","fixed","0.1000 TOD",0.01,"0.1000 TOD",true]' -p ${contract_token}



    ## ---------  register tokens on chain_b  ---------
    $cleos_b push action ${contract_token} regacpttoken \
        '["eosio.token","1000000000.0000 TOB","1.0000 TOB","100000.0000 TOB",
        "1000000.0000 TOB",1000,"organization","htttp://www.abc.io","ibc2token555","fixed","0.1000 TOB",0.01,"0.1000 TOB",true]' -p ${contract_token}
    $cleos_b push action ${contract_token} regpegtoken \
        '["cha","eosio.token","1000000000.0000 TOA","1.0000 TOA","100000.0000 TOA","1000000.0000 TOA",1000,"ibc2token555","0.1000 TOA",true]' -p ${contract_token}
    $cleos_b push action ${contract_token} regpegtoken \
        '["cha",'${contract_token}',"1000000000.0000 TOC","1.0000 TOC","100000.0000 TOC","1000000.0000 TOC",1000,"ibc2token555","0.1000 TOC",true]' -p ${contract_token}
#    $cleos_b push action ${contract_token} regpegtoken \
#        '["cha",'${contract_token}',"1000000000.0000 TOD","1.0000 TOD","100000.0000 TOD","1000000.0000 TOD",1000,"ibc2token555","0.1000 TOD",true]' -p ${contract_token}



    ## ---------  register tokens on chain_c  ---------
    $cleos_c push action ${contract_token} regacpttoken \
        '["eosio.token","1000000000.0000 TOC","1.0000 TOC","100000.0000 TOC",
        "1000000.0000 TOC",1000,"organization","htttp://www.abc.io","ibc2token555","fixed","0.1000 TOC",0.01,"0.1000 TOC",true]' -p ${contract_token}
    $cleos_c push action ${contract_token} regpegtoken \
        '["cha","eosio.token","1000000000.0000 TOA","1.0000 TOA","100000.0000 TOA","1000000.0000 TOA",1000,"ibc2token555","0.1000 TOA",true]' -p ${contract_token}
    $cleos_c push action ${contract_token} regpegtoken \
        '["cha",'${contract_token}',"1000000000.0000 TOB","1.0000 TOB","100000.0000 TOB","1000000.0000 TOB",1000,"ibc2token555","0.1000 TOB",true]' -p ${contract_token}
#    $cleos_c push action ${contract_token} regpegtoken \
#        '["cha",'${contract_token}',"1000000000.0000 TOD","1.0000 TOD","100000.0000 TOD","1000000.0000 TOD",1000,"ibc2token555","0.1000 TOD",true]' -p ${contract_token}



#    ## ---------  register tokens on chain_d  ---------
#    $cleos_d push action ${contract_token} regacpttoken \
#        '["eosio.token","4,TOD","4,TOD","1000000000.0000 TOD","1.0000 TOD","100000.0000 TOD",
#        "1000000.0000 TOD",1000,"organization","htttp://www.abc.io","ibc2token555","fixed","0.1000 TOD",0.01,"0.1000 TOD",true]' -p ${contract_token}
#    $cleos_c push action ${contract_token} regpegtoken \
#        '["cha","eosio.token","1000000000.0000 TOA","1.0000 TOA","100000.0000 TOA","1000000.0000 TOA",1000,"ibc2token555","0.1000 TOA",true]' -p ${contract_token}
#    $cleos_c push action ${contract_token} regpegtoken \
#        '["cha",'${contract_token}',"1000000000.0000 TOB","1.0000 TOB","100000.0000 TOB","1000000.0000 TOB",1000,"ibc2token555","0.1000 TOB",true]' -p ${contract_token}
#    $cleos_c push action ${contract_token} regpegtoken \
#        '["cha",'${contract_token}',"1000000000.0000 TOC","1.0000 TOC","100000.0000 TOC","1000000.0000 TOC",1000,"ibc2token555","0.1000 TOC",true]' -p ${contract_token}


# $cleos get table ${contract_token} ${contract_token} stats
# $cleos get table ${contract_token} ${contract_token} accepts
}
reg_tokens

return

transfer_b2a_a2c(){

    # b 2 a  then a 2 c
    $cleos_b transfer -f firstaccount ibc2token555 "10.0000 TOB" "receiver1111@cha notes infomation" -p firstaccount
    $cleos_a push action -f ibc2token555 transfer '["receiver1111","ibc2token555","5.0000 TOB" "chainc2acnt1@chc notes infomation"]' -p receiver1111
    $cleos_a get currency balance ${contract_token} ${contract_token}
    $cleos_c push action -f ibc2token555 transfer '["chainc2acnt1","ibc2token555","3.0000 TOB" "chaina2acnt1@cha notes infomation"]' -p chainc2acnt1
    # $cleos_a get currency balance ${contract_token} account
}






























transfer(){
    $cleos_a transfer -f firstaccount ibc2token555 "1.0000 TOA" "receiver1111@bos notes infomation" -p firstaccount
    $cleos_b transfer -f firstaccount ibc2token555 "1.0000 TOB" "receiver1111@eos notes infomation" -p firstaccount
}
# for i in `seq 10000`; do transfer && sleep 1 ;done

withdraw(){
    $cleos_a push action -f ibc2token555 transfer '["receiver1111","ibc2token555","1.0000 TOB" "chainb2acnt1@bos notes infomation"]' -p receiver1111
    $cleos_b push action -f ibc2token555 transfer '["receiver1111","ibc2token555","1.0000 TOA" "chaina2acnt1@eos notes infomation"]' -p receiver1111
}

transfer_fail(){
    $cleos_a transfer -f firstaccount ibc2token555 "1.0000 TOA" "nonexistacnt@bos" -p firstaccount
    $cleos_b transfer -f firstaccount ibc2token555 "1.0000 TOB" "nonexistacnt@eos" -p firstaccount
}

withdraw_fail(){
    $cleos_a push action -f ibc2token555 transfer '["receiver1111","ibc2token555","1.0000 TOB" "nonexistacnt@bos"]' -p receiver1111
    $cleos_b push action -f ibc2token555 transfer '["receiver1111","ibc2token555","1.0000 TOA" "nonexistacnt@eos"]' -p receiver1111
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

