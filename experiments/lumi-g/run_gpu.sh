#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs ecTrans dwarf experiments on MareNostrum 5.
# ------------------------------------------------------------------------------
source helpers.sh

# EXPDIR is the PWD of this file.
EXPDIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Define experiment details.
BIN=ectrans-benchmark-gpu-dp
NITER=10
OUTDIR="$EXPDIR/GPU"
TIMELIMIT="00:30:00"
NODES="1 4 8 16 32"

# Debug queue can maximumly have 2 jobs inside.
for N in $NODES; do
    CONCURRENT_DEBUG_JOBS=$(squeue --me -p acc_debug | wc -l)
    while [ $CONCURRENT_DEBUG_JOBS -eq 3 ]; do
        sleep 10
        CONCURRENT_DEBUG_JOBS=$(squeue --me -p dev-g | wc -l)
    done

    NAME=${VER}_${N}
    REAL_OUTDIR=$OUTDIR/TRACES/EXEC_$NAME
    echo "$NAME running @ $REAL_OUTDIR with $N nodes"
    ../workflow_scripts/submit_alaro_run.sh \
                            --version $VER \
                            --workdir=$REAL_OUTDIR \
                            --steps $STEPS  \
                            --nodes=$N \
                            --partition=dev-g \
                            --timelimit=$TIMELIMIT \
                            --environment=$ENV \
                            --name $NAME \

    info "==> Submitted $NAME"
done

success "==> Submitted all jobs."