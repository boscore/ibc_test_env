#!/usr/bin/env bash

cpath=`pwd`
bn=`basename $cpath`

if [ "$bn" != "multi_bps_per_chain" ]; then
    echo "error! you must run this command in directory 'multi_bps_per_chain'"
    return
fi

. ./../env.sh
. ./../init.sh
. ./../init_system_contracts.sh
. ./../chain_init.sh
. ./bp_keys.sh

create_big_voter(){
    cleos=cleos1 sym=${chain_A_token_sym} && if [ "$1" == "chain_B" ];then cleos=cleos2 sym=${chain_B_token_sym} ;fi

    create_account $1 eosvoterbig1
    ${!cleos} transfer eosio eosvoterbig1 "200000100.0000 "$sym -p eosio
    ${!cleos} system delegatebw eosvoterbig1 eosvoterbig1 "100000000.0000 "$sym  "100000000.0000 "$sym -p eosvoterbig1
}
create_big_voter chain_A
create_big_voter chain_B

create_register_producers(){
    cleos=cleos1 && base=1 && if [ "$1" == "chain_B" ];then cleos=cleos2 && base=2;fi
    bunch=$2 # 1 or 2

    for i in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
        sfx=${bunch}${i}
        bpname=producer${base}1${sfx} && create_account $1 ${bpname}
        var=p${sfx}_pri && if [ "$3" == "import" ];then import_key ${!var}; fi
        var=p${sfx}_pub && ${!cleos} system regproducer ${bpname} ${!var} http://${bpname}.io 8
    done
}
create_register_producers chain_A 1 import
create_register_producers chain_A 2 import
create_register_producers chain_B 1
create_register_producers chain_B 2

update_schedule(){
    p=producer11
    if [ "$1" == "chain_B" ];then p=producer21 ;fi

    schedule1="${p}1a ${p}1b ${p}1c ${p}1d ${p}1e ${p}1f ${p}1g ${p}1h ${p}1i ${p}1j
               ${p}1k ${p}1l ${p}1m ${p}1n ${p}1o ${p}1p ${p}1q ${p}1r ${p}1s ${p}1t ${p}1u"

    schedule2="       ${p}1b ${p}1c ${p}1d ${p}1e ${p}1f ${p}1g ${p}1h ${p}1i ${p}1j
               ${p}1k ${p}1l ${p}1m ${p}1n ${p}1o ${p}1p ${p}1q ${p}1r ${p}1s ${p}1t ${p}1u ${p}1v"

    schedule3="              ${p}1c ${p}1d ${p}1e ${p}1f ${p}1g ${p}1h ${p}1i ${p}1j
               ${p}1k ${p}1l ${p}1m ${p}1n ${p}1o ${p}1p ${p}1q ${p}1r ${p}1s ${p}1t ${p}1u ${p}1v ${p}1w"

    schedule4="                     ${p}1d ${p}1e ${p}1f ${p}1g ${p}1h ${p}1i ${p}1j
               ${p}1k ${p}1l ${p}1m ${p}1n ${p}1o ${p}1p ${p}1q ${p}1r ${p}1s ${p}1t ${p}1u ${p}1v ${p}1w ${p}1x"
}

update_schedule chain_A && $cleos1 system voteproducer prods eosvoterbig1 ${schedule1} -p eosvoterbig1
# update_schedule chain_A && $cleos1 system voteproducer prods eosvoterbig1 ${schedule2} -p eosvoterbig1
# update_schedule chain_A && $cleos1 system voteproducer prods eosvoterbig1 ${schedule2} -p eosvoterbig1

update_schedule chain_B && $cleos2 system voteproducer prods eosvoterbig1 ${schedule1} -p eosvoterbig1
#update_schedule chain_B && $cleos2 system voteproducer prods eosvoterbig1 ${schedule2} -p eosvoterbig1
#update_schedule chain_B && $cleos2 system voteproducer prods eosvoterbig1 ${schedule3} -p eosvoterbig1



set_schedule(){
    schedule=schedule${1}
    update_schedule chain_A && $cleos1 system voteproducer prods eosvoterbig1 ${!schedule} -p eosvoterbig1
    update_schedule chain_B && $cleos2 system voteproducer prods eosvoterbig1 ${!schedule} -p eosvoterbig1
}




