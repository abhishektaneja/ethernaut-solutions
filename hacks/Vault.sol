
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Vault {
  bool public locked;
  bytes32 private password;

  constructor(bytes32 _password) public {
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

contract ValutBreaker {

    VaultA external_contract_i;

    constructor(){
        
    }

  
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
      bytes memory tempEmptyStringTest = bytes(source);
      if (tempEmptyStringTest.length == 0) {
          return 0x0;
      }

      assembly {
          result := mload(add(source, 32))
      }
    }

    /**

    The way to hack this contract is: read storage using await web3.eth.getStorageAt(contract.address, 1)
    Once you have the password , you can call the unlock function directly
    **/
}
