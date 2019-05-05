#!/usr/bin/env bash

. env.sh

get_chain_table(){
    echo --- table: $1 of chian A ---
    $cleos1 get table ${contract_chain} ${contract_chain} $1
    echo && echo --- table: $1 of chian B ---
    $cleos2 get table ${contract_chain} ${contract_chain} $1
}

get_token_table(){
    echo --- table: $1 of chian A ---
    $cleos1 get table ${contract_token} ${contract_token} $1
    echo && echo --- table: $1 of chian B ---
    $cleos2 get table ${contract_token} ${contract_token} $1
}

#    get_chain_table sections
#    get_chain_table prodsches
#    get_chain_table chaindb

#    get_token_table globals
#    get_token_table globalm
#    get_token_table origtrxs
#    get_token_table cashtrxs


# As bellow, we use `EOS` as the token symbol of chain A, 'eos' as the name of chain A;
# and `BOS` as the token symbol of chain B, 'bos' as the name of chain B;
# you can modify it according to your blockchains environment.

transfer(){
    $cleos1 transfer -f firstaccount ibc2token555 "10.0000 EOS" "chainb2acnt1@bos notes infomation" -p firstaccount
    $cleos2 transfer -f firstaccount ibc2token555 "10.0000 BOS" "chaina2acnt1@eos notes infomation" -p firstaccount
}

withdraw(){
    $cleos1 push action -f ibc2token555 transfer '["chaina2acnt1","ibc2token555","10.0000 BOSPG" "chainb2acnt2@bos notes infomation"]' -p chaina2acnt1
    $cleos2 push action -f ibc2token555 transfer '["chainb2acnt1","ibc2token555","10.0000 EOSPG" "chaina2acnt2@eos notes infomation"]' -p chainb2acnt1
}

transfer_fail(){
    $cleos1 transfer -f firstaccount ibc2token555 "10.0000 EOS" "notexistacnt@bos" -p firstaccount
    $cleos2 transfer -f firstaccount ibc2token555 "10.0000 BOS" "notexistacnt@eos" -p firstaccount
}

withdraw_fail(){
    $cleos1 push action -f ibc2token555 transfer '["chaina2acnt2","ibc2token555","10.0000 BOSPG" "notexistacnt@bos"]' -p chaina2acnt2
    $cleos2 push action -f ibc2token555 transfer '["chainb2acnt2","ibc2token555","10.0000 EOSPG" "notexistacnt@eos"]' -p chainb2acnt2
}

once(){
    for i in `seq 10`; do transfer && sleep .2 ;done
    for i in `seq 10`; do withdraw && sleep .2 ;done
    for i in `seq 2`; do transfer_fail && sleep .2 ;done
    for i in `seq 2`; do transfer_fail && sleep .2 ;done
}
# for i in `seq 10000`; do transfer && withdraw &&          sleep .5 ;done

get_balance(){
    $cleos1 get table ibc2token555 $1 accounts
    $cleos2 get table ibc2token555 $1 accounts
}
#    get_balance chaina2acnt1
#    get_balance chaina2acnt2
#    get_balance chainb2acnt1
#    get_balance chainb2acnt2

pressure(){
    while true ;do $cleos1 transfer -f firstaccount ${receiver} "0.0001 EOS" -p firstaccount; done
    while true ;do $cleos2 transfer -f firstaccount ${receiver} "0.0001 BOS" -p firstaccount; done
}
