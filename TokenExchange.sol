// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BasicToken.sol";
import "./SecondToken.sol";


contract TokenExchange {
    BasicToken public tokenA;
    SecondToken public tokenB;
    address public owner;

    constructor(BasicToken _tokenA, SecondToken _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        owner = msg.sender;
    }
    function exchangeAtoB(uint256 _amountA) public {
        require(_amountA > 0, "Cannot exchange zero tokens");
        uint256 amountB = _amountA;
        require(tokenA.balanceOf(msg.sender) >= _amountA, "Insufficient balance of token A");
        require(tokenB.balanceOf(msg.sender) + amountB <= tokenB.totalSupply(), "Insufficient token B supply");

        tokenA.transferFrom(msg.sender, address(this), _amountA);
        tokenB.transfer(msg.sender, amountB);
    }

    function exchangeBtoA(uint256 _amountB) public {
        require(_amountB > 0, "Cannot exchange zero tokens");
        uint256 amountA = _amountB;
        require(tokenB.balanceOf(msg.sender) >= _amountB, "Insufficient balance of token B");
        require(tokenA.balanceOf(msg.sender) + amountA <= tokenA.totalSupply(), "Insufficient token A supply");

        tokenB.transferFrom(msg.sender, address(this), _amountB);
        tokenA.transfer(msg.sender, amountA);
    }

    function buyTokenA(uint256 _amount) public payable {
        require(_amount > 0, "Cannot buy zero tokens");
        uint256 cost = _amount * 1 ether; 
        require(msg.value >= cost, "Not enough ETH sent");
        require(tokenA.balanceOf(address(this)) >= _amount, "Insufficient tokens");

        tokenA.transfer(msg.sender, _amount);

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
    }

    function buyTokenB(uint256 _amount) public payable {
        require(_amount > 0, "Cannot buy zero tokens");
        uint256 cost = _amount * 1 ether; 
        require(msg.value >= cost, "Not enough ETH sent");
        require(tokenB.balanceOf(address(this)) >= _amount, "Insufficient tokens");

        tokenB.transfer(msg.sender, _amount);

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
    }

    function withdrawEther() public {
    require(msg.sender == owner, "Only the owner can withdraw Ether");
    uint256 balance = address(this).balance;
    require(balance > 0, "No Ether to withdraw");
    payable(owner).transfer(balance);
}
}
