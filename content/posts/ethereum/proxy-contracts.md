+++
title = "Upgradable Proxy Contracts"
date = "2020-04-06"
author = "Gregory Hill"
tags = [
    "ethereum",
    "solidity",
]
+++

Smart contracts in Ethereum are immutable; once they have been included in a block they cannot be changed. This is a weird philosophy to adopt from a software engineering perspective. What if there are bugs in your code? Solidity has a [plethora of known attacks](https://consensys.github.io/smart-contract-best-practices/known_attacks/) which, given the economical value at risk, is troubling to say the least. However, we also do not want to interact with an unstable application that can be arbitrarily updated.

One of the more impressive concepts that I learned recently regards the decoupling of state and functionality. By separating _what_ a contract stores from _how_ it accesses it we can easily upgrade a contract on chain. Using the infamous DAO hack as an example, let's assume we have a smart contract which stores an amount of funds but also suffers from the reentrancy bug. Without changing the underlying state, we want to rewire the logic to prevent it from being exploited. Additionally, we may not want to force the original consumers to use a new (pre-initialized) contract.

Before getting into the details, we first need to understand the difference between `CALL` and `DELEGATECALL`. If we call a class method in the traditional sense, then we only expect it to alter it's own internal state (omitting arguments). Conversely, if something is delegated then we entrust someone to carry out a task on our behalf. These concepts naturally extend to Ethereum; if we delegate a call we ask a contract to operate on our state instead of it's own.

In the following example I have defined two contracts; `Setter` exposes a method to directly alter it's state through the `set` function, and `Getter` contains the two forward calls described above. Notice the calling `set` or `call` will alter the `value` stored in `Setter`, whereas `delegatecall` will update the `value` in `Getter`.

```solidity
pragma solidity >=0.0.0;

contract Setter {
    uint public value;
    
    function set(uint256 _value) external {
        value = _value;
    }
}

contract Getter {
    uint public value;
    
    function call(address setter, uint256 value) public {
        setter.call(abi.encodeWithSignature("set(uint256)", value));
    }
    
    function delegatecall(address setter, uint256 value) public {
        setter.delegatecall(abi.encodeWithSignature("set(uint256)", value));
    }
}
```

Another feature of Solidity that we will utilise is known as the fallback function. This unnamed function cannot take any arguments and is not able to return anything, but will run instead if the called function is not found - suitable for a proxy.

The proxy technique was first popularized by Nick Johnson of the Ethereum Foundation [here](https://gist.github.com/Arachnid/4ca9da48d51e23e5cfe0f0e14dd6318f). The basic idea is that the proxy extends the same storage layout but would forward any and all calls to the registered logic contract.

In this example, we first deploy the proxy and then register either of the two functional contracts to update the `value`:

```solidity
contract Storage {
    uint public value = 0;
}

contract Proxy is Storage {
    address internal proxied;

    function redirect(address _proxied) public {
        proxied = _proxied;
    }

    function () external payable {
        address addr = proxied;
        assembly {
            let freememstart := mload(0x40)
            calldatacopy(freememstart, 0, calldatasize())
            let success := delegatecall(not(0), addr, freememstart, calldatasize(), freememstart, 32)
            switch success
            case 0 { revert(freememstart, 32) }
            default { return(freememstart, 32) }
        }
    }
}

contract Addition is Storage {
    function add(uint _value) public {
        value += _value;
    }
}

contract Subtraction is Storage {
    function sub(uint _value) public {
        value -= _value;
    }
}
```

If you are interested in learning about other proxy patterns, read the [fantastic article by OpenZeppelin](https://blog.openzeppelin.com/proxy-patterns/).