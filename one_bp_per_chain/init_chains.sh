#!/usr/bin/env bash

cpath=`pwd`
bn=`basename $cpath`

if [ "$bn" != "one_bp_per_chain" ]; then
    echo "error! you must run this command in directory 'one_bp_per_chain'"
    return
fi

curl -X POST http://127.0.0.1:4002/v1/producer/schedule_protocol_feature_activations -d \
     '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}' | jq

. ./../env.sh
. ./../init.sh
. ./../init_system_contracts.sh
. ./../chain_init.sh
