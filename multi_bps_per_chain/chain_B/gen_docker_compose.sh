#!/usr/bin/env bash

read -d '' bios << EOF
version: '3'

networks:
  default:
    external:
      name: chain_b

services:
  bp_bios:
    image: "boscore/bos:v3.0.0"
    command: /opt/eosio/bin/nodeos -d /opt/eosio/bin/data-dir --config-dir /opt/eosio/bin/config-dir
    container_name: bp_bios
    ports:
    - 9002:9002
    - 9976:9976
    volumes:
    - ./staging/etc/eosio/node_bios:/opt/eosio/bin/config-dir
    cap_add:
    - IPC_LOCK
    stop_grace_period: 10m
EOF

echo "$bios"  > docker-compose.yml

for i in `seq -w 0 21`; do
echo """
  bp_$i:
    image: boscore/bos:v3.0.0
    command: /opt/eosio/bin/nodeos -d /opt/eosio/bin/data-dir --config-dir /opt/eosio/bin/config-dir
    container_name: bp_$i
    ports:
    - $((8900+10#$i)):$((8900+10#$i))
    - $((9900+10#$i)):$((9900+10#$i))
    volumes:
    - ./staging/etc/eosio/node_$i:/opt/eosio/bin/config-dir
    cap_add:
    - IPC_LOCK
    stop_grace_period: 10m
"""  >> docker-compose.yml
done


network_prepare(){
    docker network rm chain_b       >/dev/null 2>/dev/null
    docker network create chain_b   >/dev/null
    host_ip=`docker network inspect chain_b | jq .[0].IPAM.Config[0].Gateway | sed 's/\"//g'`
    sed 's/p2p-peer-address = localhost/p2p-peer-address = '$host_ip'/g' ./config.sh > ./config_docker.sh
}
network_prepare
