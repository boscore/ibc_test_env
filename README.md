# ibc_test_env
IBC system test and debug local environment


### Explain
This repo provides two kinds of IBC cluster test environments, 
in the first environment, there is only one BP(`eosio`) in each chain, 
the corresponding shell scripts and instructions are located in folder **one_bp_per_chain**,
in the second environment, there are many BPs in each chain, 
in this way, the real blockchain network can be simulated and BP schedule replacement process can be tested,
the corresponding shell scripts and instructions are located in folder **multi_bps_per_chain**.


### How to Use
please refer to `./multi_bps_per_chain/README.md` and `one_bp_per_chain/README.md`


### Files interpretation

 - task_ibc_test.sh  
 scripts used to test ibc v2
 
 - task_ibc_test_v1.sh  
 scripts used to test ibc v1
 
 - v1_upgrade_to_v2_process.md  
 describe how to upgrade IBC system form v1 to v2
   
   