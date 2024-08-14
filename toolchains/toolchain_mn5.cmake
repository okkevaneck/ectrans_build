# (C) Copyright 1988- ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

####################################################################
# COMPILER
####################################################################

set( ECBUILD_FIND_MPI OFF CACHE STRING "" )
set( ENABLE_USE_STMT_FUNC ON CACHE STRING "" )
set(CMAKE_CUDA_COMPILER /apps/ACC/NVIDIA-HPC-SDK/24.3/Linux_x86_64/24.3/compilers/bin/nvcc)

####################################################################
# OpenMP FLAGS
####################################################################

set( ENABLE_OMP ON CACHE STRING "" )
# set( OpenMP_C_FLAGS "-mp -target=gpu" CACHE STRING "" )
# set( OpenMP_Fortran_FLAGS "-mp -target=gpu" CACHE STRING "" )
# set( CMAKE_EXE_LINKER_FLAGS "-mp -target=gpu" CACHE STRING "" )
# -target=gpu

####################################################################
# OpenACC FLAGS
####################################################################

set( ENABLE_ACC ON CACHE STRING "" )
set( OpenACC_C_FLAGS "-acc=gpu" )
set( OpenACC_CXX_FLAGS "-acc=gpu" )
set( OpenACC_Fortran_FLAGS "-acc=gpu" )

####################################################################
# Compiler FLAGS
####################################################################

# General Flags (add to default)
set(ECBUILD_Fortran_FLAGS "-Wl,--as-needed")
if(ENABLE_OMP)
    set(ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -mp=gpu")
# if(ENABLE_ACC)
#     set(ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -")
endif()
