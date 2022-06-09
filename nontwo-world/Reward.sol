// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract Reward {

    //current time
    uint public time_now;

    //a map to store info if the user has been rewarded
    mapping(address  => uint) public address_reward_time;

    function getTime() public {
        time_now = block.timestamp;
    }

    //send money to contract
    function add_reward_to_pool() public payable {
        require(msg.value > 10 ether,"The amount sent to the contract each time cannot be less than 10 eth");
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    //need a public account to maintain the balance of contract：API implement


    //params:varified hash,rewards condition,
    function reward(string memory hash, uint condition, address payable user) public {

        //verify hash !!!, now anyone can get reward
        require(bytes(hash).length >0,"invalid stored hash, please check it again");
         
        //get blocktimestamp Uinx
        getTime();
        
        //duplicate reward control
        require(address_reward_time[user]< time_now,"The reward has been issued, please get it again after 24 hours");
        

        //reward conditions !!! now only two conditions
        //condition > 60, transfer 100
        //condition <= 60, transfer 0

        if (condition > 60) {
            require(address(this).balance > 3 ether,
            "The balance of the contract account is insufficient, please recharge");

            // !!! can use a more complex algorithm to calculate reward amout
            //change to target token
            user.transfer(3 ether);
            //set next reward time condition
            address_reward_time[user] = time_now + 3600 *24;
            
        }else {
            require(address(this).balance > 1 ether,
            "The balance of the contract account is insufficient, please recharge");
            //!!! change to target token
            user.transfer(1 ether);
            //set next reward time condition
            address_reward_time[user] = time_now + 3600 *24;
        }         
    }
}
