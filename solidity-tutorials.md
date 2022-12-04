# 1 初始环境配置

在本地创建文件夹，并通过命令remixd启动

在remix中与本地连接

# 2 智能合约介绍

## 2.1 基本合约

第一行：机器许可说明：GPL-3.0 版本授权

第二行：编译器版本

Solidity 合约是功能和状态的集合，并且位于某个特定地址上

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint) {
        return storedData;
    }
}
```

状态变量可以类比为数据库中的数据，我们需要自定义一些方法，如上面的set和get来更改或者查询数据

**注意：合约中的任何表示符都只能使用ASCII字符集，UTF-8编码的数据可以用字符串变量的形式存储**

## 2.2 合约元素

### 2.2.1 关键字及可见性

**关键字类型**

如果某个函数的不需要更改状态，那写view就好

``` 
address // 一个160位的值，160bit = 20字节 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
mapping (key=>value) 
function name(paramtype param) returns (address) 有返回值时使用returns，内部使用return
uint 256位 无符号整数
require  require(msg.sender == minter,"这里写失败的备注");
bytes32 //最长32字节
Proposal[] 数组
uint[] memory tempWinner = new uint[](proposals.length); 实例化一个数组


// 定义投票者实体，结构体
    struct Voter {
        uint weight; // 投票权重
        bool voted; // 是否已经投过
        address delegate; // 委托人地址
        uint vote; // 累计票数
    }

// 结构体相当于自定义的类型，可以在函数中实例化，使用storage，每个账户的持久化存储

 Voter storage sender = voters[msg.sender];
 
 address(0) 代表0地址或者空地址，就是无效地址的意思
```

**变量/函数可见性**

```
public 外部可见（函数和变量的可见性），任何合约和用户都可以调用
external 外部可见，只能被用户和外部合约调用
private 修饰只能在其所在的合约中调用和访问，即使是其子合约也没有权限访问
internal 子合约和所在合约都可以调用
```

### 2.2.2 事件

**事件定义和发出**

```
event Sent(address from, address to, uint amount); 事件名称第一个字母大写，事件（）中说明参数和参数类型

emit Sent(msg.sender, receiver, amount); //使用emit 发出
```

**事件监听**

使用web3.js监听

```
Coin.Sent().watch({}, '', function(error, result) {
    if (!error) {
        console.log("Coin transfer: " + result.args.amount +
            " coins were sent from " + result.args.from +
            " to " + result.args.to + ".");
        console.log("Balances now:\n" +
            "Sender: " + Coin.balances.call(result.args.from) +
            "Receiver: " + Coin.balances.call(result.args.to));
    }
})
```

### 2.2.3 错误

```
error InsufficientBalance(uint requested, uint available); // 定义规则同事件
revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            }); // 使用revert 发出，一般用在if判断语句中
```

### 2.2.4 构造函数

一般就是把合约调用者指定为某个角色,或者初始化一些其他变量

```
constructor() {
        minter = msg.sender;
    }
```

### 2.2.5 运算

```
加减
```

### 2.2.6 数据位置(Data location)

复杂类型，如`数组(arrays)`和`数据结构(struct)`在Solidity中有一个额外的属性，数据的存储位置。可选为`memory`和`storage`

`memory`存储位置同我们普通程序的内存一致。即分配，即使用，越过作用域即不可被访问，等待被回收

`storage`将会永久记录数据

`calldata`存储的是函数参数，是只读的，不会永久存储的一个数据位置.

`外部函数`的参数（不包括返回参数）被强制指定为`calldata`。效果与`memory`差不多。

**案例阅读**

```text
pragma solidity ^0.4.0;

contract C {
    uint[] x; // the data location of x is storage

    // the data location of memoryArray is memory
    function f(uint[] memoryArray) {
        x = memoryArray; // works, copies the whole array to storage
        var y = x; // works, assigns a pointer, data location of y is storage
        y[7]; // fine, returns the 8th element
        y.length = 2; // fine, modifies x through y
        delete x; // fine, clears the array, also modifies y
        // The following does not work; it would need to create a new temporary /
        // unnamed array in storage, but storage is "statically" allocated:
        // y = memoryArray;
        // This does not work either, since it would "reset" the pointer, but there
        // is no sensible location it could point to.
        // delete y;
        g(x); // calls g, handing over a reference to x
        h(x); // calls h and creates an independent, temporary copy in memory
    }

    function g(uint[] storage storageArray) internal {}
    function h(uint[] memoryArray) {}
}
```

**强制的数据位置(Forced data location)**

- `外部函数(External function)`的参数(不包括返回参数)强制为：`calldata`
- `状态变量(State variables)`强制为: `storage`

**默认数据位置（Default data location）**

- 函数参数（括返回参数：`memory`
- 所有其它的局部变量：`storage`

更多请查看关于数据位置的进一步挖掘： http://me.tryblockchain.org/solidity-data-location.html

返沪数组可以通过重新新建的方式返回，memory

```
uint[] memory winningProposals = new uint[](winnerCount);
```

### 2.2.7 modifier

modifier可以改变函数的行为。可以被继承和重写。但是用的最多的还是变量检查

```
modifier onlyAfter(uint time) {
        if (block.timestamp <= time) revert TooEarly(time);
        _;
    }
```

检查完之后可以用在后续的函数签名中

## 2.3 操作

```
== 赋值
四则运算
```

一般情况下，特定的数据只会存储在某个特定合约的数据结构中

## 2.4 区块链基础

以太坊的区块打包时间是17s

外部账户由公钥得到，合约账户由创建者的地址和从该地址发出过的交易数量计算得到，即所谓的nonce

每个账户都有一个键值对形式的持久化存储，合约也是，key和value长度皆为256位，还会有个以太币余额，单位是wei 1eth = 10的18次方

**存储，内存和栈**

以太坊虚拟机有 3 个区域用来存储数据： 存储（storage）, 内存（memory） 和 栈（stack）

**合约中无法枚举存储**

但是可以有枚举

每次调用合约都会擦干净内存实例，线性按字节寻址，读为256位，写为8位或256位

EVM基于栈，栈最大1024个元素，每个元素256位。允许拷贝最顶端16个之一到栈顶，其他操作允许从顶取一到多个，结果压入栈顶或者放到存储或者内存中

**指令集**

算术、逻辑、位比较，有无条件跳转，访问区块属性，原则，尽可能不要导致共识问题

**委托调用/代码调用和库**

可以将实现复杂的数据结构库，代码虽然写在不同的文件中，但是可以重载

**合约的失效和自毁**

使用selfdestruct，delegatecall，callcode，也可以通过修改合约内部状态，让所有函数无法执行

# 3 通过例子学习Solidity

## 3.1 投票合约

bytes32转换问题，使用web3.js 或者https://tool.lu/hexstr/这里去转换，要63位

合约在部署构建的时候也可能需要提供一些参数用来初始化一些变量

```
["0x6d696f610a0a0000000000000000000000000000000000000000000000000000","0x6d696f610b0a0000000000000000000000000000000000000000000000000000","0x6d696f610c0a0000000000000000000000000000000000000000000000000000"]
```

```
["0x6d696f610b0a0000000000000000000000000000000000000000000000000000"]
```

```
["0x6d696f610c0a0000000000000000000000000000000000000000000000000000"]
```

## 3.2 盲拍合约

payable 关键字允许函数将信息和以太币一起发出去

**合约地址转账；**addr.transfer(1 ether)、addr.send(1 ether)、addr.call.value(1 ether)的接收方都是addr。

## 3.3 盲拍合约进阶

## 3.4 远程购买合约

关于枚举传递状态的使用，具体见合约代码

