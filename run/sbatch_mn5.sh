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

# Load modules.
module load \
    nvidia-hpc-sdk/24.3 \
    fftw/3.3.10-gcc-nvhpcx

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
mpirun -x $OMP_NUM_THREADS -x $PATH -x $LD_LIBRARY_PATH --bind-to core -np 8 --map-by ppr:8:node --output-filename out.4846600 ./ectrans-runner.sh

#mpirun --output="$RESULTS/out.%j.%t" --error="$RESULTS/err.%j.%t" --input=none \
#    -- ${INSTALLDIR}/${ECTRANS_DIR}/bin/${BINARY} \
#        --vordiv \
#        --scders \
#        --uvders \
#        --nfld $NFLD \
#        --norms \
#        --niter $NITER

# Output succesfull run.
success "Finished the sbatch run of ecTrans."
