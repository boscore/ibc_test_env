
### How to Use

``` 
# Step 0:
# check ./env.sh and ensure all configurations are correct.

# note: <root> bellow means the root directory of this repository.

# Step 1: start blockchain A
# open a new shell and run bellow commands
cd <root>/multi_bps_per_chain/chain_a
./cluster.sh init
./cluster.sh start
./cluster.sh check
./cluster.sh log bios


# Step 2: start blockchain B
# open a new shell and run bellow commands
cd <root>/multi_bps_per_chain/chain_b
./cluster.sh init
./cluster.sh start
./cluster.sh check
./cluster.sh log bios


# Step 3: init both blockchains
# open a new shell and run bellow commands
cd <root>/multi_bps_per_chain
. init_chains.sh


# Step 4: start relay-channel
# open a new shell and run bellow commands
cd <root>/multi_bps_per_chain/relays
./cluster.sh init
# then you can start one relay-channel according functon "relay_channel_1" in ./multi_bps_per_chain/relays/cluster.sh
# and you can start another relay-channel according functon "relay_channel_2" in ./multi_bps_per_chain/relays/cluster.sh


# Step 5: deploy IBC contracts, init them and test
# open a new shell and run bellow commands
cd <root>
. task_ibc_test.sh

# test ibc transaction
transfer
transfer_fail
withdraw
withdraw_fail

```
