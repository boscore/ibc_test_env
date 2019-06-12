#!/usr/bin/env bash

read -d '' config_bios_common << EOF
enable-stale-production = true
plugin = eosio::producer_plugin
plugin = eosio::producer_api_plugin
plugin = eosio::chain_api_plugin
plugin = eosio::net_plugin
contracts-console = true
max-transaction-time = 1000

producer-name = eosio
signature-provider = EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV=KEY:5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
EOF

read -d '' config_bios_chain_A << EOF
p2p-server-address = localhost:8001
p2p-listen-endpoint = 0.0.0.0:8001
http-server-address = 127.0.0.1:8002
EOF

read -d '' config_bios_chain_B << EOF
p2p-server-address = localhost:9001
p2p-listen-endpoint = 0.0.0.0:9001
http-server-address = 127.0.0.1:9002
EOF



read -d '' config_relay_common << EOF
plugin = eosio::chain_api_plugin
p2p-max-nodes-per-host = 50
max-clients = 25
contracts-console = true
max-transaction-time = 1000

plugin = eosio::ibc::ibc_plugin
ibc-chain-contract = ibc2chain555
ibc-token-contract = ibc2token555
ibc-relay-name = ibc2relay555
ibc-relay-private-key = EOS5jLHvXsFPvUAawjc6qodxUbkBjWcU1j6GUghsNvsGPRdFV5ZWi=KEY:5K2ezP476ThBo9zSrDqTofzaLiKrQaLEkAzv3USdeaFFrD5LAX1
EOF

read -d '' config_relay_chain_A << EOF
p2p-server-address = localhost:8011
p2p-listen-endpoint = 0.0.0.0:8011
http-server-address = 127.0.0.1:8012
p2p-peer-address = localhost:8001

ibc-listen-endpoint = 0.0.0.0:6001
#ibc-peer-address = 127.0.0.1:6002  # comment out the line

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF

read -d '' config_relay_chain_B << EOF
p2p-server-address = localhost:9011
p2p-listen-endpoint = 0.0.0.0:9011
http-server-address = 127.0.0.1:9012
p2p-peer-address = localhost:9001

#ibc-listen-endpoint = 0.0.0.0:6002 # comment out the line
ibc-peer-address = 127.0.0.1:6001

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

