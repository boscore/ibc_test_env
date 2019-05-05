#!/usr/bin/env bash

. init_system_contracts.sh

receiver=111111111111

create_one chain_A ${receiver}
create_one chain_B ${receiver}

contract_chain=ibc2chain555
contract_chain_folder=ibc.chain

contract_token=ibc2token555
contract_token_folder=ibc.token

token_c_pubkey=EOS6Sc4BuA7dEGRU6u4VSuEKusESFe61qD8LmguGEMULrghKDSPaU
token_c_prikey=5K79wAY8rgPwWQSRmyQa2BR8vPicieJdLCXL3cM5Db77QnsJess
import_key ${token_c_prikey}

new_account(){
    cleos=cleos1 && if [ "$1" == "c2" ];then cleos=cleos2 ;fi
    create_one $1 $2
}
new_account chain_A ${contract_chain}
create_account_by_pub_key chain_A ${contract_token} ${token_c_pubkey}

new_account chain_B ${contract_chain}
create_account_by_pub_key chain_B ${contract_token} ${token_c_pubkey}


new_account chain_A chengsong111
new_account chain_B chengsong111

new_account chain_A receivereos1
new_account chain_B receiverbos1


create_account_by_pub_key chain_A ibc2relay555 EOS5jLHvXsFPvUAawjc6qodxUbkBjWcU1j6GUghsNvsGPRdFV5ZWi
create_account_by_pub_key chain_B ibc2relay555 EOS5jLHvXsFPvUAawjc6qodxUbkBjWcU1j6GUghsNvsGPRdFV5ZWi







