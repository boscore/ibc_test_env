
ibc.token upgrade from v3 to v4
-------------------------------
all `parallel chain`s and `hub chain` should upgrade their `ibc.token` contract.


### 1. EOSIO mainnet ibc.token upgrade process

#### step 1 : set global and get info

bash variables
```
cleos_eos='cleos -u http://peer1.eoshuobipool.com:8181'
```


ensure all ibc transactions have finished.
```
$cleos_eos get table bosibc.io bos origtrxs
```

set global false
``` 
$cleos_eos push action bosibc.io setglobal '["eos",false]' -p mercuryoooo
```

get table info
```
$cleos_eos get table bosibc.io bosibc.io accepts

{
  "rows": [{
      "original_contract": "eosio.token",
      "peg_token_symbol": "4,EOS",
      "accept": "6462.3427 EOS",
      "max_accept": "1000000000.0000 EOS",
      "min_once_transfer": "0.2000 EOS",
      "max_once_transfer": "1000000.0000 EOS",
      "max_daily_transfer": "10000000.0000 EOS",
      "max_tfs_per_minute": 100,
      "organization": "block one",
      "website": "https://eos.io",
      "administrator": "eostkadmin33",
      "service_fee_mode": "fixed",
      "service_fee_fixed": "0.0100 EOS",
      "service_fee_ratio": "0.00000000000000000",
      "failed_fee": "0.0010 EOS",
      "total_transfer": "8818.6665 EOS",
      "total_transfer_times": 4339,
      "total_cash": "2356.3238 EOS",
      "total_cash_times": 1531,
      "active": 1,
      "mutables": {
        "minute_trx_start": 1582381949,
        "minute_trxs": 1,
        "daily_tf_start": 1582381949,
        "daily_tf_sum": "1.0000 EOS",
        "daily_wd_start": 0,
        "daily_wd_sum": "0 "
      }
    },{
      "original_contract": "eosiotptoken",
      "peg_token_symbol": "4,TPT",
      "accept": "34196.6781 TPT",
      "max_accept": "5900000000.0000 TPT",
      "min_once_transfer": "100.0000 TPT",
      "max_once_transfer": "10000000.0000 TPT",
      "max_daily_transfer": "100000000.0000 TPT",
      "max_tfs_per_minute": 50,
      "organization": "TokenPocket",
      "website": "https://tokenpocket.pro",
      "administrator": "itokenpocket",
      "service_fee_mode": "fixed",
      "service_fee_fixed": "10.0000 TPT",
      "service_fee_ratio": "0.00000000000000000",
      "failed_fee": "1.0000 TPT",
      "total_transfer": "42918.0000 TPT",
      "total_transfer_times": 39,
      "total_cash": "8721.3219 TPT",
      "total_cash_times": 9,
      "active": 1,
      "mutables": {
        "minute_trx_start": 1585889295,
        "minute_trxs": 1,
        "daily_tf_start": 1585889295,
        "daily_tf_sum": "100.0000 TPT",
        "daily_wd_start": 0,
        "daily_wd_sum": "0 "
      }
    },{
      "original_contract": "tethertether",
      "peg_token_symbol": "4,USDT",
      "accept": "6.0354 USDT",
      "max_accept": "1000000000000.0000 USDT",
      "min_once_transfer": "0.1000 USDT",
      "max_once_transfer": "100000.0000 USDT",
      "max_daily_transfer": "10000000.0000 USDT",
      "max_tfs_per_minute": 200,
      "organization": "bitfinex",
      "website": "https://www.eosfinex.com",
      "administrator": "eostkadmin33",
      "service_fee_mode": "fixed",
      "service_fee_fixed": "0.0100 USDT",
      "service_fee_ratio": "0.00000000000000000",
      "failed_fee": "0.0050 USDT",
      "total_transfer": "9.6633 USDT",
      "total_transfer_times": 9,
      "total_cash": "3.6279 USDT",
      "total_cash_times": 2,
      "active": 1,
      "mutables": {
        "minute_trx_start": 1574636436,
        "minute_trxs": 1,
        "daily_tf_start": 1574636436,
        "daily_tf_sum": "1.0000 USDT",
        "daily_wd_start": 0,
        "daily_wd_sum": "0 "
      }
    }
  ],
  "more": false,
  "next_key": ""
}
```



