#!/bin/bash

source ../helpers/helpers.sh
source ../helpers/dirs.sh

DEFAULT_BINARY="${INSTALLDIR}/${ECTRANS_DIR}/bin/ectrans-benchmark-gpu-dp"
DEFAULT_ARGS="--vordiv --scders --uvders --nfld 1 --norms --niter 10"

function is_set_to_true() {
    local varname=$1
    set +u
    [ -z "${!varname}" -o "${!varname}" == 0 -o "${!varname}" == false -o "${!varname}" == FALSE ] && return 1
    set -u
    return 0
}

[ ! -z "$BINARY" -a ! -z "$1" -a "$BINARY" != "$1" ] && { echo "FATAL: can't handle different binary names from different sources: BINARY env. and an argument."; exit 1; }
[ -z "$BINARY" ] && BINARY="$DEFAULT_BINARY"
[ -z "$1" ] || { BINARY="$1"; shift; }

ARGS="$*"
[ -z "$ARGS" ] && ARGS="$DEFAULT_ARGS"

export local_rank=$OMPI_COMM_WORLD_LOCAL_RANK
export global_rank=$OMPI_COMM_WORLD_RANK


[ -z "$PSUBMIT_PPN" ] && PSUBMIT_PPN=8
[ -z "$PSUBMIT_NGPUS" ] && PSUBMIT_NGPUS=4
if [ "$PSUBMIT_PPN" == 4 ]; then
  threads=(20 20 20 20)
  physcores=(0-19 20-39 40-59 60-79)
elif [ "$PSUBMIT_PPN" == 8 ]; then
  threads=(10 10 10 10 10 10 10 10)
  physcores=(0-9 10-19 20-29 30-39 40-49 50-59 60-69 70-79)
elif [ "$PSUBMIT_PPN" == 16 ]; then
  threads=(5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5)
  physcores=(0-4 5-9 10-14 15-19 20-24 25-29 30-34 35-39 40-44 45-49 50-54 55-59 60-64 65-69 70-74 75-79)
fi

divider=$(expr "$PSUBMIT_PPN" / "$PSUBMIT_NGPUS")
export local_device_id=$(echo | awk -v X=$local_rank "{print int(X/$divider)}")

export OMP_PROC_BIND=close
export OMP_PLACES=cores

export CUDA_VISIBLE_DEVICES="$local_device_id"
#export UCX_CUDA_COPY_DMABUF=no
#export NVCOMPILER_ACC_DEFER_UPLOADS=1

[ "$local_rank" == 0 ] && env -u CUDA_VISIBLE_DEVICES nvidia-cuda-mps-control -d
[ "$local_rank" != 0 ] && timeout 20 bash -c 'until pgrep nvidia-cuda-mps >/dev/null; do sleep 0.5; done'

if is_set_to_true PROFILE; then
    export PROFILE
    numactl -l --all --physcpubind=${physcores[$local_rank]} -- ./profiling-wrapper.sh $BINARY $ARGS
else
    numactl -l --all --physcpubind=${physcores[$local_rank]} -- $BINARY $ARGS
fi

[ "$local_rank" == 0 ] && sleep 5 && echo quit | nvidia-cuda-mps-control || true
