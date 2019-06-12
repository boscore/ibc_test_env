#!/usr/bin/env bash

## . init_system_contracts.sh

# Create ibc.chain ibc.token and relay account on chain A
create_account            chain_A ${contract_chain}
create_account_by_pub_key chain_A ${contract_token} ${token_c_pubkey}
create_account_by_pub_key chain_A ibc2relay555 EOS5jLHvXsFPvUAawjc6qodxUbkBjWcU1j6GUghsNvsGPRdFV5ZWi

# Create ibc.chain ibc.token and relay account on chain B
create_account            chain_B ${contract_chain}
create_account_by_pub_key chain_B ${contract_token} ${token_c_pubkey}
create_account_by_pub_key chain_B ibc2relay555 EOS5jLHvXsFPvUAawjc6qodxUbkBjWcU1j6GUghsNvsGPRdFV5ZWi

import_key ${token_c_prikey}

create_some_accounts(){
    create_account chain_A chaina2acnt1  # means chain A's account 1
    create_account chain_A chaina2acnt2  # means chain A's account 2
    create_account chain_B chainb2acnt1  # means chain B's account 1
    create_account chain_B chainb2acnt2  # means chain B's account 2

    create_account chain_A receiver1111
    create_account chain_B receiver1111

    create_account chain_A freeaccount1
    create_account chain_B freeaccount1
}
create_some_accounts

