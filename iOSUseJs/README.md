## 波场JS工具ForiOS-接口说明

### 接口返回值格式

success: 0-失败, 1-成功 

body: 失败原因或者函数的执行结果

格式如下:

```
{
    body = ...;
    success = 1;
}
```


### tronTool.version

- JS修订版本

```
无参
返回值
{
    body = v10;
    success = 1;
}
```

### tronTool.addressToTron
- 以太坊地址转换成波场地址

```
addressToTron(ethAddress)
p1: 以太坊地址

返回值
{
    body = TTaJsdnYPsBjLLM1u2qMw1e9fLLoVKnNUX;
    success = 1;
}
```

### tronTool.addressToEth
- 波场地址转换成以太坊地址

```
addressToEth(tronAddress)
p1: 波场地址

返回值
{
    body = 0xc11d9943805e56b630a401d4bd9a29550353efa1;
    success = 1;
}
```

### tronTool.getTokenInfo
- 获取erc20 token的基本信息: name, symbol, decimals

```
getTokenInfo(contractAddress)
p1: erc20 token地址

返回值
{
    body =     {
        decimals = 6;
        name = DX;
        symbol = DX;
    };
    success = 1;
}
```

### tronTool.getERC20Name
- 获取erc20 token的基本信息: name

```
getERC20Name(contractAddress)
p1: erc20 token地址

返回值
{
    body = DX;
    success = 1;
}
```

### tronTool.getERC20Symbol
- 获取erc20 token的基本信息: symbol

```
getERC20Symbol(contractAddress)
p1: erc20 token地址

返回值
{
    body = DX;
    success = 1;
}
```

### tronTool.getERC20Decimals
- 获取erc20 token的基本信息: decimals

```
getERC20Decimals(contractAddress)
p1: erc20 token地址

返回值
{
    body = 6;
    success = 1;
}
```

### tronTool.getERC20Balance
- 获取用户地址的erc20 token的余额

```
getERC20Balance(address, contractAddress)
p1: 用户地址
p2: erc20 token地址

返回值
{
    body = 26820689992;
    success = 1;
}
```

### tronTool.getBalance
- 获取用户地址的TRX的余额

```
getBalance(address)
p1: 用户地址

返回值
{
    body = 824802403;
    success = 1;
}
```

### tronTool.getBalances（批量获取用户的余额）
- 获取用户的一批erc20 token的余额，当指定的token地址是`T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb`时，则查询用户的TRX余额
- 返回值是数组，按照传入的token顺序依次返回用户余额


```
getBalances(multiCallAddress, user, tokens)
p1: 主网填 TCNYd8L5hBey9FwPpvgtvDaY2cHjMFVLZu, 测试网填 TCmNMtJQiPpSKiGuXUj4vcJAGKqJstmsBD
p2: 用户地址
p3: token地址列表，格式为 ['T...','T...','T...','T...']

返回值
{
    body =     (
        824802403,
        552820000,
        26820689992,
        6599000000
    );
    success = 1;
}
```

### tronTool.sendTrx
- 用户TRX资产转账
- 返回交易hash

```
sendTrx(privateKey, to, value)
p1: 发送用户私钥
p2: 接收用户地址
p3: 转账金额，转换为去精度数字

返回值
{
    body = eff3b03b7b9911c6a55091ba3d0709f02752e51d454a9442f8e9a9bef2e224f8;
    success = 1;
}
```

### tronTool.sendERC20Token
- 用户erc20 token资产转账
- 返回交易hash

```
sendERC20Token(privateKey, to, value, contractAddress, feeLimit)
p1: 发送用户私钥
p2: 接收用户地址
p3: 转账金额，转换为去精度数字
p4: erc20 token地址
p5: 手续费消耗上限（选填）

返回值
{
    body = d9381a2c75c81487d2a2ef60485ec7d58f42970bf2d3be1da5efb84dadf8bf33;
    success = 1;
}
```

### tronTool.estimateEnergyUsed
- 估算合约调用的能量消耗

```
estimateEnergyUsed(sender, contractAddress, functionDes, value, args)
p1: 发起者地址
p2: 合约地址
p3: 合约函数，格式为函数名(参数类型...)，eg. transfer(address,uint256)
p4: 发起者向合约转入的TRX数量，去精度数字
p5: 调用的合约函数的参数，格式为数组，eg. ['TFzEXjcejyAdfLSEANordcppsxeGW9jEm2', '220000']

返回值
{
    body = 13061;
    success = 1;
}
```

### tronTool.getGasLimitWithNetwork_sendTrx
- 估算TRX转账的手续费trx消耗

```
getGasLimitWithNetwork_sendTrx(from, to, value)
p1: 发送用户地址
p2: 接收用户地址
p3: 转账金额，转换为去精度数字

返回值
{
    body = 2000000;
    success = 1;
}
```

### tronTool.getGasLimit_sendERC20
- 估算erc20 token转账的手续费trx消耗

```
getGasLimit_sendERC20(from, to, value, contractAddress)
p1: 发送用户地址
p2: 接收用户地址
p3: 转账金额，转换为去精度数字
p4: erc20 token地址 

返回值
{
    body = 3657080;
    success = 1;
}
```

### tronTool.getTransaction
- 根据hash查询交易数据

```
getTransaction(hash)
P1: 交易hash

返回值
{
    body =     {
        "raw_data" =         {
            contract =             (
                                {
                    parameter =                     {
                        "type_url" = "type.googleapis.com/protocol.TransferContract";
                        value =                         {
                            amount = 100000;
                            "owner_address" = 41c11d9943805e56b630a401d4bd9a29550353efa1;
                            "to_address" = 4143a0eca8a75c86f30045a434114d750eb1b4b6e0;
                        };
                    };
                    type = TransferContract;
                }
            );
            expiration = 1651802331000;
            "ref_block_bytes" = 77c6;
            "ref_block_hash" = 8be0eb20a51d5085;
            timestamp = 1651802274194;
        };
        "raw_data_hex" = 0a0277c622088be0eb20a51d508540f8aeddb889305a67080112630a2d747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e73666572436f6e747261637412320a1541c11d9943805e56b630a401d4bd9a29550353efa112154143a0eca8a75c86f30045a434114d750eb1b4b6e018a08d067092f3d9b88930;
        ret =         (
                        {
                contractRet = SUCCESS;
            }
        );
        signature =         (
            44268aba062076a6936dd341808c73c4cab257bb8e7c1a31b3eed3646d8d8bf6cb52ff3f87033a89b4bffc2d81f2efdcd9cab129235661d0483a556d3305809200
        );
        txID = ea84b77dcceb74c8516089c7ddde23b502225f4438d66a0a7591b5de37d65add;
    };
    success = 1;
}
```

### tronTool.getTransactionInfo
- 根据hash查询交易执行数据

```
getTransactionInfo(hash)
P1: 交易hash

返回值
{
    body =     {
        blockNumber = 24213466;
        blockTimeStamp = 1651802277000;
        contractResult =         (
            ""
        );
        id = ea84b77dcceb74c8516089c7ddde23b502225f4438d66a0a7591b5de37d65add;
        receipt =         {
            "net_usage" = 267;
        };
    };
    success = 1;
}
```

### tronTool.sign
- 交易签名或者字符串签名

```
sign(message, privateKey)
p1: 需签名的字符串
p2: 用户私钥

返回值
{
    body = 0xef7af408a9b43f21b595245cfcddeb04e1c6cff41399a5e957c7105199cf430c460b5686f9e6243b43a41fa8bbb74c4f86aa950e7dfa127dee37c41202d7f6871b;
    success = 1;
}
```
