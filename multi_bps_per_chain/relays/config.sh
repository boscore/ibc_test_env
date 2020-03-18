#!/usr/bin/env bash

read -d '' config_relay_common << EOF
plugin = eosio::chain_api_plugin
p2p-max-nodes-per-host = 50
max-clients = 50
max-transaction-time = 1000
contracts-console = true

plugin = eosio::ibc::ibc_plugin
ibc-chain-contract = ibc2chain555
ibc-token-contract = ibc2token555
ibc-relay-name = ibc2relay555
ibc-relay-private-key = EOS5jLHvXsFPvUAawjc6qodxUbkBjWcU1j6GUghsNvsGPRdFV5ZWi=KEY:5K2ezP476ThBo9zSrDqTofzaLiKrQaLEkAzv3USdeaFFrD5LAX1
EOF


read -d '' config_relay1_chain_a << EOF
http-server-address = 127.0.0.1:28800

p2p-server-address = localhost:8011
p2p-listen-endpoint = 0.0.0.0:8011

p2p-peer-address = localhost:9876
p2p-peer-address = localhost:9805
p2p-peer-address = localhost:9810
p2p-peer-address = localhost:9815
p2p-peer-address = localhost:9820

ibc-listen-endpoint = 0.0.0.0:6001
#ibc-peer-address = 127.0.0.1:6002  # comment out the line

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF


read -d '' config_relay1_chain_b << EOF
http-server-address = 127.0.0.1:28900

p2p-server-address = localhost:9011
p2p-listen-endpoint = 0.0.0.0:9011

p2p-peer-address = localhost:9976
p2p-peer-address = localhost:9905
p2p-peer-address = localhost:9910
p2p-peer-address = localhost:9915
p2p-peer-address = localhost:9920

ibc-listen-endpoint = 0.0.0.0:6002
ibc-peer-address = 127.0.0.1:6001

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF



read -d '' config_relay2_chain_a << EOF
http-server-address = 127.0.0.1:28801

p2p-server-address = localhost:8012
p2p-listen-endpoint = 0.0.0.0:8012

p2p-peer-address = localhost:9876
p2p-peer-address = localhost:9805
p2p-peer-address = localhost:9810
p2p-peer-address = localhost:9815
p2p-peer-address = localhost:9820

ibc-listen-endpoint = 0.0.0.0:6003
#ibc-peer-address = 127.0.0.1:6004  # comment out the line

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF


read -d '' config_relay2_chain_b << EOF
http-server-address = 127.0.0.1:28901

p2p-server-address = localhost:9012
p2p-listen-endpoint = 0.0.0.0:9012

p2p-peer-address = localhost:9976
p2p-peer-address = localhost:9905
p2p-peer-address = localhost:9910
p2p-peer-address = localhost:9915
p2p-peer-address = localhost:9920

ibc-listen-endpoint = 0.0.0.0:6004
ibc-peer-address = 127.0.0.1:6003

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF


read -d '' logging << EOF
{
  "includes": [],
  "appenders": [{
      "name": "stderr",
      "type": "console",
      "args": {
        "stream": "std_error",
        "level_colors": [{
            "level": "debug",
            "color": "green"
          },{
            "level": "warn",
            "color": "brown"
          },{
            "level": "error",
            "color": "red"
          }
        ]
      },
      "enabled": true
    },{
      "name": "stdout",
      "type": "console",
      "args": {
        "stream": "std_out",
        "level_colors": [{
            "level": "debug",
            "color": "green"
          },{
            "level": "warn",
            "color": "brown"
          },{
            "level": "error",
            "color": "red"
          }
        ]
      },
      "enabled": true
    }
  ],
  "loggers": [{
      "name": "default",
      "level": "debug",
      "enabled": true,
      "additivity": false,
      "appenders": [
        "stderr"
      ]
    }
  ]
}
EOF




read -d '' logging_v << EOF
{
  "includes": [],
  "appenders": [{
      "name": "stderr",
      "type": "console",
      "args": {
        "stream": "std_error",
        "level_colors": [{
            "level": "debug",
            "color": "green"
          },{
            "level": "warn",
            "color": "brown"
          },{
            "level": "error",
            "color": "red"
          }
        ]
      },
      "enabled": true
    },{
      "name": "stdout",
      "type": "console",
      "args": {
        "stream": "std_out",
        "level_colors": [{
            "level": "debug",
            "color": "green"
          },{
            "level": "warn",
            "color": "brown"
          },{
            "level": "error",
            "color": "red"
          }
        ]
      },
      "enabled": true
    }
  ],
  "loggers": [{
      "name": "default",
      "level": "debug",
      "enabled": true,
      "additivity": false,
      "appenders": [
        "stderr"
      ]
    },
    {
      "name": "ibc_plugin_impl",
      "level": "debug",
      "enabled": true,
      "additivity": false,
      "appenders": [
        "stderr"
      ]
    }
  ]
}
EOF

