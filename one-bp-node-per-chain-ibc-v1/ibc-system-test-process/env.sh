#!/usr/bin/env bash

# According to the source code path on your local host, modify the following environment variables.
SYS_CONTRACTS_DIR=/Code/github.com/EOSIO/eosio.contracts/build/contracts    # the directory of system contracts
IBC_CONTRACTS_DIR=/Code/github.com/boscore/ibc_contracts/build              # the directory of IBC contracts

# As bellow, we use `EOS` as the token symbol of chain A, and `BOS` as the token symbol of chain B
# you can modify it according to your blockchains environment.
sym_chain_A=EOS
sym_chain_B=BOS

WALLET_DIR=~/tmp/eosio/eosio-wallet

cleos1='cleos -u http://127.0.0.1:8002'
cleos2='cleos -u http://127.0.0.1:9002'

contract_chain=ibc2chain555
contract_chain_folder=ibc.chain

contract_token=ibc2token555
contract_token_folder=ibc.token













































































eosio_test_test(){

    a=eostest12345
    create_one ${a}
    cleos set contract ${a} ${SYS_CONTRACTS_DIR}/eosio.test -x 1000 -p ${a}

    cleos transfer eosfirstacnt ${a}  "1.2345 EOS" -p eosfirstacnt


    cleos push action ${a} transfer '["eosfirstacnt","eostest12345","1.2356 EOS","memo"]' -p eosfirstacnt
}






#cleos push action eosio newaccount '{"creator":"eosio","name":"eosstore1111","owner":{"threshold":1,"keys":[{"key":"EOS6yuxPfeaDrAxgHCh6H4jT2kgGvuy11hPgfEPksa4SwxGr3ZC4d","weight":1}],"accounts":[],"waits":[]},"active":{"threshold":1,"keys":[{"key":"EOS6yuxPfeaDrAxgHCh6H4jT2kgGvuy11hPgfEPksa4SwxGr3ZC4d","weight":1}],"accounts":[],"waits":[]}}' -p  eosio

namelist(){
    cleos push action eosio namelist '["actor_blacklist", "insert", ["eosstoreff1a","eosstoreff1b","eosstoreff1c"]]'  -p eosio
    #cleos get table eosio eosstoreff1a userres
    #cleos get table eosio eosio minguar
}

hallo(){
    cleos get account eosstoreff1a
    cleos push action eosio setminguar '[1,1,1]'   -p eosio
    cleos push action eosio setlists '{
      "params": {
          "actor_blacklist":["111","222","333","444","555","aaa","bbb"],
          "contract_blacklist":["111","222"],
          "resource_greylist":["111"]
        }
    }' -p eosio

    cleos push action eosio setlists '{
      "params": {
          "actor_blacklist":[],
          "contract_blacklist":[],
          "resource_greylist":["111","222"]
        }
    }' -p eosio

    cleos push action eosio setlists '{
      "params": {
          "actor_blacklist": [
            "111",
            "222",
            "2221"
          ],
          "contract_blacklist": [
            "111",
            "222",
            "2221"
          ],
          "resource_greylist": [
            "111",
            "222"
          ]
        }
    }' -p eosio

    cleos get table eosio eosio lists
    cleos push action eosio setpriv '{"account": "eosio.msig", "is_priv": 1}' -p eosio
    cleos get table eosio eosio cntlrcfg
    cleos push action eosio setcontcfg '{
      "params": {
          "a": 101
        }
    }' -p eosio
}

