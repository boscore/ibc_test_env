#!/usr/bin/env bash

. ../../env.sh

program_dir=./programs
if [ -d ${program_dir} ]; then
    rm -rf ${program_dir}
fi

mkdir -p ${program_dir}/nodeos/chain_a
mkdir -p ${program_dir}/nodeos/chain_b
mkdir -p ${program_dir}/nodeos/chain_c
mkdir -p ${program_dir}/nodeos/chain_d

mkdir -p ${program_dir}/ibc-relay/chain_a
mkdir -p ${program_dir}/ibc-relay/chain_b
mkdir -p ${program_dir}/ibc-relay/chain_c
mkdir -p ${program_dir}/ibc-relay/chain_d

cp $chain_a_nodeos ${program_dir}/nodeos/chain_a
cp $chain_b_nodeos ${program_dir}/nodeos/chain_b
cp $chain_c_nodeos ${program_dir}/nodeos/chain_c
cp $chain_d_nodeos ${program_dir}/nodeos/chain_d

cp $chain_a_relay ${program_dir}/ibc-relay/chain_a
cp $chain_b_relay ${program_dir}/ibc-relay/chain_b
cp $chain_c_relay ${program_dir}/ibc-relay/chain_c
cp $chain_d_relay ${program_dir}/ibc-relay/chain_d