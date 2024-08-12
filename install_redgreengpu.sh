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
    nvidia-hpc-sdk/24.3 \
    intel/2023.2.0 \
    impi/2021.10.0 fftw/3.3.10


#module load \
#    cmake/3.29.2 EB/apps \
#    CUDA/12.5.0 \
#    intel/2023.2.0 impi/2021.10.0 \
#    hdf5/1.14.1-2 fftw/3.3.10 \
#    OpenBLAS/0.3.24-GCC-13.2.0

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

    # Move into source dir.
    cd "${SOURCEDIR}" || exit 1

    # Pull ecBuild.
    git clone --branch "3.8.5" --single-branch \
        https://github.com/ecmwf/ecbuild.git "${ECBUILD_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED ECBUILD"
    else
	    error "==> FAILED TO CLONE ECBUILD"
        error "    Make sure you're on login4."
        exit 1
    fi 

    # Pull eckit.
    git clone --branch "1.26.4" --single-branch \
        https://github.com/ecmwf/eckit.git "${ECKIT_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED ECKIT"
    else
	    error "==> FAILED TO CLONE ECKIT"
        error "    Make sure you're on login4."
        exit 1
    fi 

    # Pull fckit.
    git clone --branch "0.9.0" --single-branch \
        https://github.com/ecmwf/fckit.git "${FCKIT_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED FCKIT"
    else
	    error "==> FAILED TO CLONE FCKIT"
        error "    Make sure you're on login4."
        exit 1
    fi 
    
    # Pull FIAT.
    git clone --branch "1.4.1" --single-branch \
        https://github.com/ecmwf-ifs/fiat.git "${FIAT_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED FIAT"
    else
	    error "==> FAILED TO CLONE FIAT"
        error "    Make sure you're on login4."
        exit 1
    fi 

    # Pull ecTrans.
    info "==> PULLING ECTRANS"
    mkdir -p ${ECTRANS_DIR}
    cd ${ECTRANS_DIR} || exit 1
    git init
    git remote add origin https://github.com/ecmwf-ifs/ectrans
    git fetch --depth 1 origin c8c5c6100bb62b1d9ce15012a0722c0611992ae9
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED ECTRANS"
    else
	    error "==> FAILED TO CLONE ECTRANS"
        error "    Make sure you're on login4."
        exit 1
    fi 
    git checkout FETCH_HEAD 
    cd ..
}

# Build and install ecBuild.
_build_install_ecbuild () {
    # Build and Install ecBuild.
    info "==> INSTALLING ECBUILD.."
    cd "${SOURCEDIR}/${ECBUILD_DIR}" || exit 1

    # Create build directory and build ecBuild.
    rm -rf "${BUILDDIR:?}/${ECBUILD_DIR:?}" "${INSTALLDIR:?}/${ECBUILD_DIR:?}"
    mkdir -p "${BUILDDIR}/${ECBUILD_DIR}"
    cd "${BUILDDIR}/${ECBUILD_DIR}" || exit 1
    info "==>\t ECBUILD.."
    "${SOURCEDIR}/${ECBUILD_DIR}/bin/ecbuild" --prefix="${INSTALLDIR}/${ECBUILD_DIR}" \
        "${SOURCEDIR}/${ECBUILD_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY BUILD ECBUILD WITH ECBUILD"
    else
	    error "==> FAILED TO BUILD ECBUILD WITH ECBUILD"
        exit 1
    fi 

    # Make ecBuild.
    info "==>\t MAKE.."
    make 2>&1 | tee "${BUILDDIR}/ecbuild.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE ECBUILD"
    else
	    error "==> FAILED TO MAKE ECBUILD"
        exit 1
    fi 

    # Install ecBuild.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/ecbuild.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL ECBUILD"
    else
	    error "==> FAILED TO MAKE INSTALL ECBUILD"
        exit 1
    fi 
}

# Build and install eckit.
_build_install_eckit () {
    # Build and Install ECKIT.
    info "==> INSTALLING ECKIT.."
    cd "${SOURCEDIR}/${ECKIT_DIR}" || exit 1
    
    # Create build directory and build eckit.
    rm -rf "${BUILDDIR:?}/${ECKIT_DIR:?}" "${INSTALLDIR:?}/${ECKIT_DIR:?}"
    mkdir -p "${BUILDDIR}/${ECKIT_DIR}"
    cd "${BUILDDIR}/${ECKIT_DIR}" || exit 1
    info "==>\t ECBUILD.."
    ecbuild -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALLDIR}/${ECKIT_DIR}" -DENABLE_MPI=ON \
        -DENABLE_TESTS=OFF -DENABLE_ECKIT_CMD=OFF -DENABLE_ECKIT_SQL=OFF \
        -DENABLE_OMP=OFF "${SOURCEDIR}/${ECKIT_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY BUILD ECKIT WITH ECBUILD"
    else
	    error "==> FAILED TO BUILD ECKIT WITH ECBUILD"
        exit 1
    fi 

    # Make eckit.
    info "==>\t MAKE.."
    make -j10 2>&1 | tee "${BUILDDIR}/eckit.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE ECKIT"
    else
	    error "==> FAILED TO MAKE ECKIT"
        exit 1
    fi

    # Install eckit.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/eckit.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL ECKIT"
    else
	    error "==> FAILED TO MAKE INSTALL ECKIT"
        exit 1
    fi
}

