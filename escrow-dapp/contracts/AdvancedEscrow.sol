// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AdvancedEscrow {
    enum DealStatus { INITIATED, FUNDED, DELIVERED, DISPUTED, RELEASED, REFUNDED, CANCELLED }

    struct Deal {
        address buyer;
        address seller;
        address arbiter;
        uint256 amount;
        uint256 deadline;
        DealStatus status;
        uint256 createdAt;
    }

    uint256 public platformFeePercent = 2;
    address public platformOwner;
    uint256 public dealCounter;
    mapping(uint256 => Deal) public deals;

    event DealCreated(uint256 indexed dealId, address buyer, address seller, uint256 amount);
    event DealFunded(uint256 indexed dealId, uint256 amount);
    event DealDelivered(uint256 indexed dealId);
    event DealReleased(uint256 indexed dealId);
    event DealRefunded(uint256 indexed dealId);
    event DealDisputed(uint256 indexed dealId);
    event DealCancelled(uint256 indexed dealId);

    modifier onlyBuyer(uint256 _dealId) {
        require(msg.sender == deals[_dealId].buyer, "Only buyer");
        _;
    }

    modifier onlySeller(uint256 _dealId) {
        require(msg.sender == deals[_dealId].seller, "Only seller");
        _;
    }

    modifier onlyArbiter(uint256 _dealId) {
        require(msg.sender == deals[_dealId].arbiter, "Only arbiter");
        _;
    }

    modifier inStatus(uint256 _dealId, DealStatus _status) {
        require(deals[_dealId].status == _status, "Invalid status");
        _;
    }

    constructor() {
        platformOwner = msg.sender;
    }

    function createDeal(address _seller, address _arbiter, uint256 _deadlineInSeconds) external returns (uint256) {
        require(_seller != address(0) && _arbiter != address(0), "Invalid addresses");

        dealCounter++;
        deals[dealCounter] = Deal({
            buyer: msg.sender,
            seller: _seller,
            arbiter: _arbiter,
            amount: 0,
            deadline: block.timestamp + _deadlineInSeconds,
            status: DealStatus.INITIATED,
            createdAt: block.timestamp
        });

        emit DealCreated(dealCounter, msg.sender, _seller, 0);
        return dealCounter;
    }

    function fundDeal(uint256 _dealId) external payable onlyBuyer(_dealId) inStatus(_dealId, DealStatus.INITIATED) {
        require(msg.value > 0, "Must send ETH");
        Deal storage deal = deals[_dealId];
        deal.amount = msg.value;
        deal.status = DealStatus.FUNDED;
        emit DealFunded(_dealId, msg.value);
    }

    function markDelivered(uint256 _dealId) external onlySeller(_dealId) inStatus(_dealId, DealStatus.FUNDED) {
        deals[_dealId].status = DealStatus.DELIVERED;
        emit DealDelivered(_dealId);
    }

    function releaseFunds(uint256 _dealId) external {
        Deal storage deal = deals[_dealId];
        require(
            msg.sender == deal.buyer || msg.sender == deal.arbiter,
            "Only buyer or arbiter can release"
        );
        require(
            deal.status == DealStatus.DELIVERED || deal.status == DealStatus.DISPUTED,
            "Not eligible for release"
        );

        deal.status = DealStatus.RELEASED;

        uint256 fee = (deal.amount * platformFeePercent) / 100;
        uint256 payout = deal.amount - fee;

        payable(deal.seller).transfer(payout);
        payable(platformOwner).transfer(fee);

        emit DealReleased(_dealId);
    }

    function refundBuyer(uint256 _dealId) external onlyArbiter(_dealId) {
        Deal storage deal = deals[_dealId];
        require(
            deal.status == DealStatus.FUNDED || deal.status == DealStatus.DISPUTED,
            "Invalid state for refund"
        );

        deal.status = DealStatus.REFUNDED;
        payable(deal.buyer).transfer(deal.amount);
        emit DealRefunded(_dealId);
    }

    function raiseDispute(uint256 _dealId) external {
        Deal storage deal = deals[_dealId];
        require(
            msg.sender == deal.buyer || msg.sender == deal.seller,
            "Not authorized"
        );
        require(deal.status == DealStatus.DELIVERED, "Invalid status");
        deal.status = DealStatus.DISPUTED;
        emit DealDisputed(_dealId);
    }

    function autoRefundIfTimeout(uint256 _dealId) external {
        Deal storage deal = deals[_dealId];
        require(
            deal.status == DealStatus.FUNDED || deal.status == DealStatus.DELIVERED,
            "No timeout applicable"
        );
        require(block.timestamp > deal.deadline, "Deadline not passed");
        deal.status = DealStatus.REFUNDED;
        payable(deal.buyer).transfer(deal.amount);
        emit DealRefunded(_dealId);
    }

    function cancelUnfundedDeal(uint256 _dealId) external onlyBuyer(_dealId) inStatus(_dealId, DealStatus.INITIATED) {
        deals[_dealId].status = DealStatus.CANCELLED;
        emit DealCancelled(_dealId);
    }

    function getDeal(uint256 _dealId) external view returns (Deal memory) {
        return deals[_dealId];
    }

    function updatePlatformFee(uint256 _newFeePercent) external {
        require(msg.sender == platformOwner, "Only owner");
        require(_newFeePercent <= 10, "Fee too high");
        platformFeePercent = _newFeePercent;
    }

    function updateOwner(address _newOwner) external {
        require(msg.sender == platformOwner, "Only owner");
        platformOwner = _newOwner;
    }

    receive() external payable {}
    fallback() external payable {}
}
