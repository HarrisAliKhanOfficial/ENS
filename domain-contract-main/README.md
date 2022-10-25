# Contracts

This is a fork of [ens contracts](https://github.com/ensdomains/ens-contracts).

For documentation of the ENS system, see [docs.ens.domains](https://docs.ens.domains/).

## Contracts

### Main Contracts

- ENSRegistry
- PublicResolver
- ReverseRegistrar
- Root
- UniversalRegistrar
- NameStore
- SLDPriceOracle
- UniversalRegistrarController
- UniversalRootController

## Developer guide

### Deployment

Update `hardhat.config.js` with your Infura API Key and Deployment account private key.

Specify the `--network` option like goerli, mainnet, hardhat or localhost.

```
yarn deploy <network_here>
```

Finalize deployment.

```
yarn finalize <network_here>
```

Submit contract code to verify with etherscan (optional)

```
yarn verify <etherscan_api_key_here>
```

Note: Deployed contract info are stored in `deployments` directory, running deploy again will reuse any contracts that were deployed previously.
