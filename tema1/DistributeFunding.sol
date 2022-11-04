// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.15;

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