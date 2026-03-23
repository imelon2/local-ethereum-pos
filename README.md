# Local Ethereum PoS

A local Ethereum Proof-of-Stake development environment using Docker Compose.

Runs a fully functional PoS network locally with Geth as the execution client and Prysm as the consensus client. Useful for smart contract development, transaction testing, and blockchain experimentation without connecting to public testnets.

## Selecting a Fork Version

Use `make` with the fork name to run a network configured for that fork:

```bash
make dencun        # run Dencun (Deneb + Cancun) fork
make pectra        # run Pectra (Prague + Electra) fork
make fusaka        # run Fusaka (Fulu + Osaka) fork
```

## Components

### Fusaka
| Service | Image | Description |
|---------|-------|-------------|
| **Geth** | `ethereum/client-go:v1.16.7` | Execution Layer client |
| **Prysm CLI Tool** | `prysm/prysmctl:v7.1.3` | Prysm CLI Tool |
| **Prysm Beacon Chain** | `prysm/beacon-chain:v7.1.3` | Consensus Layer client |
| **Prysm Validator** | `prysm/validator:v7.1.3` | Validator node (64 interop validators) |

### Pectra
| Service | Image | Description |
|---------|-------|-------------|
| **Geth** | `ethereum/client-go:v1.15.11` | Execution Layer client |
| **Prysm CLI Tool** | `prysm/prysmctl:v6.0.0` | Prysm CLI Tool |
| **Prysm Beacon Chain** | `prysm/beacon-chain:v6.0.0` | Consensus Layer client |
| **Prysm Validator** | `prysm/validator:v6.0.0` | Validator node (64 interop validators) |

### Dencun
| Service | Image | Description |
|---------|-------|-------------|
| **Geth** | `ethereum/client-go:v1.14.13` | Execution Layer client |
| **Prysm CLI Tool** | `prysm/prysmctl:v5.0.4` | Prysm CLI Tool |
| **Prysm Beacon Chain** | `prysm/beacon-chain:v5.0.4` | Consensus Layer client |
| **Prysm Validator** | `prysm/validator:v5.0.4` | Validator node (64 interop validators) |


## Network Configuration

- Chain ID: `1337`
- Slot interval: 6 seconds
- Slots per epoch: 12

## Ports

Ports are configurable via the root `.env` file. Default values:

| Variable | Default | Description |
|----------|---------|-------------|
| `RPC_PORT` | `8545` | Geth HTTP RPC |
| `WS_PORT` | `8546` | Geth WebSocket |
| `AUTH_RPC_PORT` | `8551` | Geth Auth RPC |
| `BEACON_RPC_PORT` | `4000` | Beacon Chain RPC |
| `BEACON_GRPC_GATEWAY_PORT` | `3500` | Beacon Chain gRPC Gateway |

All forks share the same port variables from the root `.env` file.

## Usage

### Run

```bash
make dencun        # run Dencun fork
make pectra        # run Pectra fork
make fusaka        # run Fusaka fork
```

### Stop

```bash
make dencun/down
make pectra/down
make fusaka/down
```

### Force restart (with DB reset)

```bash
make dencun/force
make pectra/force
make fusaka/force
```

### Clean DB

```bash
./launcher.sh clean                    # clean default
./launcher.sh clean --version fusaka   # clean fusaka
./launcher.sh clean --version pectra   # clean pectra
./launcher.sh clean --version dencun   # clean dencun
```

## Troubleshooting

### Transaction stuck in mempool

On a local network, the `baseFeePerGas` drops extremely low over time due to empty blocks. However, Geth's miner requires a minimum priority fee of `1000000` (1 Mwei) to include a transaction in a block.

In EIP-1559, the effective priority fee is calculated as:

```
effectiveTip = min(maxPriorityFeePerGas, maxFeePerGas - baseFeePerGas)
```

Even if `--priority-gas-price` (maxPriorityFeePerGas) is set high enough, the transaction will still be stuck if `maxFeePerGas - baseFeePerGas` is below `1000000`. Since `baseFeePerGas` is near zero on a local network, `--gas-price` (maxFeePerGas) must also be at least `1000000` higher than the current `baseFeePerGas`.

To resolve this, explicitly set both `--priority-gas-price` and `--gas-price`:

```bash
cast send <to> \
  -r http://127.0.0.1:8545 \
  --value 0.1ether \
  --private-key <private_key> \
  --priority-gas-price 1000000 \
  --gas-price 1000008

# OR Set Export
export ETH_PRIORITY_GAS_PRICE=100000
export ETH_GAS_PRICE=1000008
```

### Fusaka: Validator `DeadlineExceeded` errors

When running `make fusaka/force`, the validator node may produce repeated errors:

```
ERROR client: Could not request attestation to sign at slot
  error=rpc error: code = DeadlineExceeded desc = context deadline exceeded
ERROR client: Could not submit sync committee message
  error=rpc error: code = DeadlineExceeded desc = context deadline exceeded
```

**Cause:** The Fusaka fork uses the [OffchainLabs fork of Prysm](https://github.com/OffchainLabs/prysm) (`prysmctl:v7.1.3`) instead of the official `prysmaticlabs/prysm`. Starting from this fork, `prysmctl testnet generate-genesis` [uses the genesis.json timestamp directly](https://github.com/OffchainLabs/prysm/blob/9ea9e1f07cca61ae5854a32a3da76ffed484db77/CHANGELOG.md?plain=1#L104) instead of overwriting it with the current time (as the official Prysm versions do for Dencun/Pectra).

If `genesis.json` contains a stale timestamp, the beacon chain starts at slot 0 but the current time maps to a much higher slot number (e.g., 21000+). The beacon node cannot process thousands of empty slots within the gRPC deadline, causing the timeout errors.

**Solution:** The `make fusaka/force` target automatically updates `genesis.json` timestamps to the current time + 5 seconds before starting the network. If you still encounter this issue, manually verify the timestamps:

```bash
grep -E '"(shanghaiTime|cancunTime|pragueTime|osakaTime|timestamp)"' ./fusaka/config/genesis.json
# All fork times should be close to: $(date +%s)
```
