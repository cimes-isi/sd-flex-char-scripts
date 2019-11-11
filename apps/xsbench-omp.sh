#!/bin/bash
export APP_NAME="xsbench-omp"
export APP_CMD=(XSBench)

function app_pre() {
    export OMP_NUM_THREADS=$1
    export OMP_PROC_BIND=TRUE
}

function app_post() {
    :
}
