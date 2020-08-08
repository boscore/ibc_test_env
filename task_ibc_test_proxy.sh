#!/usr/bin/env bash

. env.sh

set_contracts(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}

    ${!cleos} set contract ${contract_chain} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain} && sleep .2
    ${!cleos} set contract ${contract_token} ${ibc_contracts_dir}/ibc.token -x 1000 -p ${contract_token} && sleep .2
    ${!cleos} set contract ${proxy_account}  ${ibc_contracts_dir}/ibc.proxy -x 1000 -p ${proxy_account}  && sleep .2
    ${!cleos} set contract ${user_contract}  ${ibc_contracts_dir}/test/proxytest -x 1000 -p ${user_contract} && sleep .2
}
set_contracts chain_a
set_contracts chain_b

init_contracts_for_chain_step1(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}
        
    ${!cleos} set account permission ${contract_token} active '{"threshold": 1, "keys":[{"key":"'${token_c_pubkey}'", "weight":1}], "accounts":[{"permission":{"actor":"'${contract_token}'","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p ${contract_token}
    ${!cleos} set account permission ${proxy_account} active '{"threshold": 1, "keys":[{"key":"'${proxy_c_pubkey}'", "weight":1}], "accounts":[{"permission":{"actor":"'${proxy_account}'","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p ${proxy_account}
    ${!cleos} set account permission ${user_contract} active '{"threshold": 1, "keys":[{"key":"'${userc_c_pubkey}'", "weight":1}], "accounts":[{"permission":{"actor":"'${user_contract}'","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p ${user_contract}
    ${!cleos} push action ${contract_token} setadmin  '['$admin_account']' -p ${contract_token}
    ${!cleos} push action ${contract_token} setproxy  '['$proxy_account']' -p ${admin_account}

    ${!cleos} push action ${proxy_account} setglobal  '['$contract_token']' -p ${proxy_account}
    ${!cleos} push action ${user_contract} setglobal  '['$proxy_account']' -p ${user_contract}
}
init_contracts_for_chain_step1 chain_a
init_contracts_for_chain_step1 chain_b


init_contracts_for_chain_step2(){
    char=`echo $1 | cut -c 7`
    cleos=cleos_${char}

    # --- ibc.chain ---
    ${!cleos} push action ${contract_chain} relay '["add","ibc2relay555"]' -p ${contract_chain}
}
init_contracts_for_chain_step2 chain_a
init_contracts_for_chain_step2 chain_b

# get chain id
chain_id_a=` ${cleos_a} get info | jq .chain_id`
chain_id_b=` ${cleos_b} get info | jq .chain_id`

reg_peerchain(){

    $cleos_a push action ${contract_token} setglobal '["cha"'',true]' -p ${contract_token}
    $cleos_b push action ${contract_token} setglobal '["chb"'',true]' -p ${contract_token}


    $cleos_a push action ${contract_chain} setglobal '["chb"',$chain_id_b,"batch",false,1']' -p ${contract_chain}
    $cleos_b push action ${contract_chain} setglobal '["cha"',$chain_id_a,"batch",false,1']' -p ${contract_chain}
    # cleos get table ${contract_chain} ${contract_chain} global

    $cleos_a push action  ${contract_token} regpeerchain '["chb",'$peerchain_info',"ibc2token555",'${contract_chain}',"freeaccount1",5,1000,1000,true]' -p ${contract_token}
    $cleos_a push action  ${contract_token} setprchproxy '["chb",'$proxy_account']' -p ${contract_token}
    $cleos_b push action  ${contract_token} regpeerchain '["cha",'$peerchain_info',"ibc2token555",'${contract_chain}',"freeaccount1",5,1000,1000,true]' -p ${contract_token}
    $cleos_b push action  ${contract_token} setprchproxy '["cha",'$proxy_account']' -p ${contract_token}
    # cleos get table ${contract_token} ${contract_token} globals
    # cleos get table ${contract_token} ${contract_token} peerchains
}
reg_peerchain

reg_tokens(){
    ## ---------  register tokens on chain_a  ---------

    $cleos_a push action ${contract_token} regacpttoken \
        '["eosio.token","1000000000.0000 TOA","1.0000 TOA","10000.0000 TOA",
        "1000000.0000 TOA",1000,"organization","https://www.abc.io","ibc2token555","fixed","0.1000 TOA",0.01,"0.1000 TOA",true]' -p ${contract_token}
    # $cleos_a get table ${contract_token} ${contract_token} accepts
    $cleos_a push action ${contract_token} regpegtoken \
        '["chb","eosio.token","1000000000.0000 TOB","1.0000 TOB","100000.0000 TOB",
        "1000000.0000 TOB",1000,"ibc2token555","0.1000 TOB",true]' -p ${contract_token}

    ## ---------  register tokens on chain_b  ---------
    $cleos_b push action ${contract_token} regacpttoken \
        '["eosio.token","1000000000.0000 TOB","1.0000 TOB","100000.0000 TOB",
        "1000000.0000 TOB",1000,"organization","htttp://www.abc.io","ibc2token555","fixed","0.1000 TOB",0.01,"0.1000 TOB",true]' -p ${contract_token}
    $cleos_b push action ${contract_token} regpegtoken \
        '["cha","eosio.token","1000000000.0000 TOA","1.0000 TOA","100000.0000 TOA","1000000.0000 TOA",1000,"ibc2token555","0.1000 TOA",true]' -p ${contract_token}

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
    accounts="firstaccount receiver1111 chaina2acnt1 chaina2acnt2 ${contract_token} ${proxy_account} ${user_contract}"
    get_accounts_balance chain_a eosio.token       $accounts  && echo
    get_accounts_balance chain_a ${contract_token} $accounts  && echo

    echo ----------- chain B -------------
    accounts="firstaccount receiver1111 chainb2acnt1 chainb2acnt2 ${contract_token} ${proxy_account} ${user_contract}"
    get_accounts_balance chain_b eosio.token       $accounts  && echo
    get_accounts_balance chain_b ${contract_token} $accounts  && echo
}
get_all_balances

proxy_test(){

    $cleos_a push action -f ${user_contract} call '["eosio.token","123.4567 TOA","receiver1111@chb happy!"]' -p $user_contract
    $cleos_a push action ${proxy_account} transfer '["ibc2prxoy555","ibc2token555","123.4567 TOA","receiver1111@chb happy! orig_trxid=433b4508f3f927fbb84f309c1421f97fc9e885ee7d2c218e95d36c9c0d25fc5b orig_from=usercontract"]' -p ibc2hub55555



}

3c9de76e4b0447972b76d57df3c7ee22eb98063a2366c03dd481d785e7307b00



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

