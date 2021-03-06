+++
title = "ENS & IPFS"
date = "2020-04-11"
author = "Gregory Hill"
tags = [
    "ethereum",
    "ipfs",
]
+++

By utilizing the [Ethereum Name Service (ENS)](https://ens.domains/) for resolution and the Interplanetary File System (IPFS) for content hosting it is possible to decentralize a static website while retaining the predictable URL.

My primary setup leverages GitHub pages to host a blog compiled with [Hugo](https://gohugo.io/) - linked to my [domain name](https://greghill.io/). Whenever I want to publish a change, I build the latest website from my markdown content using my [custom theme](https://github.com/gregdhill/nonagon) and push it to a separate branch in my [personal repository](https://github.com/gregdhill/blog).

The process of publishing to IPFS is slightly different, first you must have access to a node which can retain the website bundle - ideally pinned to a persistent node you control, but once the content is disseminated this is not _strictly_ required. See the [official docs](https://docs.ipfs.io/introduction/usage/) to get started, once you are setup we can run a local node daemon (`ipfs daemon`) and push the target directory (`ipfs add -r public`) generated by `hugo`. The final content identifier of the directory is all that is required to load the website through an IPFS gateway - `https://gateway.ipfs.io/ipfs/<CID>`. After registering a custom name with ENS, the final step is to add a content record which links to this CID. The resolver will then interpret subsequent HTTP requests through a web3 compatible extension and redirect to an IPFS gateway. 

Navigate to [gregdhill.eth](https://gregdhill.eth) to see this blog on the dweb!