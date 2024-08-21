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
    info "==> PULLING ECBUILD" 2>&1 | tee "${SOURCEDIR}/ecbuild.log"
    git clone --branch "3.8.5" --single-branch \
        https://github.com/ecmwf/ecbuild.git "${ECBUILD_DIR}" 2>&1 \
        | tee -a "${SOURCEDIR}/ecbuild.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED ECBUILD" 2>&1 \
            | tee -a "${SOURCEDIR}/ecbuild.log"
    else
	    fatal "==> FAILED TO CLONE ECBUILD."
    fi 

    # Pull FIAT.
    info "==> PULLING FIAT" 2>&1 | tee "${SOURCEDIR}/fiat.log"
    git clone --branch "1.4.1" --single-branch \
        https://github.com/ecmwf-ifs/fiat.git "${FIAT_DIR}" 2>&1 \
        | tee -a "${SOURCEDIR}/fiat.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED FIAT" 2>&1 \
            | tee -a "${SOURCEDIR}/fiat.log"
    else
	    fatal "==> FAILED TO CLONE FIAT"
    fi

    # Pull the c8c5c61 commit of ecTrans.
    info "==> PULLING ECTRANS" 2>&1 | tee "${SOURCEDIR}/ectrans.log"
    mkdir -p ${ECTRANS_DIR}
    cd ${ECTRANS_DIR} || exit 1
    git init | tee -a "${SOURCEDIR}/ectrans.log"
    git remote add origin https://github.com/ecmwf-ifs/ectrans.git 2>&1 \
        | tee -a "${SOURCEDIR}/ectrans.log"
    git fetch --depth 1 origin c8c5c6100bb62b1d9ce15012a0722c0611992ae9 2>&1 \
        | tee -a "${SOURCEDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY CLONED ECTRANS"  2>&1\
            | tee -a "${SOURCEDIR}/ectrans.log"
    else
	    fatal "==> FAILED TO CLONE ECTRANS."
    fi 
    git checkout FETCH_HEAD 
    cd ..
}

# Build and install ecBuild.
_build_install_ecbuild () {
    # Build and Install ecBuild.
    info "==> INSTALLING ECBUILD.." 2>&1 | tee -a "${BUILDDIR}/ecbuild.log"
    cd "${SOURCEDIR}/${ECBUILD_DIR}" || exit 1

    # Create build directory and build ecBuild.
    rm -rf "${BUILDDIR:?}/${ECBUILD_DIR:?}" "${INSTALLDIR:?}/${ECBUILD_DIR:?}"
    mkdir -p "${BUILDDIR}/${ECBUILD_DIR}"
    cd "${BUILDDIR}/${ECBUILD_DIR}" || exit 1
    info "==>\t ECBUILD.." 2>&1 | tee -a "${BUILDDIR}/ecbuild.log"
    "${SOURCEDIR}/${ECBUILD_DIR}/bin/ecbuild" \
        --prefix="${INSTALLDIR}/${ECBUILD_DIR}" \
        "${SOURCEDIR}/${ECBUILD_DIR}" | tee "${BUILDDIR}/ecbuild.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY BUILD ECBUILD WITH ECBUILD" \
            | tee -a "${BUILDDIR}/ecbuild.log"
    else
	    fatal "==> FAILED TO BUILD ECBUILD WITH ECBUILD"
    fi 

    # Make ecBuild.
    info "==>\t MAKE.." 2>&1 | tee -a "${BUILDDIR}/ecbuild.log"
    make 2>&1 | tee -a "${BUILDDIR}/ecbuild.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE ECBUILD" \
            | tee -a "${BUILDDIR}/ecbuild.log"
    else
	    fatal "==> FAILED TO MAKE ECBUILD"
    fi 

    # Install ecBuild.
    info "==>\t MAKE INSTALL.."
    make install 2>&1 | tee "${INSTALLDIR}/ecbuild.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL ECBUILD" 2>&1 \
            | tee -a "${INSTALLDIR}/ecbuild.log"
    else
	    fatal "==> FAILED TO MAKE INSTALL ECBUILD"
    fi 
}

