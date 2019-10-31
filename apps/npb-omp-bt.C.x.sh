#!/bin/bash
export APP_NAME="npb-omp-bt.C.x"
APP_BIN=$(which -a bt.C.x 2>/dev/null | grep OMP || echo "bt.C.x")
export APP_CMD=("$APP_BIN")

function app_pre() {
    export OMP_NUM_THREADS=$1
    export OMP_PROC_BIND=TRUE
}

function app_post() {
    :
}