#!/usr/bin/env bash

. ../../env.sh

program_dir=./programs
if [ -d ${program_dir} ]; then
    rm -rf ${program_dir}
fi

mkdir -p ${program_dir}/nodeos/chain_A
mkdir -p ${program_dir}/nodeos/chain_B

mkdir -p ${program_dir}/ibc-relay/chain_A
mkdir -p ${program_dir}/ibc-relay/chain_B

cp $chain_A_nodeos ${program_dir}/nodeos/chain_A
cp $chain_B_nodeos ${program_dir}/nodeos/chain_B

cp $chain_A_relay ${program_dir}/ibc-relay/chain_A
cp $chain_B_relay ${program_dir}/ibc-relay/chain_B