// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SampleToken.sol";

contract Auction {
    address payable internal auction_owner;
    uint256 public auction_start;
    uint256 public auction_end;
    uint256 public highestBid;
    address public highestBidder;
    address public tokenContract;
    address public tokenSale;

    enum auction_state {
        CANCELLED, STARTED
    }

    struct car{
        string Brand;
        string Rnumber;
    }
    
    car public Mycar;
    address[] bidders;
    mapping(address => uint) public bids;
    address[] arrOfBids;
    auction_state public STATE;

    modifier an_ongoing_auction() {
        require(block.timestamp <= auction_end && STATE == auction_state.STARTED);
        _;
    }
    
    modifier only_owner() {
        require(msg.sender==auction_owner);
        _;
    }
    
    function bid() public virtual payable returns (bool) {}
    function withdraw() public virtual returns (bool) {}
    function cancel_auction() external virtual returns (bool) {}
    
    event BidEvent(address indexed highestBidder, uint256 highestBid);
    event WithdrawalEvent(address withdrawer, uint256 amount);
    event CanceledEvent(string message, uint256 time);  
    
}

contract MyAuction is Auction {
    
    constructor (uint _biddingTime, address payable _owner, string memory _brand, string memory _Rnumber, address payable _tokenContract) {
        auction_owner = _owner;
        auction_start = block.timestamp;
        auction_end = auction_start + _biddingTime*1 hours;
        STATE = auction_state.STARTED;
        Mycar.Brand = _brand;
        Mycar.Rnumber = _Rnumber;
        tokenContract = _tokenContract;
    } 
    
    function get_owner() public view returns(address) {
        return auction_owner;
    }
    
    function bid(uint256 tokens) public payable an_ongoing_auction returns (bool) {      
        require(bids[msg.sender] + tokens > highestBid,"You can't bid, Make a higher Bid");
        require(bids[msg.sender] == 0, "You can bid only once !");
        
        SampleToken tokenContract = SampleToken(tokenContract);
        uint256 bidderBalance = tokenContract.balanceOf(msg.sender);
        require(bidderBalance >= tokens, "Insuficient tokens !");

        highestBidder = msg.sender;
        highestBid = bids[msg.sender] + tokens;
        bidders.push(msg.sender);
        bids[msg.sender] = highestBid;
        arrOfBids.push(msg.sender);

        tokenContract.transferFrom(msg.sender, address(this), tokens);
        emit BidEvent(highestBidder,  highestBid);
        return true;
    } 
    
    function cancel_auction() external only_owner an_ongoing_auction override returns (bool) {
        STATE = auction_state.CANCELLED;
        emit CanceledEvent("Auction Cancelled", block.timestamp);
        return true;
    }
    
    function retrieveTokens() public payable onlyOwner {
        require(STATE == auction_state.CANCELLED, "You can't withdraw, the auction is still open");
        SampleToken tokenContract = SampleToken(tokenContract);
        tokenContract.transfer(auction_owner, highestBid);
        
        for (uint256 i = 0; i < arrOfBids.length; i++) {
            address bidder = arrOfBids[i];
            uint256 bidderTokens = bids[bidder];
            if (bidder != highestBidder) {
                tokenContract.transfer(bidder, bidderTokens);
            }
        }
    }

    function withdraw() public override returns (bool) {
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED, "You can't withdraw, the auction is still open");
        uint amount;

        amount = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit WithdrawalEvent(msg.sender, amount);
        return true;
    }
    
    function destruct_auction() external only_owner returns (bool) {
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED,"You can't destruct the contract,The auction is still open");
        for(uint i = 0; i < bidders.length; i++) {
            assert(bids[bidders[i]] == 0);
        }
        selfdestruct(auction_owner);
        return true;
    }

    modifier onlyOwner() {
        require(msg.sender == auction_owner, "Only the owner can do this!");
        _;
    }
        
    fallback () external payable { }
    receive () external payable { } 
}