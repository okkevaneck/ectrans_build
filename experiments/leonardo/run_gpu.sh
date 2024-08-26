#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs ecTrans dwarf experiments on MareNostrum 5.
# ------------------------------------------------------------------------------
# Load helpers for color printing.
source ../../helpers/helpers.sh

# Load directory structure of installation.
source ../../helpers/dirs.sh

# EXPDIR is the PWD of this file.
EXPDIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Define experiment details.
BIN=ectrans-benchmark-gpu-dp
NITER=3
TRUNCATION=1599
OUTDIR_PREFIX="$EXPDIR/GPU"
TIMELIMIT="00:20:00"
NODES="4"

# Schedule a job for each number of nodes.
for N in $NODES; do
    # Set path of output directory and set number of tasks to 4 (GPUs) per node.
    OUTDIR=${OUTDIR_PREFIX:?}/N${N}_T${TRUNCATION}_I${NITER}

    # Submit job with correct variables set.
    export BINARY=$BIN
    export RESDIR=$OUTDIR
    export NITER=$NITER
    export TRUNCATION=$TRUNCATION
    JOBID=$(sbatch --parsable -N $N --time=$TIMELIMIT \
        --output=$OUTDIR/slurm-%j.out ${JOBDIR:?}/sbatch_leonardo.sh)
    info "==> Submitted GPU on $N nodes with JobID $JOBID"
done

success "==> Submitted all jobs."
