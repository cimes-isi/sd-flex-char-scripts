#!/bin/bash

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export PATH=$THIS_DIR:$PATH # to run other scripts

function run_multiapp() {
    local socks=$1
    local logdir=$2
    local cpus=$((IS_PHYS_ONLY ? TOPOLOGY_SOCKET_CORES : TOPOLOGY_SOCKET_CPUS))
    local insts=$((IS_MULTIPLE ? socks : 1))
    local threads=$((IS_MULTIPLE ? cpus : cpus * socks))
    local OPTIONAL_PARAMS=("${PASSTHROUGH_ARGS[@]}")
    if [ "$IS_PHYS_ONLY" -ne 0 ]; then
        OPTIONAL_PARAMS+=(-p)
    fi
    mkdir "$logdir" || return $?
    (
        cd "$logdir"
        echo "Characterize: total socket(s): start: $socks"
        run-multiapp-numactl.sh -a "$APP_SCRIPT_PATH" \
                                -i "$insts" -t $threads \
                                -s "$socks" -c "$TOPOLOGY_SOCKET_CORES" \
                                "${OPTIONAL_PARAMS[@]}"
        local rc=$?
        echo "Characterize: total socket(s): end: $socks"
        return $rc
    )
}

function characterize_sockets_multiapp() {
    for s in "$@"; do
        local logdir="sockets_${s}"
        if [ -e "$logdir" ]; then
            echo "WARNING: directory exists: $logdir"
            echo "  skipping..."
            continue
        fi
        run_multiapp "$s" "$logdir" || return $?
    done
}

function usage() {
    echo "Characterize running app instance(s) on different socket counts"
    echo ""
    echo "Usage: $0 -a SH [-s N]+ [-p] [-m] [-w] [-h] -- [run-multiapp-numactl.sh args]"
    echo "    -a SH: bash script to source with app launch vars"
    echo "    -s N: a socket count to characterize (default = all sockets)"
    echo "    -p: use only physical cores"
    echo "    -m: multiple executions - one app instance per socket (weak scaling)"
    echo "    -w: perform a warmup execution before characterization"
    echo "    -h: print help/usage and exit"
}

IS_MULTIPLE=0
IS_WARMUP=0
IS_PHYS_ONLY=0
SOCKET_COUNTS=()
while getopts "a:s:pmwh?" o; do
    case "$o" in
        a)
            APP_SCRIPT=$OPTARG
            ;;
        s)
            SOCKET_COUNTS+=($OPTARG)
            ;;
        p)
            IS_PHYS_ONLY=1
            ;;
        m)
            IS_MULTIPLE=1
            ;;
        w)
            IS_WARMUP=1
            ;;
        h)
            usage
            exit
            ;;
        *)
            >&2 usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))
PASSTHROUGH_ARGS=("$@")
if [ -z "$APP_SCRIPT" ] || [ ! -f "$APP_SCRIPT" ]; then
    >&2 usage
    exit 1
fi
APP_SCRIPT_PATH=$(readlink -f "$APP_SCRIPT") # b/c we cd later

source topology.sh

if [ ${#SOCKET_COUNTS[@]} -eq 0 ]; then
    SOCKET_COUNTS=($(seq 1 "$TOPOLOGY_SOCKETS"))
else
    for s in "${SOCKET_COUNTS[@]}"; do
        if [ "$s" -lt 1 ] || [ "$s" -gt "$TOPOLOGY_SOCKETS" ]; then
            >&2 echo "Socket count ($s) out of range: [1, $TOPOLOGY_SOCKETS]"
            exit 1
        fi
    done
fi

if [ $IS_WARMUP -gt 0 ]; then
    run_multiapp "$TOPOLOGY_SOCKETS" warmup || exit $?
fi

characterize_sockets_multiapp "${SOCKET_COUNTS[@]}"
