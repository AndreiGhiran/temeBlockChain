// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.15;

contract DistributeFunding {

	bool funded = false;
	uint total_funds;
    uint total_stake = 0;
    mapping(address => uint) benefactor_stakes;

	//stake holdes pot fi adaugati de alt user prin aceasta functie
    function addBenefector(address payable user, uint stake) external {
        require(!funded &&  total_stake - benefactor_stakes[user] + stake <= 100, "Already funded or stake to big");
        benefactor_stakes[user] = stake;
        total_stake += stake;
    }

	//useri pot devenii stake holdes prin apelarea acestei functii
    function joinCroundfnding(uint stake) external{
        require(!funded &&  total_stake - benefactor_stakes[msg.sender] + stake <= 100, "Already funded or stake to big");
        benefactor_stakes[msg.sender] = stake;
        total_stake += stake;
    }

	//functia returneaza stake-ul corespunzator adresei user-ului data ca parametru;
    function getBenefactorStake(address user) view external returns(uint){
        return benefactor_stakes[user];
    }

	//functia returneaza stake-ul corespunzator user care apeleaza functia;
    function getMyStake() view external returns(uint){
        return benefactor_stakes[msg.sender];
    }

	//functia ce trebuie apelata de contractul CrowdFunding pentru a primi faondurile si de ai lasa pe stake holders sa isi retraga fondurile
    function receiveFunds() payable external {
        require(msg.value > 0);
        total_funds = msg.value;
        funded = true;
    }

	//functia trimite unui utilizator ce are un stake > 0 fondurile ce i se cuvin si dupa seteaza stake-ul acelui utilizator la 0
    function getMyFunds() external {
        require(benefactor_stakes[msg.sender] != 0 && funded, "No funds available for you");
        uint amount = (benefactor_stakes[msg.sender] * total_funds) / 100;
        payable(msg.sender).transfer(amount);
        benefactor_stakes[msg.sender] = 0;
    }

	//functie pentru interogarea starii contractului
    function getState() external view returns(string memory){
        if(funded)
            return "Funded";
        else
            return "Unfunded";
    }

    receive() payable external{}

    fallback () external {}

}