# Build and install fckit.
_build_install_fckit () {
    # Build and Install FCKIT.
    info "==> INSTALLING FCKIT.."
    cd "${SOURCEDIR}/${FCKIT_DIR}" || exit 1
    
    # Create build directory and build fckit.
    rm -rf "${BUILDDIR:?}/${FCKIT_DIR:?}" "${INSTALLDIR:?}/${FCKIT_DIR:?}"
    mkdir -p "${BUILDDIR}/${FCKIT_DIR}"
    cd "${BUILDDIR}/${FCKIT_DIR}" || exit 1
    info "==>\t ECBUILD.."
    ecbuild -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALLDIR}/${FCKIT_DIR}" -DENABLE_TESTS=OFF \
        "${SOURCEDIR}/${FCKIT_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY BUILD FCKIT WITH ECBUILD"
    else
	    error "==> FAILED TO BUILD FCKIT WITH ECBUILD"
        exit 1
    fi 

    # Make fckit.
    info "==>\t MAKE.."
    make 2>&1 | tee "${BUILDDIR}/fckit.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE FCKIT"
    else
	    error "==> FAILED TO MAKE FCKIT"
        exit 1
    fi

    # Install fckit.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/fckit.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL FCKIT"
    else
	    error "==> FAILED TO MAKE INSTALL FCKIT"
        exit 1
    fi
}

# Build and install FIAT.
_build_install_fiat () {
    # Build and Install FIAT.
    info "==> INSTALLING FIAT.."
    cd "${SOURCEDIR}/${FIAT_DIR}" || exit 1
    
    # Create build directory and build FIAT.
    rm -rf "${BUILDDIR:?}/${FIAT_DIR:?}" "${INSTALLDIR:?}/${FIAT_DIR:?}"
    mkdir -p "${BUILDDIR}/${FIAT_DIR}"
    cd "${BUILDDIR}/${FIAT_DIR}" || exit 1
    info "==>\t ECBUILD.."
    ecbuild -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALLDIR}/${FIAT_DIR}" -DENABLE_MPI=ON \
        -DENABLE_TESTS=OFF "${SOURCEDIR}/${FIAT_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY BUILD FIAT WITH ECBUILD"
    else
	    error "==> FAILED TO BUILD FIAT WITH ECBUILD"
        exit 1
    fi 

    # Make FIAT.
    info "==>\t MAKE.."
    make -j16 2>&1 | tee "${BUILDDIR}/fiat.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE FIAT"
    else
	    error "==> FAILED TO MAKE FIAT"
        exit 1
    fi

    # Install FIAT.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/fiat.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL FIAT"
    else
	    error "==> FAILED TO MAKE INSTALL FIAT"
        exit 1
    fi 
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
        "${SOURCEDIR}/${ECTRANS_DIR}"
#        -DOpenMP_Fortran_FLAGS="-fopenacc" \
#        -DCMAKE_Fortran_FLAGS="-fopenacc" \
#        -DCMAKE_C_FLAGS="-fopenacc" \
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY BUILD ECTRANS WITH ECBUILD"
    else
	    error "==> FAILED TO BUILD ECTRANS WITH ECBUILD"
        exit 1
    fi 

    # Make ecTrans.
    info "==>\t MAKE (supposed to fail).."
    make -j32 2>&1 | tee "${BUILDDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY FIRST MAKE ECTRANS"
    else
	    error "==> FAILED TO FIRST MAKE ECTRANS"
        exit 1
    fi 

    info "==>\t MAKE (again, should succeed).."
    make -j32 2>&1 | tee -a "${BUILDDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY SECOND MAKE ECTRANS"
    else
	    error "==> FAILED TO SECOND MAKE ECTRANS"
        exit 1
    fi 

    # Install ecTrans.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL ECTRANS"
    else
	    error "==> FAILED TO MAKE INSTALL ECTRANS"
        exit 1
    fi 
}

# Build and Install source files.
build_install_all () {
    _build_install_ecbuild
    _build_install_eckit
    _build_install_fckit
    _build_install_fiat
    _build_install_ectrans
}

main () {
    # Set compilers for make/cmake.
    export FC90=ifort
    export FC=ifort
    export CC=nvcc
    export CXX=nvcc

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
                        "eckit")
                            info "==> install.sh:  Building eckit"
                            _build_install_eckit
                            ;;
                        "fckit")
                            info "==> install.sh:  Building fckit"
                            _build_install_fckit
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

