+++
title = "Proof of Work (Explained)"
date = "2019-12-22"
author = "Gregory Hill"
tags = [
    "bitcoin",
    "c++",
]
+++

So you've read the theory, but want to understand Bitcoin programmatically. In this post we will analyse the 
core codebase written in C++ to understand how one can generate and include a block in the chain. Starting with 
the atomic unit of construction in this context, a block is a grouping of transactions that alter the state of 
the ledger. For example, a `coinbase` transaction may be included by a miner to collect a block reward. But in 
order for these to be processed by the network, a miner must provide a proof of work for the serialization of 
the following fields:

- `nVersion`
- `hashPrevBlock`
- `hashMerkleRoot`
- `nTime`
- `nBits`
- `nNonce`

The class definition of a block header is shown in the following snippet, of particular interest is `SerializationOp`
which tells the compiler how an instance of this class should be serialized and `GetHash` which returns a 256-bit
unsigned integer.

<!-- https://github.com/bitcoin/bitcoin/blob/5622d8f3156a293e61d0964c33d4b21d8c9fd5e0/src/primitives/block.h#L20-L69 -->
<script charset="UTF-8" src="https://gist-it.appspot.com/github.com/bitcoin/bitcoin/blob/5622d8f3156a293e61d0964c33d4b21d8c9fd5e0/src/primitives/block.h?slice=19:69&footer=minimal"></script>

The implementation of `GetHash` calls another function `SerializeHash` passing a dereferenced pointer to its context.

<script charset="UTF-8" src="https://gist-it.appspot.com/github.com/bitcoin/bitcoin/blob/5622d8f3156a293e61d0964c33d4b21d8c9fd5e0/src/primitives/block.cpp?slice=9:15&footer=minimal"></script>

From here, `CHashWriter` is established which computes the digest via the `CHash256` class.

<script charset="UTF-8" src="https://gist-it.appspot.com/github.com/bitcoin/bitcoin/blob/5622d8f3156a293e61d0964c33d4b21d8c9fd5e0/src/hash.h?slice=115:140&footer=minimal"></script>

We can see that `Finalize` writes and flushes the hash to the input buffer. It is important to note that
this actually computes `SHA-256d` (double) in an effort to prevent "length-extension" attacks.

<script charset="UTF-8" src="https://gist-it.appspot.com/github.com/bitcoin/bitcoin/blob/5622d8f3156a293e61d0964c33d4b21d8c9fd5e0/src/hash.h?slice=20:43&footer=minimal"></script>

Assuming this process has given us a valid digest of our input, how can we convince other participants to
append our block to their view of the chain? This is where the consensus parameter `bnTarget` comes in. 
For brevity, we will ignore how this is chosen but I will note that this is dynamic - the network adapts it
based on mining speeds. Honest nodes will thus accept a gossiped block under the condition that the arithmetical
representation of its hash is less that that of the current target. 

<!-- https://github.com/bitcoin/bitcoin/blob/5622d8f3156a293e61d0964c33d4b21d8c9fd5e0/src/pow.cpp#L74-L91 -->
<script charset="UTF-8" src="https://gist-it.appspot.com/github.com/bitcoin/bitcoin/blob/5622d8f3156a293e61d0964c33d4b21d8c9fd5e0/src/pow.cpp?slice=73:91&footer=minimal"></script>

To recompute a new hash, we need some variability in the form of `nNonce`. As there is no way to predict what input will lead to
a desired hash, all we can do is increment it. There's a useful example of this in the following test helper.

<!-- https://github.com/bitcoin/bitcoin/blob/5622d8f3156a293e61d0964c33d4b21d8c9fd5e0/src/test/util.cpp#L61-L64 -->
<script charset="UTF-8" src="https://gist-it.appspot.com/github.com/bitcoin/bitcoin/blob/5622d8f3156a293e61d0964c33d4b21d8c9fd5e0/src/test/util.cpp?slice=60:64&footer=minimal"></script>

Providing the final hash meets the criteria and enough nodes know about it, subsequent miners will include it as
`hashPrevBlock` in their constructions.

