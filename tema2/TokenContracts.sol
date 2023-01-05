// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SampleToken {
    
    string public name = "Fairy Dust";
    string public symbol = "FYD";

    uint256 public totalSupply;

    uint256 public tokensSinceLastMint;
    address owner;
    
    event Transfer(address indexed _from,
                   address indexed _to,
                   uint256 _value);

    event Approval(address indexed _owner,
                   address indexed _spender,
                   uint256 _value);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public allowance;

    constructor (uint256 _initialSupply) {
        require(_initialSupply > 0, "Initial supply < 0!");

        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        tokensSinceLastMint = 0;
        owner = msg.sender;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "not enough token in balance");

        emit Transfer(msg.sender, _to, _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        tokensSinceLastMint += _value;

        if (tokensSinceLastMint >= 10000) {
            mintTokens();
        }
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value >= 0, "Value can't be negative");
        require(balanceOf[msg.sender] >= _value, "Not enough tokens in balance");

        emit Approval(msg.sender, _spender, _value);
        allowance[msg.sender][_spender] = _value;
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from],  "Not enough tokens in balance");
        require(_value <= allowance[_from][msg.sender],  "Not enough allowance for transfer");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        tokensSinceLastMint += _value;

        emit Transfer(_from, _to, _value);

        if (tokensSinceLastMint >= 10000) {
            mintTokens();
        }

        return true;
    }

    function mintTokens() public{
        require(tokensSinceLastMint >= 10000, "Not enough transferred tokens to mint new ones");

        uint256 tokensToMint = tokensSinceLastMint / 10000;
        totalSupply += tokensToMint;
        balanceOf[owner] += tokensToMint;
        tokensSinceLastMint -= tokensToMint * 10000;
    }
}

contract SampleTokenSale {
    
    SampleToken public tokenContract;
    uint256 public tokenPrice;
    address owner;

    uint256 public tokensSold;

    event Sell(address indexed _buyer, uint256 indexed _amount);

    constructor(SampleToken _tokenContract, uint256 _tokenPrice) {
        require(_tokenPrice >= 0, "Price can't be negative!");

        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value >= _numberOfTokens * tokenPrice, "Not enough wei to buy tokens!");
        require(tokenContract.balanceOf(owner) >= _numberOfTokens, "Not enough tokens in ballance to sell");
        require(tokenContract.transferFrom(owner,msg.sender, _numberOfTokens), "Token transfer failed!");
        
        emit Sell(msg.sender, _numberOfTokens);
        tokensSold += _numberOfTokens;
        uint256 amountToReturn = msg.value - ( _numberOfTokens * tokenPrice);
        
        payable(msg.sender).transfer(amountToReturn);
    }

    function endSale() public {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))), "Token transfer failed!");
        require(msg.sender == owner,  "Only the owner can end the sale");

        payable(msg.sender).transfer(address(this).balance);
    }

    function changePrice(uint256 _newPrice) public {
        require(msg.sender == owner, "Only the owner can change the price");
        require(_newPrice >= 0, "Price can't be negative");

        tokenPrice = _newPrice;
    }
}