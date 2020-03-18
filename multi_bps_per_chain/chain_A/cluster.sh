#!/usr/bin/env bash

cpath=`pwd`
bn=`basename $cpath`

if [ "$bn" != "chain_a" ]; then
    echo "error! you must run this command in directory 'chain_a'"
    exit
fi

. ./../../env.sh
. ./../shared_cluster.sh
