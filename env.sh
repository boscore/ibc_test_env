#!/usr/bin/env bash


# chain name can be "EOS" or "BOS", consensus can be "pipeline" or "batch", ibc_plugin_version can be 1 or 2
chain_A=EOS_pipeline
chain_B=BOS_batch

# config
src_base_dir=/Code/github.com
nodeos_file=build/programs/nodeos/nodeos

eosio_nodeos=${src_base_dir}/EOSIO/eos/${nodeos_file}
boscore_nodeos=${src_base_dir}/boscore/bos/${nodeos_file}

eosio_ibc_plugin_nodeos=${src_base_dir}/boscore/ibc_plugin_eos/${nodeos_file}
boscore_ibc_plugin_nodeos=${src_base_dir}/boscore/ibc_plugin_bos/${nodeos_file}

eosio_sys_contracts_dir=${src_base_dir}/EOSIO/eosio.contracts/build/contracts
bos_sys_contracts_dir=${src_base_dir}/boscore/bos.contracts/build/contracts
ibc_contracts_dir=${src_base_dir}/boscore/ibc_contracts/build

eosio_launcher=${src_base_dir}/boscore/bos/build/programs/eosio-launcher/eosio-launcher
cleos=${src_base_dir}/EOSIO/eos/build/programs/cleos/cleos

get_chain_type(){ echo $1 | cut -c -3; }
get_chain_consensus(){ echo $1 | cut -c 5-; }

if [ `get_chain_type $chain_A` == "EOS" ];then      
    chain_A_nodeos=$eosio_nodeos
    chain_A_sys_contracts_dir=$eosio_sys_contracts_dir
elif [ `get_chain_type $chain_A` == "BOS" ];then    
    chain_A_nodeos=$boscore_nodeos
    chain_A_sys_contracts_dir=$bos_sys_contracts_dir
else echo "chain name error!" && return ;fi

if [ `get_chain_type $chain_B` == "EOS" ];then      
    chain_B_nodeos=$eosio_nodeos
    chain_B_sys_contracts_dir=$eosio_sys_contracts_dir
elif [ `get_chain_type $chain_B` == "BOS" ];then    
    chain_B_nodeos=$boscore_nodeos
    chain_B_sys_contracts_dir=$bos_sys_contracts_dir
else echo "chain name error!" && return ;fi

chain_A_relay=$eosio_ibc_plugin_nodeos
chain_B_relay=$boscore_ibc_plugin_nodeos

ibc_contracts_dir=$ibc_contracts_dir


check_configs(){
    echo "chain_A_nodeos:            " $chain_A_nodeos
    echo "chain_A_relay:             " $chain_A_relay
    echo "chain_A_sys_contracts_dir: " $chain_A_sys_contracts_dir

    echo "chain_B_nodeos:            " $chain_B_nodeos
    echo "chain_B_relay:             " $chain_B_relay
    echo "chain_B_sys_contracts_dir: " $chain_B_sys_contracts_dir
}
# check_configs


chain_A_token_sym=EOS
chain_B_token_sym=BOS
chain_A_name=eos
chain_B_name=bos

# three accounts
contract_chain=ibc2chain555
contract_token=ibc2token555
relay_account=ibc2relay555

# ibc.token contract account's public key and private key
token_c_pubkey=EOS6Sc4BuA7dEGRU6u4VSuEKusESFe61qD8LmguGEMULrghKDSPaU
token_c_prikey=5K79wAY8rgPwWQSRmyQa2BR8vPicieJdLCXL3cM5Db77QnsJess

receiver=receiver1111

WALLET_DIR=~/tmp/eosio/eosio-wallet

cleos1='cleos -u http://127.0.0.1:8002'
cleos2='cleos -u http://127.0.0.1:9002'

