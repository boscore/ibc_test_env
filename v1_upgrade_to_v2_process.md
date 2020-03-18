

## Upgrade Process from v1 to v2 

```
# Step 1:
Wait all pending ibc_trx finished, then stop all relay nodes.

# Step 2:
# checkout branch v1-upgrade of https://github.com/boscore/ibc_contracts, and build
# Then, set both contracts to both blockchains.

# Step 3: 
# Call forceinit action of four contracts on both chains.
$cleos_a push action ${contract_chain} forceinit '[]' -x 1000 -p ${contract_chain}
$cleos_a push action ${contract_token} forceinit '[]' -x 1000 -p ${contract_token}
$cleos_b push action ${contract_chain} forceinit '[]' -x 1000 -p ${contract_chain}
$cleos_b push action ${contract_token} forceinit '[]' -x 1000 -p ${contract_token}

# Then check these four contracts' table scope.
$cleos_a get scope ${contract_chain}
$cleos_a get scope ${contract_token}
$cleos_b get scope ${contract_chain}
$cleos_b get scope ${contract_token}

# ensure that the output of get scope of ${contract_chain} must be as bellow:
{
  "rows": [],
  "more": ""
}

# and ensure only two "rows" records related to table "accounts" are included in the output of get scope of ${contract_token},
# such as bellow, except the code, scope, payer and count, these items are different according your blockchain envirement.
{
  "rows": [{
      "code": "ibc2token555",
      "scope": "chaina2acnt1",
      "table": "accounts",
      "payer": "ibc2token555",
      "count": 1
    },{
      "code": "ibc2token555",
      "scope": "ibc2token555",
      "table": "accounts",
      "payer": "ibc2token555",
      "count": 1
    }
  ],
  "more": ""
}

# Step 4:
# checkout branch master (which is v2) of https://github.com/boscore/ibc_contracts, and build
# Then, set both contracts to both blockchains.

# Step 5:
# Init ibc.chain and ibc.token contracts on both chain.

# Step 6:
# start ibc_plugin v2 relay nodes.
```

## Upgrade Process from v2 pipeline to v2 batch
``` 
# Step 1:
# stop all relay nodes.

# Step 2:
# Call action "setglobal" to corresponding ${contract_chain} to modify "consensus_algo".

# Step3:
# start all relay nodes. 
``` 
