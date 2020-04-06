#!/usr/bin/env bash


# chain name can be "eos" or "bos", consensus can be "pipeline" or "batch", ibc_plugin_version can be 1 or 2
chain_a=eos_pipeline
chain_b=bos_batch
chain_c=bos_batch
chain_d=bos_batch


# config
src_base_dir=~/Code/github.com
nodeos_file=build/programs/nodeos/nodeos

eosio_nodeos=${src_base_dir}/EOSIO/eos/${nodeos_file}
boscore_nodeos=${src_base_dir}/boscore/bos/${nodeos_file}

#eosio_ibc_plugin_nodeos=${src_base_dir}/boscore/ibc_plugin_eos/${nodeos_file}
eosio_ibc_plugin_nodeos=${src_base_dir}/boscore/eos/${nodeos_file}
boscore_ibc_plugin_nodeos=${src_base_dir}/boscore/ibc_plugin_bos/${nodeos_file}

#eosio_sys_contracts_dir=${src_base_dir}/EOSIO/eosio.contracts/build/contracts
#bos_sys_contracts_dir=${src_base_dir}/boscore/bos.contracts/build/contracts
#ibc_contracts_dir=${src_base_dir}/boscore/ibc_contracts/build
#ibc_token_hub_dir=${src_base_dir}/boscore/ibc_contracts/build/hub


eosio_sys_contracts_dir=${src_base_dir}/bins/eosio.contracts/current
bos_sys_contracts_dir=${src_base_dir}/bins/bos.contracts/current
ibc_contracts_dir=${src_base_dir}/bins/ibc_contracts/current
ibc_token_hub_dir=${src_base_dir}/bins/ibc_contracts/current/hub


eosio_launcher=${src_base_dir}/boscore/bos/build/programs/eosio-launcher/eosio-launcher
cleos=${src_base_dir}/boscore/bos/build/programs/cleos/cleos

get_chain_type(){ echo $1 | cut -c -3; }
get_chain_consensus(){ echo $1 | cut -c 5-; }

if [ `get_chain_type $chain_a` == "eos" ];then
    chain_a_nodeos=$eosio_nodeos
    chain_a_sys_contracts_dir=$eosio_sys_contracts_dir
    chain_a_relay=$eosio_ibc_plugin_nodeos
elif [ `get_chain_type $chain_a` == "bos" ];then
    chain_a_nodeos=$boscore_nodeos
    chain_a_sys_contracts_dir=$bos_sys_contracts_dir
    chain_a_relay=$boscore_ibc_plugin_nodeos
else echo "chain name error!" && return ;fi

if [ `get_chain_type $chain_b` == "eos" ];then
    chain_b_nodeos=$eosio_nodeos
    chain_b_sys_contracts_dir=$eosio_sys_contracts_dir
    chain_b_relay=$eosio_ibc_plugin_nodeos
elif [ `get_chain_type $chain_b` == "bos" ];then
    chain_b_nodeos=$boscore_nodeos
    chain_b_sys_contracts_dir=$bos_sys_contracts_dir
    chain_b_relay=$boscore_ibc_plugin_nodeos
else echo "chain name error!" && return ;fi

if [ `get_chain_type $chain_c` == "eos" ];then
    chain_c_nodeos=$eosio_nodeos
    chain_c_sys_contracts_dir=$eosio_sys_contracts_dir
    chain_c_relay=$eosio_ibc_plugin_nodeos
elif [ `get_chain_type $chain_c` == "bos" ];then
    chain_c_nodeos=$boscore_nodeos
    chain_c_sys_contracts_dir=$bos_sys_contracts_dir
    chain_c_relay=$boscore_ibc_plugin_nodeos
else echo "chain name error!" && return ;fi

if [ `get_chain_type $chain_d` == "eos" ];then
    chain_d_nodeos=$eosio_nodeos
    chain_d_sys_contracts_dir=$eosio_sys_contracts_dir
    chain_d_relay=$eosio_ibc_plugin_nodeos
elif [ `get_chain_type $chain_d` == "bos" ];then
    chain_d_nodeos=$boscore_nodeos
    chain_d_sys_contracts_dir=$bos_sys_contracts_dir
    chain_d_relay=$boscore_ibc_plugin_nodeos
else echo "chain name error!" && return ;fi


check_configs(){
    echo "chain_a_nodeos:            " $chain_a_nodeos
    echo "chain_a_relay:             " $chain_a_relay
    echo "chain_a_sys_contracts_dir: " $chain_a_sys_contracts_dir

    echo "chain_b_nodeos:            " $chain_b_nodeos
    echo "chain_b_relay:             " $chain_b_relay
    echo "chain_b_sys_contracts_dir: " $chain_b_sys_contracts_dir

    echo "chain_c_nodeos:            " $chain_c_nodeos
    echo "chain_c_relay:             " $chain_c_relay
    echo "chain_c_sys_contracts_dir: " $chain_c_sys_contracts_dir

    echo "chain_d_nodeos:            " $chain_d_nodeos
    echo "chain_d_relay:             " $chain_d_relay
    echo "chain_d_sys_contracts_dir: " $chain_d_sys_contracts_dir
}
# check_configs


chain_a_token_sym=TOA
chain_b_token_sym=TOB
chain_c_token_sym=TOC
chain_d_token_sym=TOD

chain_a_name=cha
chain_b_name=chb
chain_c_name=chc
chain_d_name=chd

# three accounts
contract_chain=ibc2chain555
contract_token=ibc2token555
relay_account=ibc2relay555

#
contract_chain_b=ibc2chain22b
contract_chain_c=ibc2chain22c
contract_chain_d=ibc2chain22d

#
hub_account=ibc2hub55555


# ibc.token contract account's public key and private key
token_c_pubkey=EOS6Sc4BuA7dEGRU6u4VSuEKusESFe61qD8LmguGEMULrghKDSPaU
token_c_prikey=5K79wAY8rgPwWQSRmyQa2BR8vPicieJdLCXL3cM5Db77QnsJess

receiver=receiver1111

WALLET_DIR=~/tmp/eosio/eosio-wallet

cleos_a='cleos -u http://127.0.0.1:4002'
cleos_b='cleos -u http://127.0.0.1:5002'
cleos_c='cleos -u http://127.0.0.1:6002'
cleos_d='cleos -u http://127.0.0.1:7002'
