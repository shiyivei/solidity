// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0; 

contract SafePurchase {

    // 商品价格 * 2
    uint public value;
    address payable public seller;
    address payable public buyer;

    // 订单状态
    enum State { Created, Locked, Release, Inactive }
    State public state;


    modifier condition(bool condition_) {
        require(condition_);
        _;
    }

    error Onlybuyer();
    error OnlySeller();
    error InvalidState();
    error ValueNotEven();

    modifier onlyBuyer() {
        require(msg.sender == buyer,"Only buyer can call this");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller,"Only seller can call this");
        _;
    }

    modifier inState(State _state) {

        require(
            state == _state,"Invalid state"
        );
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();


    // 卖方发起订单并支付2倍的金额
    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        if ((2 * value) != msg.value) revert ValueNotEven();

    }


    // 商家终止订单，中智订单后这个钱会退给买家
    function abort() external onlySeller inState(State.Created) {

        emit Aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);

    }

    // 买方确认购买
    function confirmPurchase() external inState(State.Created) condition(msg.value == (2*value)) payable {
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    // 收货
    function confirmReceived() external onlyBuyer inState(State.Locked){
        // 退回钱的一半
        emit ItemReceived();
        state = State.Release;
        buyer.transfer(value);

    }

    // 卖家收款
    function refundSeller() external onlySeller inState(State.Release) {
        emit SellerRefunded();

        state = State.Inactive;
        seller.transfer(3* value);

    }


}
