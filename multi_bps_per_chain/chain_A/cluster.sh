#!/usr/bin/env bash

cpath=`pwd`
bn=`basename $cpath`

if [ "$bn" != "chain_A" ]; then
    echo "error! you must run this command in directory 'chain_A'"
    exit
fi

. ./../../env.sh
. ./../shared_cluster.sh
