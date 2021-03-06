#!/bin/bash
export APP_NAME="mhmxx-anqdpht"
APP_BIN=$(which mhmxx) # upcxx-run seems to need the full path
DATASET=/dev/shm/7537.7.76903.ACTTGA.anqdpht.fastq
export APP_CMD=()

function app_pre() {
    # NOTE: cores-per-node is platform-specific!
    if [ -z "$MHMXX_CORES_PER_NODE" ]; then
        >&2 echo "ERROR: Must set env var MHMXX_CORES_PER_NODE (e.g., depending on HyperThreads)"
        return 1
    fi
    APP_CMD+=(upcxx-run -shared-heap "5%" -n "$1" --
              "$APP_BIN" --cores-per-node "$MHMXX_CORES_PER_NODE" -r "$DATASET" -i "300:30" -k "21,33,55,77,99" -s "99,33")
}

function app_post() {
    rm -f ./*.fast*
}
