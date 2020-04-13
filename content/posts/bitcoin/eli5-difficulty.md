+++
title = "ELI5: Bitcoin Difficulty"
date = "2020-04-13"
author = "Gregory Hill"
tags = [
    "bitcoin",
]
+++

In Bitcoin, difficulty is the measure of how hard it is to mine a block. To ensure constant output, this rate is adjusted every 2016 blocks - anticipating block production to take around ten minutes, we can expect recalculation every two weeks. If more blocks are produced than expected then the difficulty is increased, otherwise it is lowered. 

The following formulae can be used to calculate the difficulty rate for any given height - substituting an expected average of 600 seconds (10 minutes) and a base difficulty (introduced at genesis) of `1.0`.

```
expected / actual = rate
currentDifficulty * rate = newDifficulty
```

If we look at a historical view of difficulty adjustments [on mainnet](https://btc.com/stats/diff) the first recalculation was at height `32,256` with an average block production time of 508 seconds. We can estimate the first difficulty as follows:

```
600 / 508 = 1.18
1 * 1.18 = 1.18
```

The subsequent adjustment is expected at height `32,256 + 2016 = 34,272`. Taking the new average production rate of 544 seconds we can calculate the following difficulty:

```
600 / 544 = 1.1
1.18 * 1.1 = 1.298
```

Despite some loss in precision, we can see these figures are roughly accurate.

## Target Threshold

From the [Bitcoin Technical Glossary](https://bitcoin.org/en/glossary/nbits):

> The target is the threshold below which a block header hash must be in order for the block to be valid, and nBits is the encoded form of the target threshold as it appears in the block header.

As you may have seen in my [previous post](../pow_explained), a [Bitcoin Block Header](https://bitcoin.org/en/developer-reference#block-headers) contains a field `nBits` which is a 32-bit compact encoding which correlates to the 256-bit target threshold. The miner increments `nNonce` to compute the header's hash, aiming to find a representation that is less than or equal to the target. The calculation is then taken as follows, where the maximum target is roughly `2^224`:

```
targetMax / difficulty = target
```

Using block `32,256` again as an example, we can see that `nBits` are registered as `0x1d00d86a`. To analyze how this works, let's derive the target threshold first. In [difficulty encoding](https://en.bitcoin.it/wiki/Difficulty) we take note of two components, the first byte is the exponent (`0x1d`) and remaining three bytes form the mantissa (`0x00d86a`).

```
mantissa * 2**(8*(exponent - 3)) = target
0x00d86a * 2**(8*(0x1d - 3))
= 22791060871177364286867400663010583169263383106957897897309909286912
```

If we convert the block hash to an integer we can compare it to the threshold:

```
0x000000004f2886a170adb7204cb0c7a824217dd24d11a74423d564c4e0904967
= 8336342430463410544411468431803888761223874031130229104713497856359
```

As you can see this is clearly less than the target so is a valid entry.