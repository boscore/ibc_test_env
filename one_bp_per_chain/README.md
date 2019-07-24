
### How to Use

``` 
# Step 0:
# check ./env.sh and ensure all configurations are correct.

# note: <root> bellow means the root directory of this repository.

# Step 1: start chain A, chain B and tow realy-channel nodes 
# doing this accoreding functon "nodes_managment" in ./one_bp_per_chain/chains-ctrl/cluster.sh

# Step 2: init both blockchains
# open a new shell and run bellow commands
cd <root>/one_bp_per_chain
. init_chains.sh

# Step 3: deploy IBC contracts, init them and test
# open a new shell and run bellow commands
cd <root>
. task_ibc_test.sh

# test ibc transaction
transfer
transfer_fail
withdraw
withdraw_fail
```
