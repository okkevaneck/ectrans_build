#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs the ecTrans dwarf on the currently allocated node.
# ------------------------------------------------------------------------------

# Load helpers for color printing.
source helpers.sh

# Load directory structure of installation.
source dirs.sh

# Set runtime arguments to ENV value or default.
[ -z "$NPROMA" ] && NPROMA=32
[ -z "$NFLD" ] && NFLD=1
[ -z "$NLEV" ] && NLEV=10
[ -z "$CHECK" ] && CHECK=10

# Output the run configuration:
info "Running with variables nproma=$NPROMA nfld=$NFLD nlev=$NLEV check=$CHECK"

# Setup runtime hardware config.
export ROCR_VISIBLE_DEVICES="$SLURM_LOCALID"
export MPICH_GPU_SUPPORT_ENABLED=1

physcores=(49-55 57-63 17-23 25-31 1-7 9-15 33-39 41-47)
threads=(7 7 7 7 7 7 7 7)
[ "$OMP_NUM_THREADS" != 1 ] && export OMP_NUM_THREADS=${threads[$SLURM_LOCALID]}

# Run ecTrans with given arguments.
ARGS="--nproma $NPROMA --vordiv --scders --uvders --nfld $NFLD --nlev $NLEV 
        --norms --check $CHECK"
numactl -l --all --physcpubind=${physcores[$SLURM_LOCALID]} -- \
        ${INSTALLDIR}/${ECTRANS_DIR}/bin/ectrans-lam-benchmark-gpu-dp-acc ${ARGS}
