// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../node_modules/hardhat-console/contracts/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
To solve this level, you only need to provide the Ethernaut with a Solver,
 a contract that responds to whatIsTheMeaningOfLife() with the right number.

Easy right? Well... there's a catch.

The solver's code needs to be really tiny. Really reaaaaaallly tiny. 
Like freakin' really really itty-bitty tiny: 10 opcodes at most.

Hint: Perhaps its time to leave the comfort of the Solidity compiler momentarily, 
and build this one by hand O_o. That's right: Raw EVM bytecode.

Good luck!

**/
contract MagicNum {

  address public solver;

  constructor() {}

  function setSolver(address _solver) public {
    solver = _solver;
  }

  /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */
}

contract Hack {
    
    constructor() {
        assembly{
            // Store bytecode at to mem position 0
            mstore(0x00, 0x602a60005260206000f3) // bytes32 so it is prepadding with 0
            // return mem position 0x16 => skip prepadding 0 for 22 bytes
            return(0x16, 0x0a)
        }
    }
}