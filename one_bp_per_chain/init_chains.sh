#!/usr/bin/env bash

cpath=`pwd`
bn=`basename $cpath`

if [ "$bn" != "one_bp_per_chain" ]; then
    echo "error! you must run this command in directory 'one_bp_per_chain'"
    return
fi

. ./../env.sh
. ./../init.sh
. ./../init_system_contracts.sh
. ./../chain_init.sh
