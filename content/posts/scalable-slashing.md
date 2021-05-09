+++
title = "Scalable Stake Slashing"
date = "2021-05-09"
author = "Gregory Hill"
katex = true
markup = "goldmark"
summary = "Based on the paper titled Scalable Reward Distribution on the Ethereum Blockchain, we can derive an algorithm for proportionally slashing participants based on their stake. This is useful for nomination in Proof-of-Stake since a misbehaving validator can affect a broad number of participants."
+++

This post is yet [another addendum](https://solmaz.io/2019/02/24/scalable-reward-changing/) to the paper titled [Scalable Reward Distribution on the Ethereum Blockchain](http://batog.info/papers/scalable-reward-distribution.pdf) by Batog et al. They define a pull-based algorithm for distributing rewards proportionally to a number of participants without expensive iteration (as in push-based distribution). This simplifies the complexity from `O(n)` (with `n` participants) to constant time `O(1)`. 

This algorithm may be applied to another use-case in nominated Proof-of-Stake (PoS). More specifically, if Alice and Bob nominate their stake to Charlie who is subsequently slashed we need to update all stakes to restrict future withdrawals. As there may be a large number of participants, it is not really feasible to iterate over each entry and re-calculate their stake. Fortunately, it is possible to reuse the algorithm described above with minimal changes. We must restrict the amount of stake a participant can withdraw based on their `actual_stake` as defined:


$$
to\\\_slash_j = stake_{j,n} × slash\\\_per\\\_token_n − slash\\\_tally_{j,n}
$$

$$
actual\\\_stake_j = stake_{j,n} - to\\\_slash_j
$$




Following the addendum by [Onur Solmaz](https://solmaz.io/) which accounts for changing stake sizes, we can reformulate the pseudocode as follows:

```python
class PullBasedSlashing:
    "Constant Time Stake Slashing with Changing Stake Sizes"

    def __init__(self):
        self.total_stake = 0
        self.slash_per_token = 0
        self.stake = {}
        self.slash_tally = {}

    def deposit_stake(self, address, amount):
        "Increase the stake of `address` by `amount`"
        if address not in self.stake:
            self.stake[address] = 0
            self.slash_tally[address] = 0

        self.stake[address] = self.stake[address] + amount
        self.slash_tally[address] = self.slash_tally[address] + self.slash_per_token * amount
        self.total_stake = self.total_stake + amount

    def slash_stake(self, amount):
        "Slash `amount` proportionally to active stakes"
        if self.total_stake == 0:
            raise Exception("Cannot slash zero total stake")

        self.slash_per_token = self.slash_per_token + amount / self.total_stake

    def compute_stake(self, address):
        "Compute actual stake of `address`"
        to_slash = self.stake[address] * self.slash_per_token - self.slash_tally[address]
        return self.stake[address] - to_slash

    def withdraw_stake(self, address, amount):
        "Decrease the stake of `address` by `amount`"

        actual_stake = self.compute_stake(address)
        if amount > actual_stake:
            raise Exception("Requested amount greater than staked amount")

        self.stake[address] = self.stake[address] - amount
        self.slash_tally[address] = self.slash_tally[address] - self.slash_per_token * amount
        self.total_stake = self.total_stake - amount

addr1 = 0x1
addr2 = 0x2

contract = PullBasedSlashing()

contract.deposit_stake(addr1, 100)
contract.deposit_stake(addr2, 100)

contract.slash_stake(20)

print(contract.compute_stake(addr1))
print(contract.compute_stake(addr2))

contract.slash_stake(80)
contract.withdraw_stake(addr1, 50)

print(contract.compute_stake(addr1))
```