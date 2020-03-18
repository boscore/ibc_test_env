#!/usr/bin/env bash

cpath=`pwd`
bn=`basename $cpath`

if [ "$bn" != "chain_b" ]; then
    echo "error! you must run this command in directory 'chain_b'"
    exit
fi

. ./../../env.sh
. ./../shared_cluster.sh