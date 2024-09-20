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
BIN=ectrans-benchmark-cpu-dp
NITER=3
TRUNCATION=1599
OUTDIR_PREFIX="$EXPDIR/CPU"
TIMELIMIT="00:20:00"
NODES="1 2 4 8 16 32"

# Schedule a job for each number of nodes.
for N in $NODES; do
    # Set path of output directory.
    OUTDIR=${OUTDIR_PREFIX:?}/N${N}_T${TRUNCATION}_I${NITER}

    # Submit job with correct variables set.
    export BINARY=$BIN
    export RESDIR=$OUTDIR
    export NITER=$NITER
    export TRUNCATION=$TRUNCATION
    JOBID=$(sbatch --parsable -N $N --time=$TIMELIMIT \
        --gpus-per-node=0 \
        --output=$OUTDIR/slurm-%j.out ${JOBDIR:?}/sbatch_mn5.sh)
    info "==> Submitted CPU on $N nodes with JobID $JOBID"
done

success "==> Submitted all jobs."
