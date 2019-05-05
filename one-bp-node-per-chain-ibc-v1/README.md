
This is a test environment with only one BP node and one relay node per blockchain.
Before starting the test, you need to compile the nodeos and relay nodes of the two blockchains.

You need to modify the environment variables according to your local environment.
The variables that need to be modified in files include (Please modify them according to the comments): 
 - ./chains-and-relays-management/init.sh 
 - ./ibc-system-test-process/env.sh
 - ./ibc-system-test-process/task_ibc_init.sh
 - ./ibc-system-test-process/task_ibc_test.sh

These nodes use many ports, make sure these ports are not in use, 
refer to file ./chains-and-relays-management/config.sh to see which ports are used.

If there are any errors in the process, you need to eliminate them and continue with the next steps.
You can watch the relay node's log throughout the process. Only by familiarizing yourself with relay node's logs 
can you know the current working status detail of the IBC system.

Test process as bellow:
``` 
# step 1
$ cd ./chains-and-relays-management
$ ./cluster.sh init
Then open four shells and run four groups commands described in file ./chains-and-relays-management/cluster.sh


# step 2 ( in a new shell )
$ cd ./ibc-system-test-process
$ . chains_init.sh

# step 3 ( in a new shell or the same shell with step 2 )
$ cd ./ibc-system-test-process
$ . task_ibc_init.sh
$ . task_ibc_test.sh
# Then, you can try to run all kinds of cross-chain transactions, such as:
$ transfer
```
