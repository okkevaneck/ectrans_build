#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs the ecTrans dwarf within a submitted job.
# ------------------------------------------------------------------------------
#SBATCH --job-name=ectrans_sbatch
#SBATCH --partition=boost_usr_prod
#SBATCH --qos=normal
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --account=DestE_330_24
#SBATCH --nodes=1
#SBATCH --gpus-per-node=4
#SBATCH --tasks-per-node=4
#SBATCH --time=00:01:30

# Load modules.
module load nvhpc/24.3 fftw/3.3.10--openmpi--4.1.6--nvhpc--24.3

# Load helpers for color printing.
source ../helpers/helpers.sh

# Load directory structure of installation.
source ../helpers/dirs.sh

# Set binary and results directory name to ENV value or default.
[ -z "$BINARY" ] && BINARY="ectrans-benchmark-gpu-dp"
[ -z "$RESDIR" ] && RESDIR="${SLURM_JOB_ID}.out"

# Set runtime arguments to ENV value or default.
[ -z "$NFLD" ] && NFLD=1
[ -z "$NLEV" ] && NLEV=10
[ -z "$TRUNCATION" ] && TRUNCATION=79
[ -z "$NITER" ] && NITER=10

export OMP_NUM_THREADS=6
export MPICH_GPU_SUPPORT_ENABLED=1

# Run ecTrans with given arguments.
mpirun \
    --output-filename "$RESDIR/slurm_$SLURM_JOB_ID" \
    "${INSTALLDIR:?}/${ECTRANS_DIR:?}/bin/${BINARY:?}" \
        --vordiv \
        --scders \
        --uvders \
        --norms \
        --nfld $NFLD \
        --truncation $TRUNCATION \
        --niter $NITER

# Output succesfull run.
success "Finished the sbatch run of ecTrans."
