#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file downloads, builds, and installs the ecTrans dwarf.
# When installing, pass a supported supercomputer name as the first argument,
#   e.g. "./install lumi". Options are [lumi|leonardo|mn5].
# ------------------------------------------------------------------------------

# Set pipefail to capture non-zero exit codes when also writing to logs.
set -o pipefail

# Load helpers for color printing.
source helpers/helpers.sh

# Load directory structure for installation paths.
source helpers/dirs.sh


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
	    fatal "==> FAILED TO CLONE ECBUILD\n\tMake sure you're on login4."
    fi 

    # Pull eckit.
    git clone --branch "1.26.4" --single-branch \
        https://github.com/ecmwf/eckit.git "${ECKIT_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED ECKIT"
    else
	    fatal "==> FAILED TO CLONE ECKIT\n\tMake sure you're on login4."
    fi 

    # Pull fckit.
    git clone --branch "0.9.0" --single-branch \
        https://github.com/ecmwf/fckit.git "${FCKIT_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED FCKIT"
    else
	    fatal "==> FAILED TO CLONE FCKIT\n\tMake sure you're on login4."
    fi 
    
    # Pull FIAT.
    git clone --branch "1.4.1" --single-branch \
        https://github.com/ecmwf-ifs/fiat.git "${FIAT_DIR}"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED FIAT"
    else
	    fatal "==> FAILED TO CLONE FIAT\n\tMake sure you're on login4."
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
	    fatal "==> FAILED TO CLONE ECTRANS\n\tMake sure you're on login4."
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
	    fatal "==> FAILED TO BUILD ECBUILD WITH ECBUILD"
    fi 

    # Make ecBuild.
    info "==>\t MAKE.."
    make 2>&1 | tee "${BUILDDIR}/ecbuild.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE ECBUILD"
    else
	    fatal "==> FAILED TO MAKE ECBUILD"
    fi 

    # Install ecBuild.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/ecbuild.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL ECBUILD"
    else
	    fatal "==> FAILED TO MAKE INSTALL ECBUILD"
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
	    fatal "==> FAILED TO BUILD ECKIT WITH ECBUILD"
    fi 

    # Make eckit.
    info "==>\t MAKE.."
    make -j10 2>&1 | tee "${BUILDDIR}/eckit.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE ECKIT"
    else
	    fatal "==> FAILED TO MAKE ECKIT"
    fi

    # Install eckit.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/eckit.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL ECKIT"
    else
	    fatal "==> FAILED TO MAKE INSTALL ECKIT"
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
	    fatal "==> FAILED TO BUILD FCKIT WITH ECBUILD"
    fi 

    # Make fckit.
    info "==>\t MAKE.."
    make 2>&1 | tee "${BUILDDIR}/fckit.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE FCKIT"
    else
	    fatal "==> FAILED TO MAKE FCKIT"
    fi

    # Install fckit.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/fckit.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL FCKIT"
    else
	    fatal "==> FAILED TO MAKE INSTALL FCKIT"
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
	    fatal "==> FAILED TO BUILD FIAT WITH ECBUILD"
    fi 

    # Make FIAT.
    info "==>\t MAKE.."
    make 2>&1 | tee "${BUILDDIR}/fiat.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE FIAT"
    else
	    fatal "==> FAILED TO MAKE FIAT"
    fi

    # Install FIAT.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/fiat.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL FIAT"
    else
	    fatal "==> FAILED TO MAKE INSTALL FIAT"
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
        -DENABLE_CPU=ON -DENABLE_ETRANS=ON -DENABLE_DOUBLE_PRECISION=ON \
        -DENABLE_SINGLE_PRECISION=OFF \
        "${SOURCEDIR}/${ECTRANS_DIR}"
#        -DOpenMP_Fortran_FLAGS="-fopenacc" \
#        -DCMAKE_Fortran_FLAGS="-fopenacc" \
#        -DCMAKE_C_FLAGS="-fopenacc" \
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY BUILD ECTRANS WITH ECBUILD"
    else
	    fatal "==> FAILED TO BUILD ECTRANS WITH ECBUILD"
    fi 

    # Make ecTrans.
    info "==>\t MAKE (supposed to fail).."
    make -j32 2>&1 | tee "${BUILDDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY FIRST MAKE ECTRANS\n\tExpected to fail.."
    else
	    info "==> FAILED TO FIRST MAKE ECTRANS\n\tAs expected!"
    fi 

    info "==>\t MAKE (again, should succeed).."
    make -j32 2>&1 | tee -a "${BUILDDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY SECOND MAKE ECTRANS"
    else
	    fatal "==> FAILED TO SECOND MAKE ECTRANS"
    fi 

    # Install ecTrans.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL ECTRANS"
    else
	    fatal "==> FAILED TO MAKE INSTALL ECTRANS"
    fi 
}

