// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.15;

contract SponsorFunding {
    uint public balance;
    address public owner;
    address payable public crowdFundingAddress;
    uint sponsorshipPercent;
    mapping(address => uint) contributors;
    
    constructor() payable {
        sponsorshipPercent = 10; //10%
        owner = msg.sender;
    }
 
    function changeSponsorshipPercent(uint _sponsorshipPercent) public onlyOwner {
        sponsorshipPercent = _sponsorshipPercent;
    }

    function setCrowdFundingAddress(address payable _crowdFundingAddress) public onlyOwner{
        crowdFundingAddress = _crowdFundingAddress;
    }

    function deposit() external onlyOwner payable {
        balance += msg.value;
    }

    function sponsorship() public payable {
        uint extra = address(msg.sender).balance * sponsorshipPercent / 100;
        require(extra <= address(this).balance, "Not enough money for sponsorship !");
        balance -= extra;
        payable(msg.sender).transfer(extra);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    receive() external payable {}
    fallback() external {}
}
