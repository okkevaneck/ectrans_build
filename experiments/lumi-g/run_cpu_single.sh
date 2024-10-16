#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs ecTrans dwarf GPU experiments on LUMI.
# ------------------------------------------------------------------------------
# Load helpers for color printing.
source ../../helpers/helpers.sh

# Load directory structure of installation.
source ../../helpers/dirs.sh

# EXPDIR is the PWD of this file.
EXPDIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Define experiment details.
BIN=ectrans-benchmark-cpu-dp
NITER=10
NLEV=137
TRUNCATION=399
OUTDIR_PREFIX="$EXPDIR/CPU_single"
TIMELIMIT="00:05:00"
NODES="1"

# Debug queue can maximumly have 2 jobs inside.
for N in $NODES; do
    # Wait for queque space.
    CONCURRENT_DEBUG_JOBS=$(squeue --me -p dev-g | wc -l)
    while [ $CONCURRENT_DEBUG_JOBS -eq 3 ]; do
        sleep 10
        CONCURRENT_DEBUG_JOBS=$(squeue --me -p dev-g | wc -l)
    done

    # Set path of output directory and create it.
    OUTDIR=${OUTDIR_PREFIX:?}/N${N}_T${TRUNCATION}_I${NITER}
    mkdir -p $OUTDIR

    # Submit job with correct variables set.
    export BINARY=$BIN
    export RESDIR=$OUTDIR
    export NITER=$NITER
    export NLEV=$NLEV
    export TRUNCATION=$TRUNCATION
    JOBID=$(sbatch --parsable -N $N --time=$TIMELIMIT \
        --gpus-per-node=1 \
        --output=$OUTDIR/slurm-%j.out ${JOBDIR:?}/sbatch_lumi-g.sh)
    info "==> Submitted CPU on $N nodes with JobID $JOBID"
done

success "==> Submitted all jobs."
