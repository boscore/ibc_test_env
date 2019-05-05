#!/usr/bin/env bash

programs_dir=./programs
if [ -d ${programs_dir} ]; then
    rm -rf ${programs_dir}
fi

mkdir -p ${programs_dir}/nodeos/chain-A
mkdir -p ${programs_dir}/nodeos/chain-B

mkdir -p ${programs_dir}/ibc-relay/chain-A
mkdir -p ${programs_dir}/ibc-relay/chain-B


# According to the source code path on your local host, modify the following copy path for nodeos and relay-nodeos please.

cp /Code/github.com/EOSIO/eos/build/programs/nodeos/nodeos ${programs_dir}/nodeos/chain-A
cp /Code/github.com/boscore/bos/build/programs/nodeos/nodeos ${programs_dir}/nodeos/chain-B

cp /Code/github.com/boscore/ibc_plugin_eos/build/programs/nodeos/nodeos ${programs_dir}/ibc-relay/chain-A
cp /Code/github.com/boscore/ibc_plugin_bos/build/programs/nodeos/nodeos ${programs_dir}/ibc-relay/chain-B
