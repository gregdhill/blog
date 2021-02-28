+++
title = "Cosmos SDK vs Substrate"
date = "2021-02-28"
author = "Gregory Hill"
+++

Innovative blockchain architectures are poised to address fundamental issues such as scalability, usability and interoperability. Furthermore, several state-of-the-art frameworks under development abstracts common infrastructure such as networking and consensus. This enables developers to focus on the core business logic of their application without re-inventing the wheel.

In this post I will compare two of the most popular blockchain development tool-kits, the **Cosmos SDK** (Tendermint Core) and **Substrate**. Both projects are designed to extract the application's State Transition Function (STF) into reusable modules, but additional features are included within their standard libraries.

As a maintainer of [Hyperledger Burrow](https://github.com/hyperledger/burrow), I have spent a few years working closely with Tendermint Core and the Ethereum Virtual Machine (EVM). More recently, I have been building [PolkaBTC](https://github.com/interlay/BTC-Parachain) on Substrate to bridge Bitcoin with Polkadot. This work has included the development of additional clients to monitor and interact with the parachain over RPC.

## [Cosmos SDK](https://github.com/cosmos/cosmos-sdk) & [Tendermint Core](https://github.com/tendermint/tendermint)

The name Tendermint itself has several meanings, the consensus algorithm - based on Practical Byzantine Fault Tolerance (PBFT) - proceeds in rounds where participants (also known as validators) take turns proposing blocks that extend the main chain. Tendermint Core is an application framework which combines block processing and storage with networking. The company Tendermint was established in 2014 and pioneered initial efforts in the Cosmos ecosystem.

> Tendermint Core is Byzantine Fault Tolerant (BFT) middleware that takes a state transition machine - written in any programming language - and securely replicates it on many machines.

Built in Go, Tendermint Core is responsible for propagating blocks and transactions between nodes, including "mempool" transactions to be processed by the elected leader for that round. The application is then responsible for it's STF by validating cryptographic signatures, ensuring correctness (e.g. that an account is authorized to perform an action) and maintaining it's internal state. It formalizes the Application BlockChain Interface (ABCI) to separate the node from the validation logic. The application may embed Tendermint Core as a library or configure sockets.

On top of Tendermint Core is the Cosmos SDK which describes itself as the "Ruby-on-Rails of blockchain development". There are over one dozen core modules which can be composed together with additional custom runtime logic to create an 'application-specific' blockchain. Each scoped module is formalized as an independent state-machine taking as input a custom message decoded from a signed transaction. For instance, the `supply` module is used to manage account balances whereas the `gov` module allows bonded Atom holders to submit and vote on governance proposals. The `upgrade` module can be used to define a software upgrade `Plan` which contains info such as the git commit of the new binary. Operators can utilize a sidecar process to automatically upgrade the node (using this information) at the designated block height or time. The [CosmWasm](https://github.com/CosmWasm/cosmwasm) package provides WebAssembly (Wasm) smart contracts and bindings for the Cosmos SDK. Alternatively, the [Ethermint](https://github.com/cosmos/ethermint) blockchain has an integrated EVM and compatible RPC interface to leverage existing Ethereum tooling.

The Cosmos SDK has been built from the ground up to support [Cosmos](https://cosmos.network/), the internet of blockchains. Each system / zone maintains its own security based on the consensus algorithm and participants. The Inter-Blockchain Communication (IBC) module enables assets to be traded between compatible chains via pegged light-clients. Off-chain relaying clients propagate block headers between two such zones so that they may verify packet inclusion. To reduce complexity, central hubs are designed to facilitate communication among independent zones.

## [Substrate](https://github.com/paritytech/substrate)

Pioneered by Parity and the Web3 Foundation, Substrate is a complete framework for blockchain development with over thirty core modules. The default components are fully interchangeable, from the core consensus algorithm to the storage and networking mechanisms. For instance, it ships with default implementations for Proof-of-Authority (PoA), Proof-of-Stake (PoS) and Proof-of-Work (PoW) but we could even implement Tendermint consensus. 

> Substrate is a next-generation framework for blockchain innovation. It is both a library for building new blockchain and a "skeleton key" of a blockchain client, able to synchronize to any Substrate-based chain.

Substrate is written in pure Rust and the runtime is compiled to a WebAssembly (Wasm) binary which is stored on-chain. One of the most exciting innovations with this strategy is the ability to invoke fork-less runtime upgrades. The previous runtime can process and introduce consensus-breaking logic automatically via the [democracy](https://github.com/paritytech/substrate/tree/master/frame/democracy) or [sudo](https://github.com/paritytech/substrate/tree/master/frame/sudo) modules (for example). Another interesting feature is the [Off-Chain Worker (OCW)](https://substrate.dev/docs/en/knowledgebase/learn-substrate/off-chain-features#off-chain-workers) subsystem which can be included alongside the runtime to process expensive tasks (possibly in reaction to an on-chain event). The [contracts](https://github.com/paritytech/substrate/tree/master/frame/contracts) module enables the deployment and execution of Wasm based smart contracts for which the eDSL [ink!](https://github.com/paritytech/ink) is adapted. Alternatively, the [Frontier](https://github.com/paritytech/frontier) library can be used to enable full Ethereum compatibility with an EVM module and RPC extension.

[Polkadot](https://polkadot.network/) leverages Substrate and [Cumulus](https://github.com/paritytech/cumulus) to enable interoperable shards / parachains under the shared security of its global relay chain. Actors known as collators provide Proof-of-Verification (PoV) blocks to ensure that transactions included on the (registered) parachain are finalized. Horizontal Relay-routed Message Passing (HRMP) allows messages to be stored in the relay chain and passed to other parachains. In the future, Cross-Chain Message Parsing (XCMP) will enable parachains to communicate directly without this overhead. Alternatively, the [wormhole-bridge](https://github.com/ChorusOne/wormhole-bridge) developed by Chorus One can be used to connect Substrate to the Cosmos SDK via IBC.

## Summary

Both projects have varying strengths but interoperability is a common goal. While there are certainly advantages and disadvantages to each, the choice of framework does not necessarily restrict network participation. In this final section I will outline some key programmatic differences.

The first consideration is language choice; Go (Cosmos SDK) vs Rust (Substrate). Without detailing the nuances of each, Go sacrifies runtime performance for faster compilation whereas Rust is an incredibly safe (but often slow to compile) language with little overhead on execution. Additionally, Rust has a steeper learning curve than compared with Go. It is also worth noting that there are efforts to rebuild some components in other languages (e.g. [tendermint-rs](https://github.com/informalsystems/tendermint-rs)) and API bindings are available in multiple languages.

Many of the interfaces in the Cosmos SDK are wrapped via existing standards - OpenAPI / Swagger and Protobuf / gRPC - which simplifies the process of building custom integrations through code-generation. Substrate uses a custom [codec](https://github.com/paritytech/parity-scale-codec) for encoding / decoding data types and module interfaces must be re-declared - at least in the [subxt](https://github.com/paritytech/substrate-subxt) (Rust) library. However, each module does expose [runtime metadata](https://substrate.dev/docs/en/knowledgebase/runtime/metadata) which is useful for building generalized front-end applications (such as [polkadot{.js}/apps](https://github.com/polkadot-js/apps)).

In reference to my [previous post on key management](/posts/key-management), the Cosmos SDK affords an integrated [Key Management System (KMS)](https://github.com/iqlusioninc/tmkms) for it's validators. Substrate intends for the majority of staked funds to be held in an offline "stash" account, but a session key must be held in-memory to sign consensus related messages.

Thanks for reading! Did I miss anything? Please reach out on [Twitter](https://twitter.com/gregorydhill).

> This was also published on [Medium](https://gdouglashill.medium.com/cosmos-sdk-vs-substrate-451a79f28f4b).
