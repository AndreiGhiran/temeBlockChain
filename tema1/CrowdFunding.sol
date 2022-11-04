// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.15;

import "./SponsorFunding.sol";
import "./DistributeFunding.sol";

contract CrowdFunding {
    uint public fundingGoal;
    address public owner;
    address payable public sponsorFundingAddress;
    address payable public distributeFundingAddress;
    mapping(address => uint) public contributors;
    enum State { Unfunded, Prefinanced, Financed }
    State currentState;

    constructor(uint _fundingGoal, address payable _sponsorFundingAddress) {
        fundingGoal = _fundingGoal;
        sponsorFundingAddress = _sponsorFundingAddress;
        currentState = State.Unfunded;
        owner = msg.sender;
    }

    function deposit() external payable {
        require(currentState == State.Unfunded, "The funds are not accepted anymore ! ");
        contributors[msg.sender] += msg.value;
        if (address(this).balance >= fundingGoal) {
            currentState = State.Prefinanced;
        }
    }

    function withdraw(uint amount) external payable {
        require(currentState == State.Unfunded, "Can't withdraw anymore !");
        require(contributors[msg.sender] > amount, "Not enough funds !");
        contributors[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function sendAllToDistributeFunding() external payable onlyOwner {
        require(currentState == State.Financed, "Can't send yet !");
        payable(distributeFundingAddress).transfer(address(this).balance);
    }

    function setDistributeFundingAddress(address payable _distributeFundingAddress) public onlyOwner{
        distributeFundingAddress = _distributeFundingAddress;
    }

    function getSponsorship() public payable onlyOwner {
        require(currentState == State.Prefinanced, "Can't get sponsorship anymore !");
    
        SponsorFunding sponsorFunding = SponsorFunding(sponsorFundingAddress);
        sponsorFunding.sponsorship();
        currentState = State.Financed;
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
