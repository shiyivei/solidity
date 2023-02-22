// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract Ballot {

    // 定义投票者实体
    struct Voter {
        uint weight; // 投票权重
        bool voted; // 是否已经投过
        address delegate; // 委托人地址
        uint vote; // 累计票数
    }

    // 定义提议实体
    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    // 主席
    address public chairperson;

    // 投票者 地址到投票人本身的map
    mapping(address=>Voter) public voters;

    // 提议数组，里面装满了提议
    Proposal[] public proposals;

    // 构造函数，初始化变量，构造函数需要参数
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;

        voters[chairperson].weight = 1;

        for(uint i = 0;i < proposalNames.length;i++) {
            proposals.push(Proposal({
                name:proposalNames[i],
                voteCount:0
            }));
        }

    }



    function giveRightToVote(address voter) external {

        require(msg.sender == chairperson,"Only chairperson can give right to vote");

        require(!voters[voter].voted,"The voter has already voted.");

        require(voters[voter].weight == 0);

        voters[voter].weight = 1;
        
    }

    // 委托投票，这在现实中是一个非常常见的场景
    function delegate(address to) external {

        // 获取函数的调用者
        Voter storage sender = voters[msg.sender];
        // 判断权重
        require(sender.weight != 0,"You have no right to vote");
        // 判断是否可以投票
        require(!sender.voted,"You already voted");
        // 判断是不是自我委托
        require(to != msg.sender,"Self-delegation is disallowed");

        // 判断被委托者不是第一个投票者，防止造成循环委托
        // 如果这个地址所对应的委托人为零，或者说没有委托给别人
        while (voters[to].delegate != address(0)) {
            // 那自我委托
            to = voters[to].delegate;
            // 并且要求不可以循环委托
            require(to != msg.sender,"Found loop in delegation");
        }

        // 把这个地址实例化为voter
        Voter storage delegate_ = voters[to];

        // weight 代表用户可以投几票，weight为0时，不可以投票
        require(delegate_.weight >= 1);

        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        }else {
            delegate_.weight += sender.weight;
        }

    }

    // 投票函数，
    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted,"Already voted");
        // 限制只有被授权的人才能投票
        require(sender.weight >= 1,"You have no right to vote");

        require(proposal < proposals.length);

        sender.voted = true;
        sender.vote = proposal;
        
        proposals[proposal].voteCount += sender.weight;

    }

    function winProposals() public view returns (uint[] memory ) {

        // 定义一个数组
        uint[] memory tempWinner = new uint[](proposals.length);
        

        uint winnerCount = 0;
        uint winnerVoteCounts = 0;

        for (uint p = 0; p < proposals.length;p++) {
            if (proposals[p].voteCount > winnerVoteCounts) {
                winnerVoteCounts = proposals[p].voteCount;
                
                //把临时获胜者放入数组的第一个位置
                tempWinner[0] = p;
                //记获胜者数量为1
                winnerCount = 1;

            }else if (proposals[p].voteCount == winnerVoteCounts) {
                //将第二获胜者指定为数组的第二个元素
                tempWinner[winnerCount] = p;
                //获胜者计数+1
                winnerCount ++;
            }
        }

        uint[] memory winningProposals = new uint[](winnerCount);
        
        //将所有票数最高的提案编号存储到winningProposals
        for (uint q = 0; q < winnerCount; q++){
            winningProposals[q] = tempWinner[q];
        }
        
        return winningProposals;

    }

    function winnerName() public view returns (bytes32 winnerName_) {

        winnerName_ = proposals[winProposals()[0]].name;
    }

    function getWinnerCounts() public view returns (uint voteCounts_) {
        voteCounts_ = proposals[winProposals()[0]].voteCount;
        
    }
}