#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse --version flag
VERSION=""
ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            VERSION="$2"
            shift 2
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

if [ -n "$VERSION" ]; then
    BASE_DIR="$SCRIPT_DIR/$VERSION"
else
    BASE_DIR="$SCRIPT_DIR"
fi

case "${ARGS[0]}" in
    "run")
        echo $BASE_DIR
        ;;
    "new")
        echo RUN geth new account $BASE_DIR/node/execution/data
        geth --datadir $BASE_DIR/node/execution/data account new
        ;;
    "clean")
        echo "Clear go-ethereum & Beacon & validator DB -- 🗑️"
        rm -rf $BASE_DIR/node
        mkdir -p $BASE_DIR/node/execution/data $BASE_DIR/node/consensus
        ;;
    "help" | "h")
        func_help
        ;;
    *)
    func_help
    ;;                                                                                   
esac