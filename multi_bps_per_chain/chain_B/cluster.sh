#!/usr/bin/env bash

cpath=`pwd`
bn=`basename $cpath`

if [ "$bn" != "chain_B" ]; then
    echo "error! you must run this command in directory 'chain_B'"
    exit
fi

. ./../../env.sh
. ./../shared_cluster.sh