# Build and install source files.
build_install_all () {
    _build_install_ecbuild
    _build_install_eckit
    _build_install_fckit
    _build_install_fiat
    _build_install_ectrans
}

# Parse what supercomputer to install on, set required variables and load 
# modules. First argument is the name of the supercomputer.
detect_and_load_machine() {
    #First arg is machine name.
    machine=$1
    
    # Parse machine name and act accordingly.
    case $machine in
        "lumi")
            # Load modules.
            module purge
            module load LUMI/23.03 partition/G PrgEnv-cray cpe/23.09 craype-x86-trento \
                craype-accel-amd-gfx90a
            module load cray-mpich cray-libsci cray-fftw cray-python
            module load cray-hdf5-parallel cray-netcdf-hdf5parallel
            module load buildtools
            module load rocm/5.2.3

            # Set compilers for make/cmake.
            export FC90=ftn
            export FC=ftn
            export CC=cc
            export CXX=cc

            # Set toolchain.
            export TOOLCHAIN_FILE=${BASEDIR}/../toolchains/toolchain_lumi.cmake
            export ECBUILD_TOOLCHAIN="${TOOLCHAIN_FILE}"
            ;;
        "leonardo")
            ;;
        "mn5")
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

            # Set compilers for make/cmake.
            export FC90=ifort
            export FC=ifort
            export CC=nvcc
            export CXX=nvcc
            ;;
        *)
            fatal "Passed argument '$machine' not in [lumi|leonardo|mn5]."
            ;;
    esac

    # Assert that the required variables are set.
    if [ -z "$FC90" ] || [ -z "$FC" ] || [ -z "$CC" ] || [ -z "$CXX" ]; then
        fatal "Not all compilers are set in 'detect_and_load_machine()'."
        exit 1
    fi

    # Output loaded modules to log.
    module list 2>&1 | tee "install.log"
}

main () {
    # Detect machine, set variables, and load modules.
    detect_and_load_machine $1

    # Export paths for linking the libraries.
    export BIN_PATH="${INSTALLDIR}/${ECBUILD_DIR}/bin"
    export INCLUDE_PATH="${INSTALLDIR}/${ECBUILD_DIR}/include"
    export INSTALL_PATH="${INSTALLDIR}/${ECBUILD_DIR}/"
    export ECBUILD_PATH="${INSTALLDIR}/${ECBUILD_DIR}/"
    export ECKIT_PATH="${INSTALLDIR}/${ECKIT_DIR}/"
    export FCKIT_PATH="${INSTALLDIR}/${FCKIT_DIR}/"
    export FCKIT_PATH="${INSTALLDIR}/${FIAT_DIR}/"

    # Extend LIB_PATH with each component.
    export LIB_PATH="${LIB_PATH}:${INSTALLDIR}/${ECBUILD_DIR}/lib:${INSTALLDIR}/${ECBUILD_DIR}/lib64"
    export LIB_PATH="${LIB_PATH}:${INSTALLDIR}/${ECKIT_DIR}/lib:${INSTALLDIR}/${ECKIT_DIR}/lib64"
    export LIB_PATH="${LIB_PATH}:${INSTALLDIR}/${FCKIT_DIR}/lib:${INSTALLDIR}/${FCKIT_DIR}/lib64"
    export LIB_PATH="${LIB_PATH}:${INSTALLDIR}/${FIAT_DIR}/lib:${INSTALLDIR}/${FIAT_DIR}/lib64"

    # Extend PATH with bin paths.
    export PATH="${PATH}:${INSTALLDIR}/${ECBUILD_DIR}/bin/"
    export PATH="${PATH}:${INSTALLDIR}/${ECKIT_DIR}/bin/"
    export PATH="${PATH}:${INSTALLDIR}/${FCKIT_DIR}/bin/"
    export PATH="${PATH}:${INSTALLDIR}/${FIAT_DIR}/bin/"

    # Create directories for the installation process.
    mkdir -p "${SOURCEDIR}" "${BUILDDIR}" "${INSTALLDIR}"

    # If no arguments passed, download, build, and install everything.
    if [ $# -le 1 ]; then
        info "No arguments given, so doing complete new install.."
        ./clean.sh all
        download
        build_install_all
    else
        # Else parse all other passed arguments.
        for var in "${@:2}"; do
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
