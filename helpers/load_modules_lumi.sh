#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file sets up the environment correctly for building.
# Note that this file thus needs to be sourced.
# ------------------------------------------------------------------------------

# Clean all used modules, then load the ones required.
module purge
module load LUMI/23.03 partition/G PrgEnv-cray cpe/23.09 craype-x86-trento \
    craype-accel-amd-gfx90a
module load cray-mpich cray-libsci cray-fftw cray-python
module load cray-hdf5-parallel cray-netcdf-hdf5parallel
module load buildtools
module load rocm/5.2.3
