#!/usr/bin/env bash

read -d '' config_bios_common << EOF
enable-stale-production = true
plugin = eosio::producer_plugin
plugin = eosio::producer_api_plugin
plugin = eosio::chain_api_plugin
plugin = eosio::net_plugin
contracts-console = true
max-transaction-time = 2000
p2p-max-nodes-per-host = 20

producer-name = eosio
signature-provider = EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV=KEY:5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
EOF

read -d '' config_bios_chain_a << EOF
p2p-server-address = localhost:4001
p2p-listen-endpoint = 0.0.0.0:4001
http-server-address = 127.0.0.1:4002
wasm-runtime = eos-vm-jit
EOF

read -d '' config_bios_chain_b << EOF
p2p-server-address = localhost:5001
p2p-listen-endpoint = 0.0.0.0:5001
http-server-address = 127.0.0.1:5002
EOF


read -d '' config_bios_chain_c << EOF
p2p-server-address = localhost:6001
p2p-listen-endpoint = 0.0.0.0:6001
http-server-address = 127.0.0.1:6002
EOF


read -d '' config_bios_chain_d << EOF
p2p-server-address = localhost:7001
p2p-listen-endpoint = 0.0.0.0:7001
http-server-address = 127.0.0.1:7002
EOF


read -d '' config_relay_common << EOF
plugin = eosio::chain_api_plugin
p2p-max-nodes-per-host = 50
max-clients = 25
contracts-console = true
max-transaction-time = 2000

plugin = eosio::ibc::ibc_plugin
ibc-max-clients = 20
ibc-max-nodes-per-host = 20
ibc-token-contract = ibc2token555
ibc-relay-name = ibc2relay555
ibc-relay-private-key = EOS5jLHvXsFPvUAawjc6qodxUbkBjWcU1j6GUghsNvsGPRdFV5ZWi=KEY:5K2ezP476ThBo9zSrDqTofzaLiKrQaLEkAzv3USdeaFFrD5LAX1
EOF

read -d '' config_relay_chain_a << EOF
p2p-server-address = localhost:4011
p2p-listen-endpoint = 0.0.0.0:4011
http-server-address = 127.0.0.1:4012
p2p-peer-address = localhost:4001

ibc-listen-endpoint = 0.0.0.0:4211
#ibc-peer-address = 127.0.0.1:4212  # comment out the line

ibc-chain-contract = ibc2chain555

wasm-runtime = eos-vm-jit

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF

read -d '' config_relay_chain_a2b << EOF
p2p-server-address = localhost:4011
p2p-listen-endpoint = 0.0.0.0:4011
http-server-address = 127.0.0.1:4012
p2p-peer-address = localhost:4001

ibc-listen-endpoint = 0.0.0.0:4211
#ibc-peer-address = 127.0.0.1:4212  # comment out the line

# ibc-chain-contract = ibc2chain22b
ibc-chain-contract = ibc2chain555
wasm-runtime = eos-vm-jit

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF

read -d '' config_relay_chain_a2c << EOF
p2p-server-address = localhost:4021
p2p-listen-endpoint = 0.0.0.0:4021
http-server-address = 127.0.0.1:4022
p2p-peer-address = localhost:4001

ibc-listen-endpoint = 0.0.0.0:4221
#ibc-peer-address = 127.0.0.1:4222  # comment out the line

ibc-chain-contract = ibc2chain22c

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF

read -d '' config_relay_chain_a2d << EOF
p2p-server-address = localhost:4031
p2p-listen-endpoint = 0.0.0.0:4031
http-server-address = 127.0.0.1:4032
p2p-peer-address = localhost:4001

ibc-listen-endpoint = 0.0.0.0:4231
#ibc-peer-address = 127.0.0.1:4232  # comment out the line

ibc-chain-contract = ibc2chain22d

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF


read -d '' config_relay_chain_b << EOF
p2p-server-address = localhost:5011
p2p-listen-endpoint = 0.0.0.0:5011
http-server-address = 127.0.0.1:5012
p2p-peer-address = localhost:5001

ibc-listen-endpoint = 0.0.0.0:5202
ibc-peer-address = 127.0.0.1:4211

ibc-chain-contract = ibc2chain555

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF


read -d '' config_relay_chain_c << EOF
p2p-server-address = localhost:6011
p2p-listen-endpoint = 0.0.0.0:6011
http-server-address = 127.0.0.1:6012
p2p-peer-address = localhost:6001

ibc-listen-endpoint = 0.0.0.0:6202
ibc-peer-address = 127.0.0.1:4221

ibc-chain-contract = ibc2chain555

ibc-peer-private-key = EOS65jr3UsJi2Lpe9GbxDUmJYUpWeBTJNrqiDq2hYimQyD2kThfAE=KEY:5KHJeTFezCwFCYsaA4Hm2sqEXvxmD2zkgvs3fRT2KarWLiTwv71
EOF


read -d '' config_relay_chain_d << EOF
p2p-server-address = localhost:7011
p2p-listen-endpoint = 0.0.0.0:7011
http-server-address = 127.0.0.1:7012
p2p-peer-address = localhost:7001

ibc-listen-endpoint = 0.0.0.0:7202
ibc-peer-address = 127.0.0.1:4231

ibc-chain-contract = ibc2chain555

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
      "level": "info",
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

