#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs ecTrans dwarf GPU experiments on Leonardo.
# ------------------------------------------------------------------------------
# Load helpers for color printing.
source ../../helpers/helpers.sh

# Load directory structure of installation.
source ../../helpers/dirs.sh

# EXPDIR is the PWD of this file.
EXPDIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Define experiment details.
BIN=ectrans-benchmark-gpu-dp
NITER=10
NLEV=79
TRUNCATION=1279
OUTDIR_PREFIX="$EXPDIR/GPU_scaling"
TIMELIMIT="00:20:00"
NODES="4 8 16 32"

# Schedule a job for each number of nodes.
for N in $NODES; do
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
        --output=$OUTDIR/slurm-%j.out ${JOBDIR:?}/sbatch_leonardo.sh)
    info "==> Submitted GPU on $N nodes with JobID $JOBID"
done

success "==> Submitted all jobs."
