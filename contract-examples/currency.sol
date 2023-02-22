// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Coin {
    
    address public miner;
    mapping (address=>uint) public balances;

    constructor() {
        miner = msg.sender;
    }

    event MintSuccess(address,uint);
    error Insufficient(address,uint);


    function mint(uint amount) public {

        balances[miner] += amount;
        emit MintSuccess(miner,amount);
        
    }

    function transfer(address to,uint amount) public {

        require(balances[miner] > amount,"insufficient balance");

        balances[miner] -= amount;
        balances[to] += amount;

    }

    function get_balance() public view returns (uint) {
        return balances[miner];
    }

}