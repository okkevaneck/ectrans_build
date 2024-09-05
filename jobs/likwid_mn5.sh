#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs the ecTrans dwarf within a submitted job.
# ------------------------------------------------------------------------------
#SBATCH --job-name=ectrans_sbatch
#SBATCH --qos=acc_ehpc
#SBATCH --exclusive
#SBATCH --account=ehpc01
#SBATCH --nodes=1
#SBATCH --tasks-per-node=4
#SBATCH --gpus-per-node=4
#SBATCH --time=00:01:30

# Load modules.
module load \
    nvidia-hpc-sdk/24.3 \
    fftw/3.3.10-gcc-nvhpcx

# Load modules for LIKWID.
source "/gpfs/projects/ehpc01/ovaneck/perf_tools/likwid/load_likwid.sh"

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
likwid-mpirun -np $SLURM_NTASKS  -g ENERGY \
    "${INSTALLDIR:?}/${ECTRANS_DIR:?}/bin/${BINARY:?}" \
        --vordiv \
        --scders \
        --uvders \
        --norms \
        --nfld $NFLD \
        --truncation $TRUNCATION \
        --niter $NITER

# Output succesfull run.
echo "Finished the sbatch run of ecTrans."
