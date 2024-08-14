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

####################################################################
# OpenMP FLAGS
####################################################################

set( ENABLE_OMP ON CACHE STRING "" )
set( OpenMP_C_FLAGS "-fopenmp" CACHE STRING "" )
set( OpenMP_Fortran_FLAGS "-fopenmp" CACHE STRING "" )
set( CMAKE_EXE_LINKER_FLAGS "-fopenmp" CACHE STRING "" )

####################################################################
# OpenACC FLAGS
####################################################################

set( ENABLE_ACC ON CACHE STRING "" )
set( OpenACC_C_FLAGS "-hacc" )
set( OpenACC_CXX_FLAGS "-hacc" )
set( OpenACC_Fortran_FLAGS "-hacc -h acc_model=deep_copy:no_fast_addr:auto_async_none" )

####################################################################
# Compiler FLAGS
####################################################################

# General Flags (add to default)
set(ECBUILD_Fortran_FLAGS "-hcontiguous")
set(ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -hbyteswapio")
set(ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Wl,--as-needed")
set(ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -Wl,-hsystem_alloc")
if(ENABLE_OMP)
    set(ECBUILD_Fortran_FLAGS "${ECBUILD_Fortran_FLAGS} -fopenmp")
endif()

# No tcmalloc:
set(ECBUILD_Fortran_LINK_FLAGS "${ECBUILD_Fortran_LINK_FLAGS} -hsystem_alloc")
