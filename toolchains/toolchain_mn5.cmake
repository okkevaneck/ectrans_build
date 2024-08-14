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

# set(CMAKE_Fortran_COMPILER /apps/ACC/NVIDIA-HPC-SDK/24.3/Linux_x86_64/24.3/compilers/bin/nvfortran)

# set( ECBUILD_FIND_MPI OFF CACHE STRING "" )
# set( ENABLE_USE_STMT_FUNC ON CACHE STRING "" )

# ####################################################################
# # OpenMP FLAGS
# ####################################################################

# set( ENABLE_OMP ON CACHE STRING "" )
# set( OpenMP_C_FLAGS "-openmp" CACHE STRING "" )
# set( OpenMP_Fortran_FLAGS "-openmp" CACHE STRING "" )
# set( CMAKE_EXE_LINKER_FLAGS "-openmp" CACHE STRING "" )
# # -target=gpu

# ####################################################################
# # OpenACC FLAGS
# ####################################################################

# set( ENABLE_ACC ON CACHE STRING "" )
# set( OpenACC_C_FLAGS "-acc=gpu" )
# set( OpenACC_CXX_FLAGS "-acc=gpu" )
# set( OpenACC_Fortran_FLAGS "-acc=gpu" )

# ####################################################################
# # Compiler FLAGS
# ####################################################################

# General Flags (add to default)
# set(ECBUILD_C_FLAGS "${ECBUILD_C_FLAGS} -fast")
# set(ECBUILD_CXX_FLAGS "${ECBUILD_CXX_FLAGS} --diag_suppress177 -fast")
# set(ECBUILD_Fortran_FLAGS "-Wl --disable-new-dtags -Mlarge_arrays -fast")
set(ECBUILD_Fortran_FLAGS "-lm -Wall -Wextra")
# if(ENABLE_OMP)
#     set(ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -mp=gpu")
# endif()
# if(ENABLE_ACC)
#     set(ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -acc")
# endif()