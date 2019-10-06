+++
title = "ERC Token Standards"
date = "2019-10-05"
author = "Gregory Hill"
+++

You may be familiar with the concept of a Request for Comments (RFC) from a body such as the Internet Engineering 
Task Force (IETF). They are just technical documents that describe the specifications for a particular technology -
`HTTP/1.1` is described by [RFC-2616](https://www.ietf.org/rfc/rfc2616.txt) for instance. Application level standards
in the Ethereum ecosystem are thus named accordingly, forming one possible part of an Ethereum Improvement Proposal (EIP).
For more details on this, check out [EIP-1](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1.md).

## ERC-20

[ERC-20](https://eips.ethereum.org/EIPS/eip-20) is one such standard, named simply because it was the 
[twentieth issue](https://github.com/ethereum/eips/issues/20) on GitHub. It defines six 
[functions](https://solidity.readthedocs.io/en/v0.4.21/contracts.html#functions) that should be implemented
and two [events](https://solidity.readthedocs.io/en/v0.4.21/contracts.html#events) that should be triggered 
in order for the smart contract to be considered compliant.

### Functions

```solidity
// Get the total number of tokens possible:
function totalSupply() constant returns (uint256 totalSupply)

// Get the target account's balance:
function balanceOf(address _owner) constant returns (uint256 balance)

// Send token to target account:
function transfer(address _to, uint256 _value) returns (bool success)

// Send token to target account from authorized account:
function transferFrom(address _from, address _to, uint256 _value) returns (bool success)

// Allow the target account to withdraw up to value:
function approve(address _spender, uint256 _value) returns (bool success)

// Amount approved account is allowed to spend:
function allowance(address _owner, address _spender) constant returns (uint256 remaining)

```

### Events

```solidity
// Trigger on token transfer:
event Transfer(address indexed _from, address indexed _to, uint256 _value)

// Trigger when account is approved:
event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```

### Example

Before reading ahead you should first be aware of 
[abstract](https://solidity.readthedocs.io/en/v0.5.3/contracts.html#abstract-contracts) contracts and 
[interfaces](https://solidity.readthedocs.io/en/v0.5.3/contracts.html#interfaces) in Solidity. 
Both concepts allow for a level of generality in the child implementation, with assurance that the
inherited definitions will be preserved. The [smart contract library](https://github.com/OpenZeppelin/openzeppelin-contracts) 
by OpenZeppelin details many such APIs for developers to reuse. In particular, 
[IERC20.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol)
contains all definitions for ERC-20. We can import this interface and assert that our contract implements it:

```solidity
pragma solidity ^0.5.0;

import "./IERC20.sol";

contract Token is IERC20 {
    uint256 supply;
    mapping (address => uint256) balances;
    constructor() public {  
        supply = 1000000000;  
        balances[msg.sender] = supply;  
        emit Transfer(msg.sender, msg.sender, supply);  
    }
    
    function totalSupply() external view returns (uint256) {
        return supply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        if (balances[msg.sender] > amount) {
            balances[msg.sender] -= amount;
            balances[recipient] += amount;
            emit Transfer(msg.sender, recipient, amount);
            return true;
        }
        return false;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return 0;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        return false;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        return false;
    }
}
```

### MakerDAO

I had previously mentioned this in my post on [Decentralized Autonomous Organizations (DAO)](../dao/), 
MakerDAO is responsible for the stablecoin named Dai. To mint this token, a user must lock up their Ether
in a Collateralized Debt Position (CDP). This accrues interest over time (known as a stability fee) and all
Dai will need to be paid back before the CDP can be unlocked. Without diving too deep into the economics,
Maker has integrated a number of techniques to ensure the value of a single Dai is equivalent to the USD.
The whole system is open-source, and is in fact ERC-20 compliant as shown [here](https://github.com/makerdao/dss/blob/master/src/dai.sol).


## ERC-721

To understand why [ERC-721](https://github.com/ethereum/EIPs/issues/721) exists, we need to understand the concept of
fungibility. In essence, something is fungible if it is completely interchangeable. For example, ERC-20 is fungible
because it's impossible to distinguish individual tokens, like gold - where one unit can be wholly replaced with another
with no loss of value. Now, let's imagine we wanted to build a virtual game in which players have unique assets.
You may have heard of the game [CryptoKitties](https://www.cryptokitties.co/) for instance, where no two cats are the same.
This is built atop ERC-721, a standard for the Non-Fungible Token (NFT) - see the interface defined by
[OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol).