// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DistributeFunding {

	bool funded = false;
    uint total_stake = 0;
    mapping(address => uint) benefactor_stakes;

    function addBenefector(address payable user, uint stake) external {
        require(!funded,"Funded");
        benefactor_stakes[user] = stake;
    }

    function getBenefactorStake(address user) view external returns(uint){
        return benefactor_stakes[user];
    }

    function receiveFunds() payable external {
        require(msg.value > 0);
        funded = true;
    }

    function getFunds() external {
        require(benefactor_stakes[msg.sender] != 0 && funded, "No funds available");
        uint amount = (benefactor_stakes[msg.sender] * address(this).balance) / 100;
        payable(msg.sender).transfer(amount);
        benefactor_stakes[msg.sender] = 0;
    }

    receive() payable external{}

    fallback () external {}

}

pragma solidity >=0.8.0 <=0.8.15;

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
