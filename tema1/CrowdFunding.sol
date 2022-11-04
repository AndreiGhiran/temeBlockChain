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

    constructor(uint _fundingGoal, address payable _sponsorFundingAddress, address payable _distributeFundingAddress) {
        fundingGoal = _fundingGoal;
        sponsorFundingAddress = _sponsorFundingAddress;
        distributeFundingAddress = _distributeFundingAddress;
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

    function withdraw(uint amount) external {
        require(currentState == State.Unfunded, "Can't withdraw anymore !");
        require(contributors[msg.sender] > amount, "Not enough funds !");
        contributors[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function sendAllToDistributeFunding() external onlyOwner {
        require(currentState == State.Financed, "Can't send yet !");
        DistributeFunding distributer = DistributeFunding(distributeFundingAddress);
        distributer.receiveFunds{value:address(this).balance}();
    }

    function getSponsorship() public onlyOwner {
        require(currentState == State.Prefinanced, "Can't get sponsorship anymore !");
    
        SponsorFunding sponsorFunding = SponsorFunding(sponsorFundingAddress);
        sponsorFunding.sponsorship();
        currentState = State.Financed;
    }

    function getState() external view returns(string memory){
        if (currentState == State.Unfunded)
            return "Unfunded";
        else if (currentState == State.Prefinanced)
            return "Prefinanced";
        else 
            return "Financed";
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Only the owner can do this!");
        _;
    }

    receive() external payable {}
    fallback() external {}
    
}
