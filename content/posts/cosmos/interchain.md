+++
title = "Interchain Standards"
date = "2020-05-25"
author = "Gregory Hill"
+++

The [Inter-Blockchain Communication (IBC) protocol](https://cosmos.network/ibc/) is an architecture designed for Cosmos to allow participating processes to share state. Each module is a deterministic process, such as a replicated state machine with fast transaction finality. Unlike sharded architectures (such as Polkadot), IBC does not provide pooled security.

The specification builds on several assumptions to reason about the capabilities of the protocol. For instance, it assumes
**fast finality** for any adopted consensus mechanism - Tendermint & GRANDPA are two such examples. These processes should also
allow for **cheaply-verifiable consensus transcripts** and basic **key / value functionality**.

## [Clients](https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics)

A [light client](https://www.parity.io/what-is-a-light-client/) provides a way to verify the expected state of a consensus
mechanism without directly participating in it's process. Given a starting state and a "validity predicate", it can follow the
**consensus transcripts** output by another chain to easily verify their correctness. By submitting a transaction inclusion proof
it should then be possible for the light client to verify the sub-state of the canonical chain at any particular height.

Let us assume we have two independent networks, each with a component that can update it's internal state based on externally submitted data. In this case, our component is a light client that can verify **headers** from another chain with a compatible consensus algorithm. For each block agreed upon by the respective network, a corresponding header should be registered by the light client embedded in the counter-chain.

![](/img/ibc-client.png)
*Client*

Out-of-bounds, we can expect some [relaying process](https://github.com/cosmos/ics/tree/master/spec/ics-018-relayer-algorithms) to sign and broadcast these transactions between networks.

## [Connections](https://github.com/cosmos/ics/tree/master/spec/ics-003-connection-semantics)

With two stateful clients eliciting up-to-date headers, we now require _authorization semantics_. That is, both chains need to understand how they can speak with each other. In the following state machine diagram, an actor transacting with chain **A** will trigger the initialization step to connect chain **B**. Each subsequent datagram in the handshake will then require commitment proofs to affirm the counter-chain state.

![](/img/ibc-connection.png)
*Connection*

Each connection is eternal and uniquely identified on a first-come-first-serve basis.

## [Ports & Modules](https://github.com/cosmos/ics/tree/master/spec/ics-005-port-allocation)

After establishing a permanent connection between two chains, we would like to begin passing messages.
Before we can do that however, we need to identify _what_ we are actually going to send data to.

A **module** is an abstraction used to denote a sub-component of a particular state machine. We will see
a particular example of this later on, but for now let us imagine these as smart contracts. Each module may
bind to one or more **ports** to allow incoming traffic to be routed correctly. Additionally, a module can connect
to multiple outbound ports bound by external modules. They may be released at any point in time.

To draw a familiar analogy, imagine you are requesting HTTP data from a web server. The server will typically serve requests from port 80 which the client will automatically default to. The client will then bind to an ephemeral port in order for the return traffic to be routed correctly.

## [Channels](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics)

Port allocation and ownership facilitates the permissioning of channels to modules. Through a connection, an actor may open a channel between two modules by linking the source and destination ports. Analogous to a TCP / UDP connection, a channel can be **ordered** or **unordered** and is typically ephemeral. The state machine for establishing a channel can be seen in the following diagram:

![](/img/ibc-channel.png)
*Channel*

It is important to note that after initialization, each subsequent step requires a proof from the counter-chain to verify against it's corresponding light client. It can determine this by checking the connection object for the source network.

## [Packets](https://github.com/cosmos/ics/tree/master/spec/ics-004-channel-and-packet-semantics)

Once a channel is established, we can send packets containing arbitrary data payloads for use with higher level protocols. We do however require a partial interface defined as follows:

| Field            | Description                 |
|------------------|-----------------------------|
| sequence         | order of sends and receives |
| timeoutHeight    | consensus height expiry     |
| timeoutTimestamp | timestamp expiry            |
| sourcePort       | sending port                |
| sourceChannel    | sending channel             |
| destPort         | receiving port              |
| destChannel      | receiving channel           |
| data             | opaque value                |

It is a module's responsibility to send and receive packets. Each step in the following state machine diagram should additionally validate connection and channel state, port ownership and timeout. On send we store a constant sized commitment to the packet data and timeout which should be verified by the receiving chain. Finally, the calling module should delete the packet commitment on acknowledgement.

![](/img/ibc-packet.png)
*Packet*

An ordered channel should optionally check that the sequence numbers are monotonically increasing.

## [Asset Transfer](https://github.com/cosmos/ics/tree/master/spec/ics-020-fungible-token-transfer)

An example payload for application layer usage is fungible asset transfer via a two-way peg. Specifically, we want to *preserve*:

- ownership
- fungibility
- total supply

Let us assume an account on chain **A** wants to send tokens to an account on chain **B**. After channel setup, both chains
should recognize a particular _escrow address_. The desired path can then be summarized as follows:

### **A** -> **B**

1) **A** transfers `amount` of tokens from `sender` to the _escrow address_ for the source channel.
2) **A** sends packet to **B** with `denomination`, `amount` and `recipient`.
3) **B** receives packet and mints `amount` of tokens to `recipient`.

### **B** -> **A**

1) **B** burns `amount` of tokens owned by `sender`.
2) **B** sends a packet to **A** with `denomination`, `amount` and `recipient`.
3) **A** receives packet and transfers `amount` of tokens from the _escrow account_ to `recipient`.

> Note: The specification does not handle the "diamond problem", where tokens are transferred through chains: `A -> B -> D -> C -> A`.