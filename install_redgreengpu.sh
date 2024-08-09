#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file downloads, builds, and installs the ecTrans dwarf.
# ------------------------------------------------------------------------------

# Load helpers for color printing.
source helpers/helpers.sh

# Load directory structure for installation paths.
source helpers/dirs.sh

# Setup required modules.
module load \
    cmake/3.29.2 EB/apps \
    CUDA/12.5.0 \
    intel/2023.2.0 impi/2021.10.0 \
    hdf5/1.14.1-2 fftw/3.3.10 \
    OpenBLAS/0.3.24-GCC-13.2.0

#module load \
#    cmake/3.29.2 EB/apps \
#    CUDA/12.5.0 \
#    intel/2023.2.0 openmpi/4.1.5-gcc hdf5/1.14.1-2-gcc-ompi \
#    fftw/3.3.10-gcc-ompi OpenBLAS/0.3.24-GCC-13.2.0

#mpi/2021.11 openmpi/4.1.5-gcc
module list &> loaded_mods.txt

# Remove source and build files, and download fresh version.
download () {
    # Remove sources/ and build/
    ./clean.sh

    # Pull ecTrans.
    info "==> PULLING ECTRANS"
    cd "${SOURCEDIR}" || exit 1
    mkdir -p ectrans
    cd ectrans || exit 1
    git init
    git remote add origin https://github.com/ecmwf-ifs/ectrans
    git fetch --depth 1 origin c8c5c6100bb62b1d9ce15012a0722c0611992ae9

    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED ECTRANS"
    else
	    error "==> FAILED TO CLONE ECTARNS"
        error "    Make sure you're on login4."
        exit 1
    fi 
    git checkout FETCH_HEAD 
    cd ..

    # Pull ecBuild.
    git clone --branch "3.8.5" --single-branch https://github.com/ecmwf/ecbuild.git
    success "==> SUCCESFULLY CLONED ECBUILD"

    # Pull FIAT.
    git clone --branch "1.4.1" --single-branch https://github.com/ecmwf-ifs/fiat
    success "==> SUCCESFULLY CLONED FIAT"
}

# Build and install ecBuild.
_build_install_ecbuild () {
    # Build and Install ecBuild.
    info "==> INSTALLING ECBUILD.."
    cd "${SOURCEDIR}/ecbuild" || exit 1

    # Create build directory and build ecBuild.
    rm -rf "${BUILDDIR:?}/ecbuild" "${INSTALLDIR:?}/ecbuild"
    mkdir -p "${BUILDDIR}/ecbuild"
    cd "${BUILDDIR}/ecbuild" || exit 1
    info "==>\t ECBUILD.."
    "${SOURCEDIR}/ecbuild/bin/ecbuild" --prefix="${INSTALLDIR}/ecbuild" \
        "${SOURCEDIR}/ecbuild"
    info "==>\t MAKE.."
    make 2>&1 | tee "${BUILDDIR}/ecbuild.log"

    # Install ecBuild.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/ecbuild.log"
    success "==> SUCCESFULLY INSTALLED ECBUILD"
}

# Build and install FIAT.
_build_install_fiat () {
    # Build and Install FIAT.
    info "==> INSTALLING FIAT.."
    cd "${SOURCEDIR}/fiat" || exit 1
    
    # Create build directory and build FIAT.
    rm -rf "${BUILDDIR:?}/${FIAT_DIR:?}" "${INSTALLDIR:?}/${FIAT_DIR:?}"
    mkdir -p "${BUILDDIR}/${FIAT_DIR}"
    cd "${BUILDDIR}/${FIAT_DIR}" || exit 1
    info "==>\t ECBUILD.."
    ecbuild -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALLDIR}/${FIAT_DIR}" -DENABLE_MPI=ON \
        -DENABLE_TESTS=OFF "${SOURCEDIR}/fiat"
    info "==>\t MAKE.."
    make -j16 2>&1 | tee "${BUILDDIR}/fiat.log"

    # Install FIAT.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/fiat.log"
    success "==> SUCCESFULLY INSTALLED FIAT"
}