# Build and install FIAT.
_build_install_fiat () {
    # Build and Install FIAT.
    info "==> INSTALLING FIAT.." 2>&1 | tee -a "${BUILDDIR}/fiat.log"
    cd "${SOURCEDIR}/${FIAT_DIR}" || exit 1
    
    # Create build directory and build FIAT.
    rm -rf "${BUILDDIR:?}/${FIAT_DIR:?}" "${INSTALLDIR:?}/${FIAT_DIR:?}"
    mkdir -p "${BUILDDIR}/${FIAT_DIR}"
    cd "${BUILDDIR}/${FIAT_DIR}" || exit 1
    info "==>\t ECBUILD.." 2>&1 | tee -a "${BUILDDIR}/fiat.log"
    ecbuild -DCMAKE_INSTALL_PREFIX="${INSTALLDIR}/${FIAT_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_MPI=ON \
        -DENABLE_TESTS=OFF \
        "${SOURCEDIR}/${FIAT_DIR}" | tee "${BUILDDIR}/fiat.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY BUILD FIAT WITH ECBUILD" \
            | tee -a "${BUILDDIR}/fiat.log"
    else
	    fatal "==> FAILED TO BUILD FIAT WITH ECBUILD"
    fi 

    # Make FIAT.
    info "==>\t MAKE.." 2>&1 | tee -a "${BUILDDIR}/fiat.log"
    make 2>&1 | tee -a "${BUILDDIR}/fiat.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE FIAT" 2>&1 | tee -a "${BUILDDIR}/fiat.log"
    else
	    fatal "==> FAILED TO MAKE FIAT"
    fi

    # Install FIAT.
    info "==>\t MAKE INSTALL.." 2>&1 | tee "${INSTALLDIR}/fiat.log"
    make install 2>&1 | tee "${INSTALLDIR}/fiat.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL FIAT" \
            | tee -a "${INSTALLDIR}/fiat.log"
    else
	    fatal "==> FAILED TO MAKE INSTALL FIAT"
    fi 
}

# Build and install ecTrans.
_build_install_ectrans () {
    # Build and Install ecTrans.
    info "==> Installing ecTrans.." 2>&1 | tee -a "${BUILDDIR}/ectrans.log"

    # Create build directory and build ecTrans.
    rm -rf "${BUILDDIR:?}/${ECTRANS_DIR:?}" "${INSTALLDIR:?}/${ECTRANS_DIR:?}"
    mkdir -p "${BUILDDIR}/${ECTRANS_DIR}"
    cd "${BUILDDIR}/${ECTRANS_DIR}" || exit 1
    info "==>\t ECBUILD.." 2>&1 | tee -a "${BUILDDIR}/ectrans.log"
    BUILD_GPU="ON"
    ecbuild -DCMAKE_INSTALL_PREFIX="${INSTALLDIR}/${ECTRANS_DIR}" \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DENABLE_TESTS=OFF \
        -DENABLE_SINGLE_PRECISION=OFF \
        -DENABLE_DOUBLE_PRECISION=ON \
        -DENABLE_TRANSI=ON \
        -DENABLE_MKL=OFF \
        -DENABLE_FFTW=ON \
        -DENABLE_GPU=$BUILD_GPU \
        -DENABLE_GPU_AWARE_MPI=$BUILD_GPU \
        -DENABLE_GPU_GRAPHS_GEMM=$BUILD_GPU \
        -DENABLE_CUTLASS=OFF \
        -DENABLE_3XTF32=OFF \
        -Dfiat_ROOT="${INSTALLDIR}/${FIAT_DIR}" \
        "${SOURCEDIR}/${ECTRANS_DIR}" 2>&1 | tee "${BUILDDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY BUILD ECTRANS WITH ECBUILD" 2>&1 \
            | tee -a "${BUILDDIR}/ectrans.log"
    else
	    fatal "==> FAILED TO BUILD ECTRANS WITH ECBUILD"
    fi 

    # Make ecTrans.
    info "==>\t MAKE.." 2>&1 | tee -a "${BUILDDIR}/ectrans.log"
    make 2>&1 | tee -a "${BUILDDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE ECTRANS" 2>&1 \
            | tee -a "${BUILDDIR}/ectrans.log"
    else
	    fatal "==> FAILED TO MAKE ECTRANS"
    fi

    # Install ecTrans.
    info "==>\t MAKE INSTALL.." 2>&1 | tee -a "${INSTALLDIR}/ectrans.log"
    make install 2>&1 | tee "${INSTALLDIR}/ectrans.log"
    retval=$?
    if [[ $retval -eq 0 ]]; then
    	success "==> SUCCESFULLY MAKE INSTALL ECTRANS" 2>&1 \
            | tee -a "${INSTALLDIR}/ectrans.log"
    else
	    fatal "==> FAILED TO MAKE INSTALL ECTRANS"
    fi 
}

