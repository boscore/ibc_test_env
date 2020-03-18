#!/usr/bin/env bash

# Note:
# in config.ini of ibc_plugin nodeos v1, there must be "ibc-sidechain-id=<chain id>", but in v2, it's not need.
# so you should add this item in auto generated config.ini for relay nodes, then you can start those nodes.

. env.sh

set_contracts(){
    cleos=cleos_a && if [ "$1" == "chain_b" ];then cleos=cleos_b ;fi
    ${!cleos} set contract ${contract_chain} ${ibc_contracts_dir}/ibc.chain -x 1000 -p ${contract_chain} && sleep .2
    ${!cleos} set contract ${contract_token} ${ibc_contracts_dir}/ibc.token -x 1000 -p ${contract_token} && sleep .2
}
set_contracts chain_a
set_contracts chain_b

init_contracts(){
    cleos=cleos_a && if [ "$1" == "chain_b" ];then cleos=cleos_b ;fi

    # --- init ibc.chain contract ---
    ${!cleos}  push action  ${contract_chain} setlibdepth '["170"]' -p ${contract_chain}
    ${!cleos}  push action  ${contract_chain} relay '["add","ibc2relay555"]' -p ${contract_chain}
    # cleos get table ${contract_chain} ${contract_chain} global

    # --- init ibc.token contract ---
    ${!cleos} set account permission ${contract_token} active '{"threshold": 1, "keys":[{"key":"'${token_c_pubkey}'", "weight":1}],
    "accounts":[{"permission":{"actor":"'${contract_token}'","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p ${contract_token}
}
init_contracts chain_a
init_contracts chain_b


init_contracts_2(){
    $cleos_a push action ${contract_token} setglobal '["ibc2chain555","'${chain_b_name}'","ibc2token555",0,1000,5,true]' -p ${contract_token}
    $cleos_b push action ${contract_token} setglobal '["ibc2chain555","'${chain_a_name}'","ibc2token555",0,1000,5,true]' -p ${contract_token}
}
init_contracts_2


# As bellow, we use `EOS` as the token symbol of chain A, and `BOS` as the token symbol of chain B.
# you can modify it according to your blockchains environment.
register_tokens_on_both_chains(){
    $cleos_a push action ${contract_token} regacpttoken \
        '["eosio.token","1000000000.0000 EOS","ibc2token555","10.0000 EOS","5000.0000 EOS",
        "100000.0000 EOS",1000,"eos organization","www.eos.com","fixed","0.1000 EOS",0.01,"fixed","0.1000 EOS",0.01,true,"4,EOSPG"]' -p ${contract_token}
    $cleos_a push action ${contract_token} regpegtoken \
        '["1000000000.0000 BOSPG","10.0000 BOSPG","5000.0000 BOSPG",
        "100000.0000 BOSPG",1000,"ibc2token555","eosio.token","4,BOS","fixed","0.1000 BOSPG",0.01,true]' -p ${contract_token}


    $cleos_b push action ${contract_token} regacpttoken \
        '["eosio.token","1000000000.0000 BOS","ibc2token555","10.0000 BOS","5000.0000 BOS",
        "100000.0000 BOS",1000,"bos organization","www.bos.com","fixed","0.1000 BOS",0.01,"fixed","0.1000 BOS",0.01,true,"4,BOSPG"]' -p ${contract_token}
    $cleos_b push action ${contract_token} regpegtoken \
        '["1000000000.0000 EOSPG","10.0000 EOSPG","5000.0000 EOSPG",
        "100000.0000 EOSPG",1000,"ibc2token555","eosio.token","4,EOS","fixed","0.1000 EOSPG",0.01,true]' -p ${contract_token}
}
register_tokens_on_both_chains

transfer(){
    $cleos_a transfer -f firstaccount ibc2token555 "10.0000 EOS" "chainb2acnt1@bos notes infomation" -p firstaccount
    $cleos_b transfer -f firstaccount ibc2token555 "10.0000 BOS" "chaina2acnt1@eos notes infomation" -p firstaccount
}


