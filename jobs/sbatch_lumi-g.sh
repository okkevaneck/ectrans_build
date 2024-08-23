#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file runs the ecTrans dwarf within a submitted job.
# ------------------------------------------------------------------------------
#SBATCH --job-name=ectrans_sbatch
#SBATCH --partition=dev-g
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --account=project_465000454
#SBATCH --nodes=1
#SBATCH --gpus-per-node=8
#SBATCH --ntasks=8
#SBATCH --time=00:01:30

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

# Create "select_gpu" script as indicated by Lumi documentation.
SELECT_GPU_NAME=./select_gpu_sbatch
rm -rf "$SELECT_GPU_NAME"
cat << EOF > "$SELECT_GPU_NAME"
#!/bin/bash

export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID
exec \$*
EOF
chmod +x "$SELECT_GPU_NAME"

# Setup GPU and OpenMP aware hardware config.
CPU_BIND="mask_cpu:7e000000000000,7e00000000000000"
CPU_BIND="${CPU_BIND},7e0000,7e000000"
CPU_BIND="${CPU_BIND},7e,7e00"
CPU_BIND="${CPU_BIND},7e00000000,7e0000000000"

export OMP_NUM_THREADS=6
export MPICH_GPU_SUPPORT_ENABLED=1

# Specify where to store results.
RESULTS="$RESULTS_DIR/$RESDIR"
rm -rf "$RESULTS"
mkdir -p "$RESULTS"

# Run ecTrans with given arguments.
srun --cpu-bind=${CPU_BIND} --output="$RESULTS/out.%j.%t" \
    --error="$RESULTS/err.%j.%t" --input=none "$SELECT_GPU_NAME" -- \
    "${INSTALLDIR}/${ECTRANS_DIR}/bin/${BINARY}" \
        --vordiv \
        --scders \
        --uvders \
        --norms \
        --nfld $NFLD \
        --truncation $TRUNCATION \
        --niter $NITER

# Delete the "select_gpu_sbatch" script.
rm -rf "$SELECT_GPU_NAME"

# Output succesfull run.
success "Finished the sbatch run of ecTrans."