# Build and install source files.
build_install_all () {
    _build_install_ecbuild
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
            module load LUMI/23.03 partition/G PrgEnv-cray \
                cpe/23.09 craype-x86-trento craype-accel-amd-gfx90a
            module load cray-mpich cray-libsci cray-fftw cray-python
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
            # Setup required modules.
            module load \
                git \
                cmake/3.27.7 \
                nvhpc/24.3 \
                fftw/3.3.10--openmpi--4.1.6--nvhpc--24.3

            # Set compilers for make/cmake.
            export FC90=nvfortran
            export FC=nvfortran
            export CC=nvc
            export CXX=nvc++
            ;;
        "mn5")
            # Setup required modules.
            module load \
                cmake/3.29.2 EB/apps \
                nvidia-hpc-sdk/24.3 \
                fftw/3.3.10-gcc-nvhpcx

            # Set compilers for make/cmake.
            export FC90=nvfortran
            export FC=nvfortran
            export CC=nvc
            export CXX=nvc++
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
    module list 2>&1 | tee "modules.log"
}

main () {
    # Detect machine, set variables, and load modules.
    info "==> install.sh:  Detecting machine and setting up environment.."
    detect_and_load_machine $1
    success "==> install.sh:  Succesfully set up environment."

    # Export paths for linking the libraries.
    export BIN_PATH="${INSTALLDIR}/${ECBUILD_DIR}/bin"
    export INCLUDE_PATH="${INSTALLDIR}/${ECBUILD_DIR}/include"
    export ECBUILD_PATH="${INSTALLDIR}/${ECBUILD_DIR}/"
    export FCKIT_PATH="${INSTALLDIR}/${FIAT_DIR}/"

    # Extend LIB_PATH with each component.
    export LIB_PATH="${LIB_PATH}:${INSTALLDIR}/${ECBUILD_DIR}/lib:${INSTALLDIR}/${ECBUILD_DIR}/lib64"
    export LIB_PATH="${LIB_PATH}:${INSTALLDIR}/${FIAT_DIR}/lib:${INSTALLDIR}/${FIAT_DIR}/lib64"

    # Extend PATH with bin paths.
    export PATH="${PATH}:${INSTALLDIR}/${ECBUILD_DIR}/bin/"
    export PATH="${PATH}:${INSTALLDIR}/${FIAT_DIR}/bin/"

    # Create directories for the installation process.
    mkdir -p "${SOURCEDIR}" "${BUILDDIR}" "${INSTALLDIR}"

    # If no arguments passed, download, build, and install everything.
    if [ $# -le 1 ]; then
        info "==> install.sh:  No arguments given, so doing complete new install.."
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
                    info "==> install.sh:  Instruction '$instruction' not found.."
                    ;;
                esac
        done
    fi
}

# Call main as entrypoint of script.
main "$@"
