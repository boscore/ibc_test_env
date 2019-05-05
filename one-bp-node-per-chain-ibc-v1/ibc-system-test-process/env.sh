#!/usr/bin/env bash

# According to the source code path on your local host, modify the following environment variables.
SYS_CONTRACTS_DIR=/Code/github.com/EOSIO/eosio.contracts/build/contracts    # the directory of system contracts
IBC_CONTRACTS_DIR=/Code/github.com/boscore/ibc_contracts/build              # the directory of IBC contracts


# As bellow, we use `EOS` as the token symbol of chain A, 'eos' as the name of chain A;
# and `BOS` as the token symbol of chain B, 'bos' as the name of chain B;
# you can modify it according to your blockchains environment.
sym_chain_A=EOS
sym_chain_B=BOS
name_chain_A=eos
name_chain_B=bos

# Local wallet directory
WALLET_DIR=~/tmp/eosio/eosio-wallet

cleos1='cleos -u http://127.0.0.1:8002'
cleos2='cleos -u http://127.0.0.1:9002'

# three accounts
contract_chain=ibc2chain555
contract_token=ibc2token555
relay_account=ibc2relay555

# ibc.token contract account's public key and private key
token_c_pubkey=EOS6Sc4BuA7dEGRU6u4VSuEKusESFe61qD8LmguGEMULrghKDSPaU
token_c_prikey=5K79wAY8rgPwWQSRmyQa2BR8vPicieJdLCXL3cM5Db77QnsJess


receiver=receiver1111