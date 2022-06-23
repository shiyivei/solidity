// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Auth {

     //定义状态变量
     address private administrator;

     //使用构造函数,初始化时合约拥有者就是发送交易的人
     constructor() {
          administrator = msg.sender;
     }

     //判断是不是合约拥有者
     function isAdministrator(address user) public view returns (bool) {
          return user == administrator;
     }
     
}