+++
title = "Online Key Management"
date = "2020-12-31"
author = "Gregory Hill"
summary = "I was recently looking into key management for the BTC-Parachain and associated client software. Like similar software - namely Proof-of-Stake (PoS) validators or arbitrage keepers - they are designed to run autonomously 24/7 with unrestricted access to private keys for signing. In my effort to understand best-practices I decided to compare approaches across the industry."
+++

I was recently looking into key management for the [BTC-Parachain](https://gitlab.com/interlay/btc-parachain) and associated client software. Like similar software - namely Proof-of-Stake (PoS) validators or arbitrage keepers - they are designed to run autonomously 24/7 with unrestricted access to private keys for signing. In my effort to understand best-practices I decided to compare approaches across the industry.

### Bitcoin

There are a number of standards that contribute to secure key management in Bitcoin and related technologies such as Ethereum. The first, known as [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki), formalizes Hierarchical Deterministic Wallets; derivation of a tree of key-pairs from a master seed. Another, [BIP38](https://github.com/bitcoin/bips/blob/master/bip-0038.mediawiki), focuses on passphrase protection; both to encrypt pre-existing and generate pre-encrypted keys. Lastly, [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki), extends BIP32 with a strategy to generate the master seed from a mnemonic phrase. Multisignatures can also be used to improve security by physically separating the private keys required to spend from a wallet. For example, "m-of-n" style addresses allow "m" signatures to unlock a payment designated to "n" participants.

Proof-of-Work (PoW) mining software has no need for key management since only an address is needed to generate the special coinbase transaction to mint coins. When using software such as [CGMiner](https://github.com/ckolivas/cgminer) or [BFGMiner](https://github.com/luke-jr/bfgminer) this is typically a configuration detail - mining pools will likely surface joint payout through registration. [Bitcoin Core](https://bitcoin.org/en/bitcoin-core/) itself has an integrated wallet which can be encrypted at rest. Upon starting the software, it may prompt the user for a password which decrypts the master key into memory using AES-256-CBC. 

### Ethereum

The [Web3 Secret Storage Definition](https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition) defines the structure and encryption of JSON based private key files as used in Ethereum 1. A supplemental improvement proposal ([EIP-2335](https://eips.ethereum.org/EIPS/eip-2335)) generalizes the structure for use within Ethereum 2 and beyond.

Go-Ethereum (geth) supports [password encryption](https://geth.ethereum.org/docs/dapp/native-accounts), signing can be authorized per request or the account manager can hold the decrypted private key in-memory for a certain period of time. The manager can also be configured to delegate signing to a remote service over a secure connection. Additionally, [native hardware support](https://github.com/ethereum/go-ethereum/tree/master/accounts/usbwallet) allows users to directly sign transactions via [Ledger](https://www.ledger.com/) or [Trezor](https://trezor.io/) devices. Two of the most popular Eth2 clients ([Lighthouse](https://github.com/sigp/lighthouse) and [Prysm](https://github.com/prysmaticlabs/prysm)) also support key-store encryption and external signing.

Web3Signer is an open-source signing service developed by [ConsenSys](https://consensys.net/) which exposes endpoints for clients to securely sign transactions. Locally it can use raw (unencrypted) files, key-store (encrypted) files, [HashiCorp Vault](https://www.hashicorp.com/products/vault), [Azure Key Store](https://azure.microsoft.com/en-au/services/key-vault/), [YubiHSM2](https://developers.yubico.com/YubiHSM2/) or the [USB Armory Mk 2](https://www.f-secure.com/en/consulting/foundry/usb-armory). There is also support for [Filecoin](https://filecoin.io/)'s Lotus client.

A number of decentralized applications require external participants to contribute to the liveness of the system. For instance, [Maker](https://makerdao.com/en/) has a number of incentivized roles for market making, auctioning and arbitrage. The [simple-arbitrage-keeper](https://docs.makerdao.com/keepers/simple-arbitrage-keeper) toolkit uses [seth](https://github.com/dapphub/dapptools/tree/master/src/seth) to sign transactions which can load key-store wallet files or auto-sign via [Ledger](https://shop.ledger.com/products/ledger-nano-s). Another popular market making client [Hummingbot](https://hummingbot.io/) also uses [encrypted key-file wallets](https://docs.hummingbot.io/operation/adv-command-ref/#setup-ethereum-wallet) to interact with various decentralized exchanges.

### Tendermint

Validators in [Cosmos](https://cosmos.network/) only require one private key to participate in consensus. [Tendermint](https://tendermint.com/) supports an integrated Key Management System (KMS) developed by the staking provider [Iqlusion](https://www.iqlusion.io/). The toolkit has both [Ledger](https://www.ledger.com/) and [YubiHSM](https://www.yubico.com/products/hardware-security-module/) support, but can also sign using in-memory keys.

### Substrate

Validators in [Polkadot](https://polkadot.network/) require three sets of keys: the controller key is semi-online and should hold a small amount of funds, used to start and stop validating; the stash key is almost entirely offline but should hold the majority of funds, this balance is used as stake for the controller; the session key is always online and is used to sign consensus related messages. There are currently no additional protection mechanisms, but [Substrate](https://substrate.dev/) does enable automatic key rotation.

## Conclusion

Secure key management is difficult to get right and many projects simply defer to the end-user. In an enterprise system there are many additional risk factors which need to be accounted for such as joint access. In such situations it is important to create a policy that identifies recourse should the system be compromised.

**Encryption at rest** is perhaps the most important recommendation to consider when storing keys locally. Without the passphrase, an attacker with physical access to the hard drive should not be able to recover the signing keys. Other important architectural considerations are **key-rotation** to limit the fallout of improper key handling and **multi-party** schemes to limit the exposure of online keys - i.e. using offline keys backed onto external mediums to hold funds and revoke online keys. 

Specialized hardware can be used to generate, sign and manage digital keys. Facilitated access can can limit the exposure of keys and alleviate responsibility. **Hardware Wallets (HW)** derive a master seed for hierarchical key generation based on a mnemonic phase. Further interactions with compatible software are typically guarded by a manual approval process. The threat model here assumes that the software is untrusted. **Hardware Security Modules (HSM)** also allow software to delegate signing operations but are commonly designed with access management in mind.

### [Ledger](https://www.ledger.com/)

There are a few different models, but each device uses the same Blockchain Open Ledger Operating System (BOLOS) and app development toolkit. The marketplace ([Ledger Live](https://www.ledger.com/ledger-live)) hosts many popular applications for various cryptocurrencies - including [Bitcoin](https://github.com/LedgerHQ/app-bitcoin) and [Ethereum](https://github.com/LedgerHQ/app-ethereum). As discussed above, Tendermint even has a custom application which supports autonomous signing for PoS validators. Many of the other (user-oriented) applications do not support similar *autonomous* operations, however it is possible to fork them and load the custom build onto the firmware.

### [Trezor](https://trezor.io/)

Designed by [SatoshiLabs](https://satoshilabs.com/), Trezor's application architecture differs from that of its competitor. Recognized coins, tokens and FIDO/U2F apps are described in the [core firmware](https://github.com/trezor/trezor-firmware), limited only by the [cryptographic library](https://github.com/trezor/trezor-firmware/tree/master/crypto). There is no apparent ability to disable tx verification for autonomous signing which may make this device difficult to use for enterprise systems.

On a related note, a recent innovation based on [Shamir's secrets](https://wiki.trezor.io/Shamir_Backup) ([SLIP-0039](https://github.com/satoshilabs/slips/blob/master/slip-0039.md)) provides a safe way to split the master seed into multiple shares such that a minimum number of parts can recover the original secret.

### [YubiHSM](https://www.yubico.com/products/hardware-security-module/)

The latest version of this tamper resistant device has extensive cryptographic support. Supporting up to sixteen concurrent connections, the device can even be shared by multiple networked servers. The [open-source SDK](https://github.com/Yubico/yubihsm-shell) has already been integrated with a number of popular projects such as Cosmos.

### Cloud

Depending on the service provider, it may also be possible to use a hosted key management solution:

- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
- [Cloud KMS](https://cloud.google.com/kms/)
- [Azure Key Vault](https://github.com/Azure/secrets-store-csi-driver-provider-azure)

An open-source alternative is [HashiCorp Vault](https://github.com/hashicorp/vault) which can generate secrets on-demand for integrated services. Associated clients can then lease or renew these secrets for a period of time, subject to revocation.

On [Kubernetes](https://kubernetes.io/) it is possible to [encrypt secret data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/). Third-party tools such as [SealedSecrets](https://github.com/bitnami-labs/sealed-secrets) even enable encrypted keys to be committed to a public git repository.