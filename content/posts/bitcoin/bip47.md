+++
title = "BIP47: TL;DR"
date = "2020-12-05"
author = "Gregory Hill"
tags = [
    "bitcoin",
]
summary = "Reusable payment codes simplify identity management without loss of privacy."
+++

**[BIP-0047](https://github.com/bitcoin/bips/blob/master/bip-0047.mediawiki)**

**Payment Code**: {version}{features}{bitmessage}{public_key}{chain-code}{reserved}

## Version 1

### Setup

- Alice derives Bob's notification address from his payment code (see [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki))
- Alice computes payment code using a shared secret (Alice's private key and Bob's public key)
- Alice sends notification tx to Bob with payment code in `OP_RETURN` data
- Bob watches for transactions to his notification address
- Bob decodes Alice's payment code using the shared secret

> To anonymize payments, Alice may use an ephemeral payment code which is a hardened child of her original payment code.

### Transfer

- Alice derives 0th private key from her payment code
- Alice derives next unused public key from Bob's payment code (local counter)
- Alice computes shared secret, calculates Bob's ephemeral public key and generates P2PKH address
- Bob computes `n` ephemeral addresses and watches for transactions

Note that in this scheme (ECDH) it is computationally infeasible for a third party to correlate Alice's payments to Bob.

### Refund

- Bob derives Alice's notification address from her payment code
- Bob sends notification tx to Alice with payment code in `OP_RETURN` data

- Bob derives 0th private key from his payment code
- Bob derives next unused public key from Alice's payment code (local counter)
- Bob computes shared secret, calculates Alice's ephemeral public key and generates P2PKH address
- Alice computes `n` ephemeral addresses and watches for transactions

## Version 2

Identical to the process above, with one exception. Bob's notification _change_ address is calculated as a multisig:

- BOB_PAYMENT_CODE_ID: payment code identifier; `0x02${sha256(bob_payment_code).toString("hex")}`
- ALICE_CHANGE_PUBKEY: notification change output; public key for Alice's change address in tx

```
OP_1 <BOB_PAYMENT_CODE_ID> <ALICE_CHANGE_PUBKEY> OP_2 OP_CHECKMULTISIG
```

Bob should add his payment code identifier to his bloom filter to detect notification transactions.
