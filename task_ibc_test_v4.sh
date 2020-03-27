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
    ${!cleos} set contract ${contract_token}   ${ibc_token_hub_dir}/ibc.token -x 1000 -p ${contract_token}   && sleep .2
}
set_contracts_for_chain_a

# for chain b c d
set_contracts(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}

    ${!cleos} set contract ${contract_chain} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain} && sleep .2
    ${!cleos} set contract ${contract_token} ${ibc_contracts_dir}/ibc.token -x 1000 -p ${contract_token} && sleep .2
}
set_contracts chain_b
set_contracts chain_c
#set_contracts chain_d

# get chain id
chain_id_a=` ${cleos_a} get info | jq .chain_id`
chain_id_b=` ${cleos_b} get info | jq .chain_id`
chain_id_c=` ${cleos_c} get info | jq .chain_id`
#chain_id_d=` ${cleos_d} get info | jq .chain_id`


init_contracts_for_chain_a_step1(){
    cleos=cleos_a
    ${!cleos} set account permission ${contract_token} active '{"threshold": 1, "keys":[{"key":"'${token_c_pubkey}'", "weight":1}], "accounts":[{"permission":{"actor":"'${contract_token}'","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p ${contract_token}
    ${!cleos} push action ${contract_token} setglobal '['$chain_a_name',true]' -p ${contract_token}
    ${!cleos} push action ${contract_token} hubinit '['$hub_account']' -p ${contract_token}
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

    echo ----------- chain C -------------
    accounts="firstaccount receiver1111 chainc2acnt1 chainc2acnt2 ${contract_token}"
    get_accounts_balance chain_c eosio.token       $accounts  && echo
    get_accounts_balance chain_c ${contract_token} $accounts  && echo
}
get_all_balances


