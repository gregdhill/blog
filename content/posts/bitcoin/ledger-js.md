+++
title = "LedgerJS"
date = "2020-07-25"
author = "Gregory Hill"
tags = [
    "bitcoin",
    "typescript",
]
+++

A hardware wallet is a specialized physical device used to store (and [derive](https://en.bitcoin.it/wiki/Deterministic_wallet)) your private keys.
Some of the most popular products are developed by [Ledger](https://www.ledger.com/) and you may be familiar with the Nano series. They support developing 
custom applications in C (for now, but Rust [is coming](https://github.com/LedgerHQ/rust-app-demo)) and the active library is well stocked, both
[Bitcoin](https://github.com/LedgerHQ/app-bitcoin) and [Ethereum](https://github.com/LedgerHQ/app-ethereum) have dedicated applications. To build on top of 
these we need to speak through the application protocol data unit (APDU) - for which Bitcoin has a [technical specification](https://blog.ledger.com/btchip-doc/bitcoin-technical-beta.html).
There are also some high-level libraries that simplify this task and in this post I will give an example of how we can use the JS/TS API to read your public keys
and sign a Bitcoin transaction.

## Installation

We will assume that the following script is interpreted through the node runtime, but it is also possible to port this to
client-side JS using one of the [supported transports](https://github.com/LedgerHQ/ledgerjs#ledgerhqhw-transport-).

```bash
yarn add @ledgerhq/@ledgerhq/hw-transport-node-hid
yarn add @ledgerhq/hw-app-btc
```

We need a few helper libraries in order to generate the output script later:

```bash
yarn add bitcoinjs-lib
yarn add bigint-buffer
```

## Getting Started

Let's create our script as `index.ts`:

```typescript
import Transport from '@ledgerhq/@ledgerhq/hw-transport-node-hid';
import AppBtc from "@ledgerhq/hw-app-btc";
import * as bitcoin from 'bitcoinjs-lib';
import {toBufferLE} from 'bigint-buffer';

const OPEN_TIMEOUT = 10000;
const LISTENER_TIMEOUT = 30000;

async function main() {
    const transport = await Transport.create(OPEN_TIMEOUT, LISTENER_TIMEOUT);
    const app = new AppBtc(transport);

    const publicKey = await app.getWalletPublicKey("84'/0'/0'/0/0", {format: "bech32"});
    console.log(publicKey.bitcoinAddress);
}

main();
```

Before running this script (using [ts-node](https://github.com/TypeStrong/ts-node)) make sure your device 
is connected via USB and the Bitcoin app is open. Unless you have disabled the verification check in the 
settings your device may ask for permission to export the public key for this derivation path.

The console should print a [Bech32](https://en.bitcoin.it/wiki/Bech32) formatted [SegWit](https://en.bitcoin.it/wiki/Segregated_Witness)
address like this:

```bash
bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq
```

For more details on derivation paths or HD wallets in general;

- [BIP-32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) - Hierarchical Deterministic (HD) Wallets
- [BIP-39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) - Mnemonics
- [BIP-44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) - Multi-Account Hierarchy

## Signing a Transaction

Please make sure you are familiar with the concept of unspent transaction outputs (UTXO).
Unlike in account based architectures (such as Ethereum) balances are calculated differently.
Your wallet should instead 'watch' for transactions that spend to your address and sum the amount.
To spend a particular output you need to prove that you are the owner of that address by providing 
a signature that links your public key.

Before we can sign a new transaction we first need a valid UTXO. If you are running a 
[full-node](https://bitcoin.org/en/full-node) we can fetch the hex using the RPC API:

```bash
bitcoin-cli getrawtransaction "mytxid" false "myblockhash"
```

The [Blockstream Esplora](https://github.com/Blockstream/esplora) API is also particularly useful 
so I published a [client library](https://github.com/interlay/esplora-btc-api) in Typescript. 

For now we can copy this into the `utxoHex` variable below. Also note that we should adjust the `txIndex`
to unlock the correct output (there may be multiple).

```typescript
const utxoHex = "*****";
const txIndex = 0;
const inTx = app.splitTransaction(utxoHex, true, false);
```

Finally, let's construct and sign our new transaction to pay `100` satoshis to the `recipient`:

```typescript
const amount = 100;
const recipient = "*****";
const payment = bitcoin.payments.p2wpkh({ address: recipient });
const outputScriptHex = app.serializeTransactionOutputs({
    version: Buffer.from("01000000", 'hex'),
    inputs: [],
    outputs: [{
        amount: toBufferLE(BigInt(amount), 8),
        script: payment.output!,
    }]
}).toString('hex');

const result = await app.createPaymentTransactionNew({
    inputs: [[inTx, txIndex, undefined, undefined]],
    associatedKeysets: [ "84'/0'/0'/0/0" ],
    outputScriptHex,
    segwit: true,
    sigHashType: 1,
    additionals: ["bitcoin", "bech32"],
});
const tx = bitcoin.Transaction.fromHex(result);
console.log(tx.toHex());
```

If you accepted the prompts on your device the console should display the signed 
transaction hex. We can now broadcast this through an RPC or REST API.