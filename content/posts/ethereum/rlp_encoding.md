+++
title = "Recursive Linear Prefix (RLP) Encoding"
date = "2019-09-15"
author = "Gregory Hill"
+++

I was recently tasked with developing a new encoding library for [Hyperledger Burrow](https://github.com/hyperledger/burrow)
to further interoperability with the broader Ethereum ecosystem. Recursive Linear Prefix (RLP) is a data format used to store
state in Ethereum, more precisely it is an algorithm for representing arbitrary data structures in binary form. 
Unlike other serialization techniques however, the output is position dependant in that recovering the original object 
requires knowledge of the input structure.

## History

The first mention of RLP encoding was in the Ethereum [yellow paper](https://ethereum.github.io/yellowpaper/paper.pdf)
which logically defines the encoding procedure adopted by [Vitalik](https://vitalik.ca/). It's not entirely clear why this 
method was chosen, but it is likely to have been devised for space efficiency. To quote the [design rationale](https://github.com/ethereum/wiki/wiki/Design-Rationale#rlp):

> RLP is intended to be a highly minimalistic serialization format; its sole purpose is to store nested arrays of bytes. Unlike protobuf, BSON and other existing solutions, RLP does not attempt to define any specific data types such as booleans, floats, doubles or even integers; instead, it simply exists to store structure, in the form of nested arrays, and leaves it up to the protocol to determine the meaning of the arrays.

Simply put, this means that we can not always expect the input of our decode function to conform to our target representation.

## Internals

As described on the [wiki](https://github.com/ethereum/wiki/wiki/RLP), the input to the encoding function is an 'item'
which may be a string (byte array) or a list of items. This is evaluated against the following set of conditions in which
a list is recursively solved for nested strings.

| Prefix | Condition           |
| ------ | ------------------- |
| -      | [0x00, 0x7f]        | 
| 0x80   | string - 0-55 bytes |
| 0xb7   | string - > 55 bytes |
| 0xc0   | list - 0-55 bytes   |
| 0xf7   | list - > 55 bytes   |

> The length of each item is also added to its prefix.

## Examples

Guided by the above rule set, we can begin to encode / decode some example items. Let's assume we pass the **string** 
`foo bar` to our encoding function. After evaluating the length (including whitespace) as `7`, which is distinctly 
less that `55` bytes, we should add the byte with value `0x80` to the length to give us our prefix `0x87`. We can then
append the raw bytes of our input string.

```
   f  o  o     b  a  r
87 66 6f 6f 20 62 61 72
```

To decode this, our function should first check the prefix. As the value is between `[0x80,0xb7)` we can subtract `0x80` 
to get the length and return the string at offset `1:8`.

Given the **list** `[foo, bar]`, we'll start the encoding by taking the item's length plus the byte value `0xc0`. We can
then linearly append each string following the process above; each word is of length `3`, so the prefix is the value `0x83`.

```
[]    {f o  o}    {b a  r}
c8 83 66 6f 6f 83 62 61 72
```

Let's follow this procedure in reverse to decode the output. The first prefix is between `[0xc0,0xf7)` so we know to construct
a list object, but at this point it is still unclear what the sub-items may be - we could have arbitrary lists or strings.
Therefore the simplest approach is to enumerate over the remaining bytes, taking the next prefix (`0x83`) we can extract the
first string, leaving us with 4 bytes (including prefix) as specified by the outer prefix. So our recursive function should
know to continue decoding our second string.