transferxxx(){

    # ---- simple ibc transfer ----
    $cleos_b push action -f eosio.token  transfer '["firstaccount","ibc2token555","100.0000 TOB" "receiver1111@cha notes infomation"]' -p firstaccount
    $cleos_a push action -f ibc2token555 transfer '["receiver1111","ibc2token555","90.0000 TOB" "chainb2acnt1@chb notes infomation"]' -p receiver1111

    $cleos_a push action -f eosio.token  transfer '["firstaccount","ibc2token555","100.0000 TOA" "receiver1111@chb notes infomation"]' -p firstaccount
    $cleos_b push action -f ibc2token555 transfer '["receiver1111","ibc2token555","90.0000 TOA" "chaina2acnt1@cha notes infomation"]' -p receiver1111

    # ---- simple ibc transfer fail ----
    $cleos_a push action -f eosio.token  transfer '["firstaccount","ibc2token555","100.0000 TOA" "nonexistacnt@chb notes infomation"]' -p firstaccount
    $cleos_b push action -f eosio.token  transfer '["firstaccount","ibc2token555","100.0000 TOB" "nonexistacnt@cha notes infomation"]' -p firstaccount



    # ---- ibc hub transfer of non-hub-chain-token ----
    $cleos_b push action -f eosio.token  transfer '["firstaccount","ibc2token555","100.0000 TOB" "ibc2hub55555@cha >> chainc2acnt1@chc notes infomation"]' -p firstaccount

    $cleos_a push action -f ibc2token555  transfer '["ibc2hub55555","ibc2token555","99.9000 TOB"
    "chainc2acnt1@chc orig_trx_id=151b40701f48f4d0df0a924de8ab046340f8b6f8f68d5f7edeed04835bd5aae3 worker=chaina2acnt2  notes infomation"]' -p firstaccount

    $cleos_c push action -f ibc2token555  transfer '["chainc2acnt1","ibc2token555","10.0000 TOB" "ibc2hub55555@cha >> chainb2acnt2@chb notes infomation"]' -p chainc2acnt1

    $cleos_a push action -f ibc2token555  transfer '["ibc2hub55555","ibc2token555","9.8000 TOB"
    "chainb2acnt2@chb orig_trx_id=d83d24810fdc6f5f0db14591d6a080a1feae9959df0dcfeafcc7c9fcc2221c34 worker=chaina2acnt2  notes infomation"]' -p firstaccount

    $cleos_c push action -f ibc2token555  transfer '["chainc2acnt1","ibc2token555","89.9000 TOB" "ibc2hub55555@cha >> chainb2acnt2@chb notes infomation"]' -p chainc2acnt1

    $cleos_a push action -f ibc2token555  transfer '["ibc2hub55555","ibc2token555","89.7000 TOB"
    "chainb2acnt2@chb orig_trx_id=21619f8b08389958fc909fa9b19971d3a4b2d9f1cd77b08f69bd95720dd9e340 worker=chaina2acnt1  notes infomation"]' -p firstaccount



    # ---- ibc hub transfer of hub-chain-token ----
    $cleos_a push action -f eosio.token  transfer '["firstaccount","ibc2token555","10000.0000 TOA" "receiver1111@chb notes infomation"]' -p firstaccount

    # b -> c
    $cleos_b push action -f ibc2token555  transfer '["receiver1111","ibc2token555","10.0000 TOA" "ibc2hub55555@cha >> chainc2acnt1@chc notes infomation"]' -p receiver1111

    # back
    $cleos_a push action -f ibc2token555  transfer '["ibc2hub55555","ibc2token555","999.8000 TOA"
    "receiver1111@chb orig_trx_id=04589e120a6f82c622e197dbd67cfbbe980093715f2b606d78a41dd554007cd8 worker=chaina2acnt2  notes infomation"]' -p firstaccount

    # b -> c
    $cleos_b push action -f ibc2token555  transfer '["receiver1111","ibc2token555","999.8000 TOA" "ibc2hub55555@cha >> chainc2acnt2@chc notes infomation"]' -p receiver1111

    $cleos_a push action -f ibc2token555  transfer '["ibc2hub55555","ibc2token555","999.6000 TOA"
    "chainc2acnt2@chc orig_trx_id=348cf480aba0479fba774edf1e5bee9afdf7bb37f1f7452a90518b14fa092ece worker=chaina2acnt2  notes infomation"]' -p firstaccount

    $cleos_c push action -f ibc2token555  transfer '["chainc2acnt2","ibc2token555","999.6000 TOA" "receiver1111@cha notes infomation"]' -p chainc2acnt2



    # c -> b
    $cleos_c push action -f ibc2token555  transfer '["chainc2acnt1","ibc2token555","10.0000 TOA" "ibc2hub55555@cha >> chainb2acnt2@chb notes infomation"]' -p chainc2acnt1

    $cleos_a push action -f ibc2token555  transfer '["ibc2hub55555","ibc2token555","9.9000 TOA"
    "chainb2acnt2@chb orig_trx_id=943333e4966e6219a2958ffb8d3fcde200cb797a10dac13101a8c0e0dcde5301 worker=chaina2acnt2  notes infomation"]' -p firstaccount


    ## $cleos_a get table ${contract_token} ${contract_token} hubtrxs
    ## $cleos_a get table ${contract_token} ${contract_token} hubgs





    $cleos_b push action -f eosio.token  transfer '["firstaccount","ibc2token555","10.0000 TOB" "ibc2hub55555@cha >> chainc5acnt1@chc notes infomation"]' -p firstaccount

    $cleos_a push action -f eosio.token transfer '["firstaccount","ibc2token555","10.0000 TOA" "chainc2acnt2@chc notes infomation"]' -p firstaccount


    # === success TOB ===
    # b -> c
    $cleos_b push action -f eosio.token  transfer '["firstaccount","ibc2token555","100.0000 TOB" "ibc2hub55555@cha >> chainc2acnt1@chc notes infomation"]' -p firstaccount
    # c -> a
    $cleos_c push action -f ibc2token555  transfer '["chainc2acnt1","ibc2token555","30.0000 TOB" "chaina2acnt2@cha notes infomation"]' -p chainc2acnt1
    # c -> b
    $cleos_c push action -f ibc2token555  transfer '["chainc2acnt1","ibc2token555","10.0000 TOB" "ibc2hub55555@cha >> chainb2acnt1@chb notes infomation"]' -p chainc2acnt1








    # === success TOA ===
    # a -> b
    $cleos_a push action -f eosio.token  transfer '["firstaccount","ibc2token555","10000.0000 TOA" "chainb2acnt1@chb notes infomation"]' -p firstaccount
    # b -> c
    $cleos_b push action -f ibc2token555  transfer '["chainb2acnt1","ibc2token555","10.0000 TOA" "ibc2hub55555@cha >> chainc2acnt1@chc notes infomation"]' -p chainb2acnt1
    # c -> a
    $cleos_c push action -f ibc2token555  transfer '["chainc2acnt1","ibc2token555","20.0000 TOA" "receiver1111@cha notes infomation"]' -p chainc2acnt1
    # c -> b
    $cleos_c push action -f ibc2token555  transfer '["chainc2acnt1","ibc2token555","10.0000 TOA" "ibc2hub55555@cha >> chainb2acnt2@chb notes infomation"]' -p chainc2acnt1
    # b -> a
    $cleos_b push action -f ibc2token555  transfer '["chainb2acnt2","ibc2token555","5.0000 TOA" "chaina2acnt2@cha notes infomation"]' -p chainb2acnt2




}

