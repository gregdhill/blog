+++
title = "Hyperledger Global Forum (2020)"
date = "2020-03-25"
author = "Gregory Hill"
tags = [
    "travel",
    "conferences",
]
+++

Since I am on lock-down due to the ongoing coronavirus pandemic I decided this would be a good time to write up some notes from my recent visit to Phoenix, Arizona. The conference lasted around four days, though I had some buffer around this for travel - with time to visit the local desert botanical gardens! Fortunately, it was still well attended despite the obvious health concerns but the Linux Foundation made every effort to accommodate guests. The first two days were designated for talks and demonstrations, 'ending' with a visit to the ironically named Corona ranch for dinner and drinks. The last two days were exclusively for technical workshops, with representation from most projects in the greenhouse.

## Workshops

The primary motivation for my attendance was to present a workshop on [Hyperledger Burrow](https://github.com/hyperledger/burrow) for smart contract developers. It was split into two segments over one afternoon, with one particular theme: tokens. After starting a single node chain with Ed25519 & Secp125k1 keys, we guided participants through using truffle and the web3 interface from Javascript. The example here was ERC-20, the technical standard for fungible tokens - inheriting the interface defined by [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts). This was followed by a delve into ERC-721 (the non-fungible token standard) using Burrow's native GRPC client through Typescript. 

Once participants were familiar with talking to their node, we decided to start talking to each other! Each node first connected to my chain on the local network, I then asked everyone to post their would-be validator address in [Rocket.Chat](https://chat.hyperledger.org/channel/burrow). After sending each participant some funds, they then bonded onto the network to help produce blocks. Although we were not able to continue, I had also setup one more experiment: [CryptoMarmots](https://github.com/gregdhill/cryptomarmots). If you are familiar with [CryptoKitties](https://www.cryptokitties.co/) on Ethereum, then you may see where I am going with this. From the shared chain, the intent was for users to buy, sell and trade tokens corresponding to a virtual marmot.

If you are interested in running through these exercises yourself, please find the course content [here](https://github.com/gregdhill/hyperledger-global-forum-2020).

Given my schedule, I was only able to attend a few other workshops. The first was on [Hyperledger Avalon](https://github.com/hyperledger/avalon), on ways to enable trusted computation via Intel SGx. I was not overly impressed with the presentation or setup of this workshop as it was far too complex for the length of session. However, I do see potential with this project and I would like to see it thrive, particularly if it can also [support Burrow](https://github.com/hyperledger/avalon/issues/306). The other workshop I attended was on [Hyperleger Besu](https://github.com/hyperledger/besu), and despite the lengthy synchronization time of the Görli testnet, I was especially impressed with the framework.

## Keynotes and Talks

As an enterprise driven ecosystem, the organizers did an excellent job of dividing the business and technical tracks. The keynotes were still largely use-case focused, as evident during the panel on the first day which discussed several projects; Walmart has driven a food traceability effort, Honeywell started a marketplace for used aircraft parts, and American Express begun a rewards system.
