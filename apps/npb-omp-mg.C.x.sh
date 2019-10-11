#!/bin/bash
export APP_NAME="npb-omp-mg.C.x"
APP_BIN=$(which -a mg.C.x 2>/dev/null | grep OMP || echo "mg.C.x")
export APP_CMD=("$APP_BIN")

function app_pre() {
    export OMP_NUM_THREADS=$1
    export OMP_PROC_BIND=TRUE
}

function app_post() {
    :
}
