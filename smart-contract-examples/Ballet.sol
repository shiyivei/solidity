// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Ballet {

    //第一步，定义状态变量,投票人实体
    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    //被投的对象
    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    //定义一个管理员
    address public chairperson;

    //将地址和投票者对应起来
    mapping(address => Voter) public voters;
    
    //定义一个数组用来装投票对象
    Proposal[] public proposals;

    //第二步，定义构造函数,初始化变量
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender; //合约创建者
        voters[chairperson].weight = 1;//给一个权重

        //把提议装入数组中
        for (uint i = 1; i < proposalNames.length; i ++ ) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount:0
            }));
        }  
    } 


    //第三步，定义逻辑函数
    function giveRightToVote(address voter) external {
        require (
            msg.sender == chairperson,"Only chairperson can give right to vote."
        );
        require (!voters[voter].voted,"the voter already voted");

        require (voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    function delegate(address to) external {
        //传引用
        Voter storage sender = voters[msg.sender];

        require(!sender.voted,"you have aready voted");

        require(to != msg.sender,"self-delegation is disallowed");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate; //奇怪，不应该是把前者赋值给后者吗
            require(to != msg.sender,"Found loop indelegation");
        }

        Voter storage delegate_ = voters[to];

        require(delegate_.weight>=1);
        //这两个是对的
        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        }else {
            delegate_.weight += sender.weight;
        }
    }

    function winningProposal() external view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++ ) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() public view returns (bytes32 winnerName_) {

        winnerName_ = proposals[winningProposal()].name;

    }

    //第四步，定义错误
    //第五步，定义event

:

