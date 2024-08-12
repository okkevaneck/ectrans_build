#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file contains environment variables used to define the installation
# structure. definitions used.
# ------------------------------------------------------------------------------

# Export base directories.
# The BASEDIR is the PWD of dirs.sh, which is now regardless of callers location.
export BASEDIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
export SOURCEDIR=${BASEDIR}/../src/sources
export BUILDDIR=${BASEDIR}/../src/build
export INSTALLDIR=${BASEDIR}/../src/install

# Export results folders.
export RESULTS_DIR=${BASEDIR}/../results

# Export application specific directories.
export ECBUILD_DIR="ecbuild"
export ECKIT_DIR="eckit"
export FCKIT_DIR="fckit"
export FIAT_DIR="fiat"
export ECTRANS_DIR="ectrans"
