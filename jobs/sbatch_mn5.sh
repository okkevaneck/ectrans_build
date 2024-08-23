#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs the ecTrans dwarf within a submitted job.
# ------------------------------------------------------------------------------
#SBATCH --job-name=ectrans_sbatch
#SBATCH --qos=acc_debug
#SBATCH --exclusive
#SBATCH --account=bsc32
#SBATCH --nodes=1
#SBATCH --gpus-per-node=4
#SBATCH --time=00:1:30

# Load modules.
module load \
    nvidia-hpc-sdk/24.3 \
    fftw/3.3.10-gcc-nvhpcx

# Load helpers for color printing.
source ../helpers/helpers.sh

# Load directory structure of installation.
source ../helpers/dirs.sh

# Set binary and results directory name to ENV value or default.
[ -z "$BINARY" ] && BINARY="${INSTALLDIR}/${ECTRANS_DIR}/bin/${BINARY}"
[ -z "$RESDIR" ] && RESDIR="${RESULTS_DIR}/${SLURM_JOB_ID}.out"

# Set runtime arguments to ENV value or default.
[ -z "$NFLD" ] && NFLD=1
[ -z "$NLEV" ] && NLEV=10
[ -z "$TRUNCATION" ] && TRUNCATION=79
[ -z "$NITER" ] && NITER=10

export OMP_NUM_THREADS=6  # TODO: Review required number of threads.
export MPICH_GPU_SUPPORT_ENABLED=1

# Create clean results directory.
rm -rf "$RESDIR"
mkdir -p "$RESDIR"

# Run ecTrans with given arguments.
mpirun \
    --output-filename "$RESDIR/slurm_$SLURM_JOB_ID.out" \
    ${BINARY} \
        --vordiv \
        --scders \
        --uvders \
        --norms \
        --nfld $NFLD \
        --truncation $TRUNCATION \
        --niter $NITER

# Output succesfull run.
success "Finished the sbatch run of ecTrans."
