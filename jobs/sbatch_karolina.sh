#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs the ecTrans dwarf within a submitted job.
# ------------------------------------------------------------------------------
#SBATCH --job-name=ectrans_sbatch
#SBATCH --partition=qgpu
#SBATCH --exclusive
#SBATCH --account=dd-24-88
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --gpus-per-node=8
#SBATCH --time=00:05:00
##SBATCH --reservation=dd-24-88_2024-09-05T13:00:00_2024-09-05T17:00:00_4_qgpu

# Load modules.
module load \
    CMake/3.26.3-GCCcore-12.3.0 \
    nvompi/2024.3 \
    FFTW/3.3.10-NVHPC-24.3-CUDA-12.3.0

# Set binary and results directory name to ENV value or default.
[ -z "$BINARY" ] && BINARY="ectrans-benchmark-gpu-dp"
[ -z "$RESDIR" ] && RESDIR="${RESULTS_DIR}/${SLURM_JOB_ID}.out"

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
        --nlev $NLEV \
        --truncation $TRUNCATION \
        --niter $NITER

# Output succesfull run.
echo "Finished the sbatch run of ecTrans."
