+++
title = "Containerizing Bitcoin"
date = "2020-04-10"
author = "Gregory Hill"
tags = [
    "bitcoin",
    "docker",
]
+++

There are over 500,000 lines of code in Bitcoin Core, roughly 70% of which is pure C++. Compile times vary, but if you just want to get a node up and running, docker is the easiest way to go. Here's something I prepared [earlier](https://github.com/gregdhill/bitcoin-docker)...

Courtesy of the [official docs](https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md#to-build), there are only four commands to run which build `bitcoind`, `bitcoin-cli` and `bitcoin-qt`. The dependencies are clearly outlined for different architectures - including OSx, Windows and Unix flavours - but in my Dockerfile I have chosen to extend Ubuntu. Checkout the repository linked above to build the image yourself or use `gregdhill/bitcoin:latest`.

```yaml
version: '3'
services:
  node_1:
    image: gregdhill/bitcoin:latest
    network_mode: host
    ports:
      - "8333:8333"
    command: bitcoind -regtest -port=8333 -rpcport=18443 -rpcuser=admin -rpcpassword=admin
  node_2:
    image: gregdhill/bitcoin:latest
    network_mode: host
    ports:
      - "8334:8334"
    command: bitcoind -regtest -port=8334 -rpcport=18444 -rpcuser=admin -rpcpassword=admin -addnode=127.0.0.1:8333
    depends_on: 
    - node_1
  node_3:
    image: gregdhill/bitcoin:latest
    network_mode: host
    ports:
      - "8335:8335"
    command: bitcoind -regtest -port=8335 -rpcport=18445 -rpcuser=admin -rpcpassword=admin -addnode=127.0.0.1:8333
    depends_on: 
    - node_1
  node_4:
    image: gregdhill/bitcoin:latest
    network_mode: host
    ports:
      - "8336:8336"
    command: bitcoind -regtest -port=8336 -rpcport=18446 -rpcuser=admin -rpcpassword=admin -addnode=127.0.0.1:8333
    depends_on: 
    - node_1
```

Save the source above as `docker-compose.yaml` and run `docker-compose up` to start a local four node network running in [regression test mode](https://bitcoin.org/en/glossary/regression-test-mode). With this, it is possible to generate new blocks instantaneously through the JSON RPC. We can utilise `bitcoin-cli` from the same docker image to create an arbitrary number of transactions:

```shell
address=$(docker run --network="host" gregdhill/bitcoin:latest bitcoin-cli -rpcpassword=admin -rpcuser=admin -regtest getnewaddress)
docker run --network="host" gregdhill/bitcoin:latest bitcoin-cli -rpcpassword=admin -rpcuser=admin -regtest generatetoaddress 100 "${address}"
```

If we query the same RPC manually, we can observe the latest block height via `getmininginfo`:

```shell
curl --user admin:admin -H 'content-type:text/plain;' --data-binary '{"id":"1", "jsonrpc":"1.0", "method": "getmininginfo", "params":[]}'  http://localhost:18443
```

Alternatively we can verify that the node has four peers total (including itself) using the `getpeerinfo` method.

For a full list of methods, [checkout the wiki](https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_calls_list).
