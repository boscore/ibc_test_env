#!/usr/bin/env bash

cpath=`pwd`
bn=`basename $cpath`

if [ "$bn" != "multi_bps_per_chain" ]; then
    echo "error! you must run this command in directory 'multi_bps_per_chain'"
    return
fi

curl -X POST http://127.0.0.1:8002/v1/producer/schedule_protocol_feature_activations -d \
     '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}' | jq


. ./../env.sh
. ./../init.sh
. ./../init_system_contracts.sh
. ./../chain_init.sh
. ./bp_keys.sh

create_big_voter(){
    cleos=cleos_a sym=${chain_a_token_sym} && if [ "$1" == "chain_b" ];then cleos=cleos_b sym=${chain_b_token_sym} ;fi

    create_account $1 eosvoterbig1
    ${!cleos} transfer eosio eosvoterbig1 "200000100.0000 "$sym -p eosio
    ${!cleos} system delegatebw eosvoterbig1 eosvoterbig1 "100000000.0000 "$sym  "100000000.0000 "$sym -p eosvoterbig1
}
create_big_voter chain_a
create_big_voter chain_b

create_register_producers(){
    cleos=cleos_a && base=1 && if [ "$1" == "chain_b" ];then cleos=cleos_b && base=2;fi
    bunch=$2 # 1 or 2

    for i in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
        sfx=${bunch}${i}
        bpname=producer${base}1${sfx} && create_account $1 ${bpname}
        var=p${sfx}_pri && if [ "$3" == "import" ];then import_key ${!var}; fi
        var=p${sfx}_pub && ${!cleos} system regproducer ${bpname} ${!var} http://${bpname}.io 8
    done
}
create_register_producers chain_a 1 import
create_register_producers chain_a 2 import
create_register_producers chain_b 1
create_register_producers chain_b 2

update_schedule(){
    p=producer11
    if [ "$1" == "chain_b" ];then p=producer21 ;fi

    schedule1="${p}1a ${p}1b ${p}1c ${p}1d ${p}1e ${p}1f ${p}1g ${p}1h ${p}1i ${p}1j
               ${p}1k ${p}1l ${p}1m ${p}1n ${p}1o ${p}1p ${p}1q ${p}1r ${p}1s ${p}1t ${p}1u"

    schedule2="       ${p}1b ${p}1c ${p}1d ${p}1e ${p}1f ${p}1g ${p}1h ${p}1i ${p}1j
               ${p}1k ${p}1l ${p}1m ${p}1n ${p}1o ${p}1p ${p}1q ${p}1r ${p}1s ${p}1t ${p}1u ${p}1v"

    schedule3="              ${p}1c ${p}1d ${p}1e ${p}1f ${p}1g ${p}1h ${p}1i ${p}1j
               ${p}1k ${p}1l ${p}1m ${p}1n ${p}1o ${p}1p ${p}1q ${p}1r ${p}1s ${p}1t ${p}1u ${p}1v ${p}1w"

    schedule4="                     ${p}1d ${p}1e ${p}1f ${p}1g ${p}1h ${p}1i ${p}1j
               ${p}1k ${p}1l ${p}1m ${p}1n ${p}1o ${p}1p ${p}1q ${p}1r ${p}1s ${p}1t ${p}1u ${p}1v ${p}1w ${p}1x"
}

update_schedule chain_a && $cleos_a system voteproducer prods eosvoterbig1 ${schedule1} -p eosvoterbig1
# update_schedule chain_a && $cleos_a system voteproducer prods eosvoterbig1 ${schedule2} -p eosvoterbig1
# update_schedule chain_a && $cleos_a system voteproducer prods eosvoterbig1 ${schedule2} -p eosvoterbig1

update_schedule chain_b && $cleos_b system voteproducer prods eosvoterbig1 ${schedule1} -p eosvoterbig1
#update_schedule chain_b && $cleos_b system voteproducer prods eosvoterbig1 ${schedule2} -p eosvoterbig1
#update_schedule chain_b && $cleos_b system voteproducer prods eosvoterbig1 ${schedule3} -p eosvoterbig1



set_schedule(){
    schedule=schedule${1}
    update_schedule chain_a && $cleos_a system voteproducer prods eosvoterbig1 ${!schedule} -p eosvoterbig1
    update_schedule chain_b && $cleos_b system voteproducer prods eosvoterbig1 ${!schedule} -p eosvoterbig1
}




