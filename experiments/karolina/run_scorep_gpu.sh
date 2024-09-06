#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs ecTrans dwarf experiments on Karolina.
# ------------------------------------------------------------------------------
# Load helpers for color printing.
source ../../helpers/helpers.sh

# Load directory structure of installation.
source ../../helpers/dirs.sh

# Export runtime variables for enabling Score-P instrumentation and tracing.
export SCOREP_OPENACC_ENABLE=yes

# EXPDIR is the PWD of this file.
EXPDIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Define experiment details.
BIN=ectrans-benchmark-gpu-dp
NITER=1
TRUNCATION=1599
OUTDIR_PREFIX="$EXPDIR/GPU"
TIMELIMIT="00:03:00"
NODES="4"

# Schedule a job for each number of nodes.
for N in $NODES; do
    # Set path of output directory.
    OUTDIR=${OUTDIR_PREFIX:?}/N${N}_T${TRUNCATION}_I${NITER}

    # Submit job with correct variables set.
    export BINARY=$BIN
    export RESDIR=$OUTDIR
    export NITER=$NITER
    export TRUNCATION=$TRUNCATION
    JOBID=$(sbatch --parsable -N $N --time=$TIMELIMIT --gpus-per-node=8 \
        --tasks-per-node=8 --output=$OUTDIR/slurm-%j.out \
        ${JOBDIR:?}/sbatch_karolina.sh)
    info "==> Submitted GPU on $N nodes with JobID $JOBID"
done

success "==> Submitted all jobs."
                                                                                

