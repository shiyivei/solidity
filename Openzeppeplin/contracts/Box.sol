// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./access-control/Auth.sol";

contract Box {

     //定义状态变量
     uint256 private value;

     //1 引入导入的合约，把引入的合约当做一个类型使用 
     Auth private auth;


     //定义状态变量更改后要发出的事件
     event ValueChanged(uint256 newValue);

     //2 给合约变量赋值
     constructor(Auth _auth) {
          auth = _auth;
     } 

     //更改状态变量
     function store(uint256 newValue) public {

          //3 调用第一个合约中的函数，如果结果为假，则返回错误
          require(auth.isAdministrator(msg.sender) ,"Unauthorized");

          value = newValue;
          emit ValueChanged(value);
     }

     //查看改变后的值
     function retrieve()public view returns (uint256){
          return value;
     } 
}