# Build and install ecTrans.
_build_install_ectrans () {
    # Build and Install ecTrans.
    info "==> Installing ecTrans.."

    # Create build directory and build ecTrans.
    rm -rf "${BUILDDIR:?}/${ECTRANS_DIR:?}" "${INSTALLDIR:?}/${ECTRANS_DIR:?}"
    mkdir -p "${BUILDDIR}/${ECTRANS_DIR}"
    cd "${BUILDDIR}/${ECTRANS_DIR}" || exit 1
    info "==>\t ECBUILD.."
    ecbuild --prefix="${INSTALLDIR}/${ECTRANS_DIR}" \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -Dfiat_ROOT="${INSTALLDIR}/${FIAT_DIR}" \
        -DENABLE_FFTW=ON -DENABLE_GPU=ON -DENABLE_OMPGPU=OFF \
        -DENABLE_ACCGPU=ON -DENABLE_TESTS=OFF -DENABLE_GPU_AWARE_MPI=ON \
        -DENABLE_CPU=ON -DENABLE_ETRANS=ON  -DENABLE_DOUBLE_PRECISION=ON \
        -DENABLE_SINGLE_PRECISION=OFF \
        -DOpenMP_Fortran_FLAGS="-fopenacc" \
        -DCMAKE_Fortran_FLAGS="-fopenacc" \
        -DCMAKE_C_FLAGS="-fopenacc" \
        "${SOURCEDIR}/ectrans"
    info "==>\t MAKE (supposed to fail).."
    make -j32 2>&1 | tee "${BUILDDIR}/ectrans.log"
    info "==>\t MAKE (again, should succeed).."
    make -j32 2>&1 | tee -a "${BUILDDIR}/ectrans.log"

    # Install ecTrans.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/ectrans.log"
    success "==> SUCCESFULLY INSTALLED ECTRANS"
}

# Build and Install source files.
build_install_all () {
    _build_install_ecbuild
    _build_install_fiat
    _build_install_ectrans
}

main () {
    # Set compilers for make/cmake.
    export FC90=ifort
    export FC=ifort
    export CC=cc
    export CXX=cc

    # Export environment variables used during installation.
    export PATH=${PATH}:${INSTALLDIR}/ecbuild/bin/
    # export TOOLCHAIN_FILE=toolchains/toolchain_mn5.cmake
    # export ECBUILD_TOOLCHAIN="${TOOLCHAIN_FILE}"

    # Create directories for the installation process.
    mkdir -p "${SOURCEDIR}" "${BUILDDIR}" "${INSTALLDIR}"

    # If no arguments passed, download, build, and install everything.
    if [ $# -eq 0 ]; then
        info "No arguments given, so doing complete new install.."
        ./clean.sh all
        download
        build_install_all
    else
        # Else parse every passed argument.
        for var in "$@"; do
            arrVar=(${var//:/ })
            instruction=${arrVar[0]}
            program=${arrVar[1]}

            case $instruction in
                "d")
                    # Download everything, regardless of specified program.
                    info "Downloading all sources.."
                    download
                    ;;
                "bi")
                    # Parse the program to build, default to all.
                    case $program in
                        "ecbuild")
                            info "==> install.sh:  Building ecBuild"
                            _build_install_ecbuild
                            ;;
                        "fiat")
                            info "==> install.sh:  Building FIAT"
                            _build_install_fiat
                            ;;
                        "ectrans")
                            info "==> install.sh:  Building ecTrans"
                            _build_install_ectrans
                            ;;
                        *)
                            # Build everything as default.
                            info "==> install.sh:  Building all"
                            build_install_all
                            ;;
                    esac
                    ;;
                *)
                    info "Instruction '$instruction' not found.."
                    ;;
                esac
        done
    fi
}

# Call main as entrypoint of script.
main "$@"

