#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs the ecTrans dwarf within a submitted job.
# ------------------------------------------------------------------------------
#SBATCH --job-name=ectrans_sbatch
#SBATCH --qos=acc_debug
#SBATCH --exclusive
#SBATCH --account=bsc32
#SBATCH --nodes=1
#SBATCH --time=00:1:30

# Load helpers for color printing.
source ../helpers/helpers.sh

# Load directory structure of installation.
source ../helpers/dirs.sh

# Set binary and results directory name to ENV value or default.
[ -z "$BINARY" ] && BINARY="ectrans-benchmark-cpu-dp"
[ -z "$RESDIR" ] && RESDIR="sbatch"

# Set runtime arguments to ENV value or default.
[ -z "$NPROMA" ] && NPROMA=32
[ -z "$NFLD" ] && NFLD=1
[ -z "$NLEV" ] && NLEV=10
[ -z "$NITER" ] && NITER=10

export OMP_NUM_THREADS=6  # TODO: Review required number of threads.
export MPICH_GPU_SUPPORT_ENABLED=1

# Specify where to store results.
RESULTS="$RESULTS_DIR/$RESDIR"
rm -rf "$RESULTS"
mkdir -p "$RESULTS"

# Run ecTrans with given arguments.
ARGS="--nproma $NPROMA --vordiv --scders --uvders --nfld $NFLD --norms --niter $NITER"
srun --output="$RESULTS/out.%j.%t" --error="$RESULTS/err.%j.%t" --input=none \
    -- "${INSTALLDIR}/${ECTRANS_DIR}/bin/${BINARY}" "${ARGS}"

# Delete the "select_gpu_sbatch" script.
rm -rf "$SELECT_GPU_NAME"

# Output succesfull run.
success "Finished the sbatch run of ecTrans."
