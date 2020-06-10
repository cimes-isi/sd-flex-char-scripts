#!/bin/bash
export APP_NAME="npb-mz-mpi-lu.C.x"
export APP_CMD=(lu-mz.C.x)

function app_pre() {
    export OMP_NUM_THREADS=$2
    [ -z "$OMP_PROC_BIND" ] && export OMP_PROC_BIND=TRUE
}

function app_post() {
    :
}
