+++
title = "Polkadot Governance"
date = "2021-08-13"
author = "Gregory Hill"
+++

On-chain governance in Polkadot is used to perform forkless runtime upgrades and change system parameters based on community input. Anyone with sufficient DOT holdings can participate, but some roles are reserved for specialized entities.


## Participants

There are two primary roles:

* **Holders** own DOT tokens for deposits and vote weighting.
* **Members** are elected into a council or committee.

In Polkadot, there are two membership instantiations which directly affects the voting power needed to execute a proposal.

### Council

The **Council** is voted in by DOT holders to directly propose referenda. However, well-supported community proposals may also be selected for referenda periodically. All participants may vote on proposals or referenda as they await finalization. The council can also submit emergency referenda and cancel ongoing referenda.


### Technical Committee

The **Technical Committee** is voted in by the **Council** and can fast-track emergency referenda. They are also able to cancel a proposal if agreed unanimously, which burns the deposit.

## Elections

<!-- TODO -->


## Proposals and Referenda

Proposals may be started by the community or council and are routinely "baked" into referenda.

There are three vote thresholds:

* **Simple majority** requires more than half of the total voting power. 
* **Super majority approval** requires *far* more than half of the total voting power. 
* **Super majority against** requires *far* more than half of the total voting power. 


<!-- preimage = encoded dispatchable call -->

### Democracy - Voting

1. Holder proposes dispatchable call (preimage)
2. Holder seconds proposal
3. New referenda are routinely baked
4. Holders vote on referenda
5. If accepted, preimage is executed and deposit is released
6. If the call fails, the proposer is slashed
7. On timeout, preimage may be reaped for deposit

## Collective - Voting

1. Member proposes preimage (must call democracy)
2. Members vote on proposals
3. Members may "execute" accepted proposals
4. Once baked, preimage must be noted