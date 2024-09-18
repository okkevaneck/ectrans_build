# (C) Copyright 1988- ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.
# ---
# NOTE:
#   This is an altered version of a file used for phase 1 of the DEODE project.
#   For the current version, it fixed the OpenMP linking for the FIAT 
#   compilation, but breaks the one for the ecTrans compilation. Hence, it
#   needs to be loaded at the start and unloaded when the ecTrans compilation
#   and installation starts.


####################################################################
# OpenMP FLAGS
####################################################################

set( ENABLE_OMP ON CACHE STRING "" )
set( OpenMP_C_FLAGS "-fopenmp" CACHE STRING "" )
set( OpenMP_Fortran_FLAGS "-fopenmp" CACHE STRING "" )
set( CMAKE_EXE_LINKER_FLAGS "-fopenmp" CACHE STRING "" )
set( ECBUILD_Fortran_FLAGS "-fopenmp" )
