mpirun \
    --output-filename "CTEST_$SLURM_JOB_ID" \
    ctest \
    src/install/ectrans/bin/ectrans-benchmark-cpu-dp \
        --vordiv \
        --scders \
        --uvders \
        --norms \
        --nfld 1 \
        --truncation 79 \
        --niter 3
