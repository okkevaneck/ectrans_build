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
NITER=10
TRUNCATION=79
OUTDIR_PREFIX="$EXPDIR/GPU"
TIMELIMIT="00:10:00"
# NODES="1 4 8 16 32"
NODES="1 4"

# Debug queue can maximumly have 2 jobs inside.
for N in $NODES; do
    # Create work directory and copy binary to run there.
    OUTDIR=${OUTDIR_PREFIX:?}/N${N}_T${TRUNCATION}_I${NITER}
    rm -rf $OUTDIR
    mkdir -p $OUTDIR
    cp "${INSTALLDIR:?}/${ECTRANS_DIR:?}/bin/${BIN:?}" ${OUTDIR:?}/

    # Submit job with correct variables set.
    export BINARY="${OUTDIR:?}/${BIN}"
    export RESDIR="${OUTDIR}/RESULTS"
    export NITER=$NITER
    export TRUNCATION=$TRUNCATION
    sbatch -N $N --time=$TIMELIMIT ${JOBDIR:?}/sbatch_mn5.sh

    info "==> Submitted GPU on $N nodes with JobID $SLURM_JOB_ID"
done

success "==> Submitted all jobs."