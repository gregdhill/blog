+++
title = "Substrate & Ink"
date = "2020-04-08"
author = "Gregory Hill"
tags = [
    "substrate",
    "ink",
    "rust",
]
+++

To interact with Polkadot, there are three envisioned development trajectories; a parachain implements it's own runtime logic (think custom sidechain), a parathread is similar but only produces a block when absolutely necessary to update the relay chain, and a smart contract can run atop any chain with the correct execution environment. Substrate enables the former methodology based on a modular architecture with pluggable consensus and Parity maintain an embedded Domain Specific Language (eDSL) atop Substrate for WASM smart contracts.

As of the time of writing, interchain support is not yet finalized. Once complete, anything developed with Substrate will be able to communicate with the ecosystem through [Cumulus](https://github.com/paritytech/cumulus) using [Cross-chain Message Passing](https://wiki.polkadot.network/docs/en/learn-crosschain). [Collators](https://wiki.polkadot.network/docs/en/maintain-collator) will forward transactions from a designated parachain to the [relay chain](https://wiki.polkadot.network/docs/en/learn-architecture#relay-chain) to benefit from _pooled security_. Each parachain slot on the relay chain will have a registered State Transition Function (STF) that validates the bundled transactions.

In this post I will demonstrate how to implement a custom parachain runtime versus an equivalent on layer two. To interact with the examples it will be helpful to open the official [Polkadot UI](https://polkadot.js.org/apps/) on a supported browser or run it locally:

```shell
docker run --rm -it --name polkadot-ui -p 80:80 chevdor/polkadot-ui:latest
```

## Substrate

The [template repository](https://github.com/substrate-developer-hub/substrate-node-template) is the main starting point for developing a custom runtime. Ensure that you have the required dependencies installed before continuing, namely [Rust](https://www.rust-lang.org/tools/install) and the [WebAssembly backend](https://github.com/rust-lang/rust/pull/46115#issuecomment-345727266).

```shell
git clone -b v2.0.0-alpha.3 --depth 1 https://github.com/substrate-developer-hub/substrate-node-template
cd substrate-node-template
```

In the `substrate-node-template` directory, create a new file `runtime/src/flip.rs` and copy the following source into it:

```rust
use frame_support::{
    decl_module, decl_storage,
    dispatch::{DispatchResult},
};

pub trait Trait: system::Trait {
}

decl_storage! {
    trait Store for Module<T: Trait> as flipper {
        pub Value get(value): bool;
    }
}

decl_module! {
    pub struct Module<T: Trait> for enum Call where origin: T::Origin {
        pub fn flip(_origin) -> DispatchResult {
            <Value>::put(!<Value>::get());
            Ok(())
        }
    }
}
```

Edit `runtime/src/lib.rs` to include our new runtime module as follows:

```rust
mod flip;

impl flip::Trait for Runtime {
}

construct_runtime!(
    pub enum Runtime where
        Block = Block,
        ...
    {
        ...
        Flip: flip::{Module, Call, Storage},
    }
);
```

We're ready to compile and run our first node runtime!

```shell
cargo build --release
./target/release/node-template --dev
```

Navigate to the `Extrinsics` tab in the sidebar of the UI and trigger `flip.flip()`, you should notice in the `Chain state` tab that `flip.value()` will change each time the aforementioned action is triggered.

## Ink

This section is an excerpt from the official tutorial [here](https://substrate.dev/substrate-contracts-workshop/#/) which you may find more useful. Otherwise run the following commands to download and compile the example contract:

```shell
cargo install cargo-contract --vers 0.6.0 --force
cargo contract new flipper
cd flipper
cargo +nightly test
cargo +nightly contract build
cargo +nightly contract generate-metadata
```

Unless using a custom node runtime with the [contracts](https://github.com/paritytech/substrate/tree/master/frame/contracts) pallet, it is possible to use the main substrate node runtime for smart contract development:

```shell
substrate --dev
```

Reload the UI and navigate to the `Contracts` tab in the sidebar. Click `Upload WASM` and specify `flipper.wasm` and `metadata.json` for the contract and ABI respectively. 

## Other

One of the core developers has a great post which describes how to [interact with the JSON RPC](https://www.shawntabrizi.com/substrate/querying-substrate-storage-via-rpc/). In short, if you call the following method over HTTP, your node should return a list of all the methods it supports:

```shell
curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "rpc_methods"}' http://localhost:9933/
```

## Glossary

### [Extrinsics](https://substrate.dev/docs/en/conceptual/node/extrinsics)

Anything that ingresses into the chain is an extrinsic, namely inherents (information inserted by a block producer), signed or unsigned transactions.

### [FRAME](https://substrate.dev/docs/en/conceptual/runtime/frame)

The Framework for Runtime Aggregation of Modularized Entities (FRAME) describes a set of modules, known as pallets, linked by support libraries.
Pallets are the domain specific dependencies of Substrate - crates that only work within the context of a node.






