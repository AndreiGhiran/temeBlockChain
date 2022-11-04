// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.15;

contract SponsorFunding {
    uint public balance;
    address public owner;
    uint sponsorshipPercent;
    mapping(address => uint) contributors;
    
    constructor() payable {
        if(msg.value>=0)
            balance = msg.value;
        sponsorshipPercent = 10; //10%
        owner = msg.sender;
    }
 
    function changeSponsorshipPercent(uint _sponsorshipPercent) public onlyOwner {
        sponsorshipPercent = _sponsorshipPercent;
    }

    function deposit() external onlyOwner payable {
        balance += msg.value;
    }

    function sponsorship() external{
        uint extra = address(msg.sender).balance * sponsorshipPercent / 100;
        if(extra <= address(this).balance){
            balance -= extra;
            payable(msg.sender).transfer(extra);
        }
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
