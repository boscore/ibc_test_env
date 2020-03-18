#!/usr/bin/env bash

## . init_system_contracts.sh

# Create ibc.chain ibc.token and relay accounts
create_accounts_for_chain(){
    char=`echo $1 | cut -c 7`

    create_account            chain_${char} ${contract_chain}
    create_account_by_pub_key chain_${char} ${contract_token} ${token_c_pubkey}
    create_account_by_pub_key chain_${char} ibc2relay555 EOS5jLHvXsFPvUAawjc6qodxUbkBjWcU1j6GUghsNvsGPRdFV5ZWi
}

create_accounts_for_chain chain_a
create_accounts_for_chain chain_b
create_accounts_for_chain chain_c
#create_accounts_for_chain chain_d


import_key ${token_c_prikey}

create_some_accounts(){
    char=`echo $1 | cut -c 7`

    create_account chain_${char} chain${char}2acnt1  # means chain *'s account 1
    create_account chain_${char} chain${char}2acnt2  # means chain *'s account 2
    create_account chain_${char} receiver1111
    create_account chain_${char} freeaccount1
}

create_some_accounts chain_a
create_some_accounts chain_b
create_some_accounts chain_c
#create_some_accounts chain_d


create_accounts_for_chain_a(){
    create_account chain_a ${contract_chain_b}
    create_account chain_a ${contract_chain_c}
    create_account chain_a ${contract_chain_d}
}
create_accounts_for_chain_a
