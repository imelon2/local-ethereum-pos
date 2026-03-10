# Local Ethereum PoS

A local Ethereum Proof-of-Stake development environment using Docker Compose.

Runs a fully functional PoS network locally with Geth as the execution client and Prysm as the consensus client. Useful for smart contract development, transaction testing, and blockchain experimentation without connecting to public testnets.

## Selecting a Fork Version

Each git tag corresponds to a specific Ethereum fork version (e.g., `deneb`, `electra`). Check out the desired tag to run a network configured for that fork:

```bash
git tag            # list available fork versions
git checkout <tag> # switch to a specific fork version
```

## Components
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

| Port | Description |
|------|-------------|
| `8545` | Geth HTTP RPC |
| `8546` | Geth WebSocket |
| `8551` | Geth Auth RPC |
| `3500` | Beacon Chain gRPC Gateway |
| `4000` | Beacon Chain RPC |

## Usage

### Run

```bash
make run
```

### Force restart (with DB reset)

```bash
make re-run
```

### Clean DB

```bash
sudo ./launcher.sh clean
```
