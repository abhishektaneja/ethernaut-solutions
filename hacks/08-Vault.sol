
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Vault {
  bool public locked;
  bytes32 private password;

  constructor(bytes32 _password) {
    locked = true;
    password = _password;
  }

  function setNew(bytes32 _password) public {
    locked = true;
    password = _password;
  }

  function unlock(bytes32 _password) public {
    if (password == _password) {
      locked = false;
    }
  }
}

interface VaultA {
  function unlock(bytes32 _password) external;
  function locked() external view returns(bool);
}

contract Hack {

    /**
     1. Read the storage: await web3.eth.getStorageAt(contract.address, 1)
     2. call the contract.unlock with previous data
    **/
    
}
