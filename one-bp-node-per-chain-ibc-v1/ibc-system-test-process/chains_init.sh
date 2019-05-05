#!/usr/bin/env bash

. init_system_contracts.sh

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
    create_account chain_A chain1a1ooo1
    create_account chain_A chain1a1ooo2
    create_account chain_B chain1b1ooo1
    create_account chain_B chain1b1ooo2
}
create_some_accounts