$cleos_eos get table bosibc.io bosibc.io stats
``` 

{
  "rows": [{
      "supply": "0.0000 UB",
      "max_supply": "10000000000.0000 UB",
      "min_once_withdraw": "1.0000 UB",
      "max_once_withdraw": "50000.0000 UB",
      "max_daily_withdraw": "500000.0000 UB",
      "max_wds_per_minute": 50,
      "administrator": "ubibcmanager",
      "peerchain_name": "bos",
      "peerchain_contract": "unicorntoken",
      "orig_token_symbol": "4,UB",
      "failed_fee": "0.1000 UB",
      "total_issue": "1.0000 UB",
      "total_issue_times": 1,
      "total_withdraw": "1.0000 UB",
      "total_withdraw_times": 1,
      "active": 1,
      "mutables": {
        "minute_trx_start": 1567673870,
        "minute_trxs": 1,
        "daily_isu_start": 0,
        "daily_isu_sum": "0 ",
        "daily_wd_start": 1567673870,
        "daily_wd_sum": "1.0000 UB"
      }
    },{
      "supply": "130817.4718 BOS",
      "max_supply": "1000000000.0000 BOS",
      "min_once_withdraw": "0.2000 BOS",
      "max_once_withdraw": "1000000.0000 BOS",
      "max_daily_withdraw": "10000000.0000 BOS",
      "max_wds_per_minute": 100,
      "administrator": "bostkadmin33",
      "peerchain_name": "bos",
      "peerchain_contract": "eosio.token",
      "orig_token_symbol": "4,BOS",
      "failed_fee": "0.0010 BOS",
      "total_issue": "253534.8747 BOS",
      "total_issue_times": 9355,
      "total_withdraw": "122717.4029 BOS",
      "total_withdraw_times": 4489,
      "active": 1,
      "mutables": {
        "minute_trx_start": 1586242619,
        "minute_trxs": 1,
        "daily_isu_start": 0,
        "daily_isu_sum": "0 ",
        "daily_wd_start": 1586182509,
        "daily_wd_sum": "1.2000 BOS"
      }
    }
  ],
  "more": false,
  "next_key": ""
}
```

#### step 2 : deploy special ibc.token contracts and clear tables
check out branch `upgrade_v3_to_v4` of [ibc_contracts](https://github.com/boscore/ibc_contracts) project 
or use pre-build contact on [bos.contract-prebuild/bosibc/upgrade_v3_to_v4](https://github.com/boscore/bos.contract-prebuild/tree/master/bosibc/upgrade_v3_to_v4/ibc.token).
``` 
ibc_contracts_dir='...'
$cleos_eos set contract bosibc.io ${ibc_contracts_dir}/ibc.token -x 1000 -p bosibc.io
$cleos_eos push action bosibc.io deltokentbl '[]' -p bosibc.io
```

check if tables has cleared
``` 
$cleos_eos get table bosibc.io bosibc.io accepts
$cleos_eos get table bosibc.io bosibc.io stats
```

#### step 3 : deploy another special ibc.token contract and set tables
check out branch `upgrade_v3_to_v4_step2` of [ibc_contracts](https://github.com/boscore/ibc_contracts) project 
or use pre-build contact on [bos.contract-prebuild/bosibc/upgrade_v3_to_v4_step2](https://github.com/boscore/bos.contract-prebuild/tree/master/bosibc/upgrade_v3_to_v4_step2/ibc.token).
``` 
ibc_contracts_dir='...'
$cleos_eos set contract bosibc.io ${ibc_contracts_dir}/ibc.token -x 1000 -p bosibc.io
$cleos_eos push action bosibc.io addacpttoken \
     '["eosio.token","1000000000.0000 EOS","0.2000 EOS","1000000.0000 EOS",
     "10000000.0000 EOS",100,"block one","https://eos.io","eostkadmin33","fixed","0.0100 EOS",0.0,"0.0100 EOS",true,"6462.3427 EOS","8818.6665 EOS","2356.3238 EOS"]' -p bosibc.io

$cleos_eos push action bosibc.io addacpttoken \
     '["eosiotptoken","5900000000.0000 TPT","100.0000 TPT","10000000.0000 TPT",
     "100000000.0000 TPT",50,"TokenPocket","https://tokenpocket.pro","itokenpocket","fixed","10.0000 TPT",0.0,"1.0000 TPT",true,"34196.6781 TPT","42918.0000 TPT","8721.3219 TPT"]' -p bosibc.io

$cleos_eos push action bosibc.io addacpttoken \
     '["tethertether","1000000000000.0000 USDT","0.1000 USDT","100000.0000 USDT",
     "10000000.0000 USDT",200,"bitfinex","https://www.eosfinex.com","eostkadmin33","fixed","0.0100 USDT",0.0,"0.0050 USDT",true,"6.0354 USDT","9.6633 USDT","3.6279 USDT"]' -p bosibc.io


$cleos_eos push action bosibc.io addpegtoken \
        '["bos","eosio.token","1000000000.0000 BOS","0.2000 BOS","1000000.0000 BOS",
        "10000000.0000 BOS",100,"bostkadmin33","0.0010 BOS",true,"130817.4718 BOS","253534.8747 BOS","122717.4029 BOS"]' -p bosibc.io

$cleos_eos push action bosibc.io addpegtoken \
        '["bos","unicorntoken","10000000000.0000 UB","1.0000 UB","50000.0000 UB",
        "500000.0000 UB",50,"ubibcmanager","0.1000 UB",true,"0.0000 UB","1.0000 UB","1.0000 UB"]' -p bosibc.io

```

check if tables had added
``` 
$cleos_eos get table bosibc.io bosibc.io accepts
$cleos_eos get table bosibc.io bosibc.io stats
```

#### step 4 : deploy v4 ibc.token contract
check out branch `master` of [ibc_contracts](https://github.com/boscore/ibc_contracts) project 
or use pre-build contact on [bos.contract-prebuild/bosibc](https://github.com/boscore/bos.contract-prebuild/tree/master/bosibc).

```
ibc_contracts_dir='...'
$cleos_eos set contract bosibc.io ${ibc_contracts_dir}/ibc.token -x 1000 -p bosibc.io
```


















