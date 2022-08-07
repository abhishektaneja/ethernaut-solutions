
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

    function setAddress(address _add) public{
      external_contract_i = VaultA(_add);
    }

    function locked() public view returns(bool){
      return external_contract_i.locked();
    }

    function unlock(string memory pass) public payable {
      external_contract_i.unlock(stringToBytes32(pass));
    }

    function setNewPass(string memory pass) public{
      (bool success,)  = address(external_contract_i).call(abi.encodeWithSignature("constructor(bytes32)", stringToBytes32(pass)));
      require(success, 'Success was not true');
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
}
