// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract SimpleAuction {
    

    address payable public beneficiary;

    // 拍卖结束时间
    uint public auctionEndTime;

    // 最高出价者
    address public highestBidder;
    // 最高价
    uint public highestbid;

    // 退款人及退款金额
    mapping(address=>uint) pendingReturns;

    // 拍卖状态
    bool ended;

    event HighestBidIncreased(address bidder,uint amount);
    event AuctionEnded(address winner,uint amount);

    error AuctionAlreadyEnded();
    error BidNotHeighEnough(uint highestbid);
    error AuctionNotYetEnded();
    error AuctionEndAlreadyCalled();

    // 创建合约时要指定拍卖时长
    constructor(
        uint biddingTime,
        address payable beneficiaryAddress
    ) {
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
    }

    // 竞价
    function bid() external payable {
        // 判断拍卖是否结束
        if (block.timestamp > auctionEndTime) {
            revert AuctionAlreadyEnded();
        }

        // 判断出价是否有效（高于最高价）
        if (msg.value <= highestbid) {
            revert BidNotHeighEnough(msg.value);
        }

        // 记录返回值
        if (highestbid != 0) {
            pendingReturns[highestBidder] += highestbid;
        }

        // 更新最高价出价者
        highestBidder = msg.sender;
        // 更新最高价
        highestbid = msg.value;

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    // 取回出价
    function withDraw() external returns(bool) {

        // 获取应该给调用者返回的金额，临时存储
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // 先重置返回金额为0
            pendingReturns[msg.sender] = 0;
            // 使用payable（address）将地址转为可以接受以太币，同时调用send函数，如果失败则重新修改回撤金额
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }

        return true;
    }

    function auctionEnd() external {
        // 如果还在时间内，则返回拍卖时间未结束
        if (block.timestamp < auctionEndTime) {
           revert AuctionNotYetEnded();
        }

        // 查状态，只能调用一次
        if (ended) {
            revert AuctionEndAlreadyCalled();
        }

        // 修改状状态
        ended = true;
        emit AuctionEnded(highestBidder, highestbid);

        // 把钱转给受益人，受益人把货物交给受益者
        beneficiary.transfer(highestbid);
    }

    



}