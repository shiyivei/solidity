// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0; 

contract BlindAuction {

    // 使用新的数据结构代表出价
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    // 拍卖受益人
    address payable  public beneficiary;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    // 竞价记录表
    mapping(address => Bid[]) public bids;

    // 最高出价者
    address public highestBidder;
    // 最高出价
    uint public highestBid;

    // 应该退回的钱
    mapping (address => uint) pendingReturns;

    event AuctionEnded(address winner,uint highestBid);

    error TooEarly(uint time);
    error TooLate(uint time);

    error AuctionEndedAlreadyCalled();

    // 修改两个条件
    modifier onlyBefore(uint time) {
        if (block.timestamp >= time) revert TooLate(time);
        _;
    }

    // 作为参数限制
    modifier onlyAfter(uint time) {
        if (block.timestamp <= time) revert TooEarly(time);
        _; 
    }

    // 构造函数，初始化变量
    constructor (uint endTime,uint revealTime,address payable beneficiaryAddress) {
        beneficiary = beneficiaryAddress;

        biddingEnd = block.timestamp + endTime;
        revealEnd = biddingEnd + revealTime;

    }

    // 竞价，数组加入数据使用push,竞价的时候传入了数据同时发送了金额，竞价没有任何限制，但是本轮系统实际上是有时间的
    // 这里的参数 blindedBid 实际上是 keccak256(value, fake, secret) 之后的哈希(keccak256(abi.encodePacked(value,fake,secret))
    // value > 当前最高价格 && fake 为真，出价成功
    function bid(bytes32 blindedBid) external payable onlyBefore(biddingEnd) {

        // 把数据装入数组保存
        bids[msg.sender].push(Bid({blindedBid:blindedBid,
        deposit: msg.value}));
    }

    // 披露竞价,使用之前竞价的参数数组
    // 这些参数放在合约外存储 或者其他合约存储
    function reveal(uint[] calldata values,bool[] calldata fakes,bytes32[] calldata secrets) external  onlyAfter(biddingEnd)
        onlyBefore(revealEnd){

            // 验证参数数组是否等长
            uint length = bids[msg.sender].length;

            require(values.length == length);
            require(fakes.length == length);
            require(secrets.length == length);

            uint refund;

            // 获取每次出价信息参数
            for (uint i =0; i < length; i++ ) {
                Bid storage b = bids[msg.sender][i];
               
                (uint value,bool fake,bytes32 secret) = (values[i],fakes[i],secrets[i]);

                // 检验参数
                if (b.blindedBid != keccak256(abi.encodePacked(value,fake,secret))) {
                    continue;
                }
                // 退款金额
                refund += b.deposit;

                // 检查是否是有效出价
                if (!fake && b.deposit >= value) {
                    if (placeBid(msg.sender,value))
                    refund -= value;
                }

                b.blindedBid = bytes32(0);
            }

            payable(msg.sender).transfer(refund);
    }

    function placeBid(address bidder,uint value) internal returns (bool success) {
        if (value <= highestBid) {
            return false;
        }

        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = value;
        highestBidder = bidder;
        return true;

    }

    function withDraw() external {
        uint amount = pendingReturns[msg.sender];

        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            payable(msg.sender).transfer(amount);
        }
    }

    function auctionEnd() external onlyAfter(revealEnd) {
        if (ended) revert AuctionEndedAlreadyCalled();

        emit AuctionEnded(highestBidder, highestBid);
        ended = true;

        beneficiary.transfer(highestBid);
    }

}