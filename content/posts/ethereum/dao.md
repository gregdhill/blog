+++
title = "Decentralized Autonomous Organizations (DAO)"
date = "2019-09-28"
author = "Gregory Hill"
tags = [
    "ethereum",
    "solidity",
]
+++

In traditional governance systems, we rely upon human entities to enact policies on
behalf of constituents. This may viewed as in contemporary politics or in the hierarchical
structure of an enterprise. An historical issue however, is that it is not always possible 
to trust the judgement of those in charge. In economics, this is known as the 
[principle-agent problem](https://en.wikipedia.org/wiki/Principal%E2%80%93agent_problem).

A DAO is a form of self-enforcing protocol, typically modelled as a smart contract. Each
decision is recorded on a public ledger which ensures transparency. It allows participants
to propose, vote on and enact policies, guided by a strict set of rules.

An [infamous attack](https://www.wired.com/2016/06/50-million-hack-just-showed-dao-human/)
brought a lot of attention to the subject a few years ago, but there have been many
advancements since. For example, [MakerDAO](https://makerdao.com/en/dai/) have created the 
'Dai' stablecoin, pinned to the value of the US dollar. I will save this topic for a future
post, but if you want to know more now, checkout [this post](https://medium.com/@james_3093/the-dai-stablecoin-is-a-game-changer-for-ethereum-and-the-entire-cryptocurrency-ecosystem-13fb412d1e75).
Another interesting development is [MolochDAO](https://medium.com/@simondlr/the-moloch-dao-collapsing-the-firm-2a800b3aa2e7)
which aims to drive community funding for open-source projects. In short, stakeholders vote on proposals 
(typically for work to be undertaken) and upon success the proposer is awarded some amount of token. They
can then choose to use this power to vote on other proposals or burn it (convert to ether).

## Example

Borrowing some of the key ideas from MolochDAO, I've put together an example contract:

```solidity
pragma solidity >=0.5.0;

contract MolochDAO {
    uint pot;
    uint participants;
    mapping (address => uint) power;
    mapping (address => uint) proposals;
    mapping (address => uint) votes;

    // initial seed funds
    constructor() public payable {
        pot = msg.value;
        participants++;
        power[msg.sender] = msg.value;
    }
    
    // caller burns participation for token
    function burn() public {
        if (power[msg.sender] == 0) {
            return;
        }
        participants--;
        pot -= power[msg.sender];
        power[msg.sender] = 0;
        msg.sender.transfer(power[msg.sender]);
    }
    
    // create a proposal for funds
    function propose(uint want) public {
        proposals[msg.sender] = want;
    }
    
    // vote for a proposer
    function vote(address proposal) public {
        if (proposals[proposal] == 0) {
            return;
        } else if (power[msg.sender] > 0) {
            votes[proposal]++;
        }

        if (votes[proposal] == participants) {
            power[proposal] += proposals[proposal];
            votes[proposal] = 0;
        }
    }
}
```

This sets up an initial seed pot in the constructor and anyone can then `propose` to take
an amount of the shares. If we receive enough votes, the proposer will be added to the pool
with the option to `burn` their share to receive ether.

> Do not use this contract with token of value.

I should add that this contract is nowhere near complete or even fair to all participants.
For instance, the last party to vote will incur additional gas costs. A slightly more critical
flaw however is that I do not force any kind of unique constraint on the voter, so any participant
could submit multiple votes to unlock the funds.

## Addendum

I'm excited to share some work I've [recently completed](https://github.com/hyperledger/burrow/pull/1238) on
[Hyperledger Burrow](https://github.com/hyperledger/burrow). We now support experimental Web3, meaning that
all of your favorite Ethereum tooling should now work with our built-in JSON RPC.

Lets start a chain with one validator to process blocks and two participants from which we can transact:

```shell
burrow spec -v1 -p2 | burrow configure --curve-type secp256k1 -s- | burrow start -c- 
```

If we now query for the latest block, we should get a response:

```shell
curl -X POST localhost:26660 --data \
   '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}'
```

[Truffle](https://www.trufflesuite.com/) is a tool for smart contract development and testing.
Follow the configuration instructions in our [docs](http://hyperledger.github.io/burrow/#/reference/web3?id=truffle),
download the [MolochDAO](https://github.com/MolochVentures/moloch) source and follow the [deploy instructions](https://github.com/MolochVentures/moloch#deploying-a-new-pool):

```shell
git clone git@github.com:MolochVentures/moloch.git
cd moloch
npm install
npx buidler moloch-deploy --network burrow
```