#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file downloads, builds, and installs the ecTrans dwarf.
# ------------------------------------------------------------------------------

# Load helpers for color printing.
source helpers/helpers.sh

# Load directory structure for installation paths.
source helpers/dirs.sh

# Setup required modules.
source helpers/load_modules.sh

# ---

# Remove source and build files, and download fresh version.
download () {
    # Remove sources/ and build/
    ./clean.sh

    # Pull ecTrans.
    info "==> PULLING ECTRANS"
    cd ${SOURCEDIR}
    # git clone --branch alaro_ectrans https://github.com/ddegrauwe/ectrans.git
    git clone https://github.com/OkkeVanEck/ectrans.git
    success "==> SUCCESFULLY CLONED ECTRANS"

    # Pull ecBuild.
    git clone --branch "3.8.2" https://github.com/ecmwf/ecbuild.git
    success "==> SUCCESFULLY CLONED ECBUILD"

    # Pull FIAT.
    git clone --branch "1.2.0" https://github.com/ecmwf-ifs/fiat
    success "==> SUCCESFULLY CLONED FIAT"
}

# Build and install ecBuild.
_build_install_ecbuild () {
    # Build and Install ecBuild.
    info "==> INSTALLING ECBUILD.."
    cd ${SOURCEDIR}/ecbuild

    # Remove obsolete switch '-Gfast'.
    sed -i -e "s/-Gfast//" cmake/compiler_flags/Cray_Fortran.cmake
    
    # Create build directory and build ecBuild.
    mkdir -p ${BUILDDIR}/ecbuild
    cd ${BUILDDIR}/ecbuild
    info "==>\t ECBUILD.."
    ${SOURCEDIR}/ecbuild/bin/ecbuild --prefix=${INSTALLDIR}/ecbuild ${SOURCEDIR}/ecbuild
    info "==>\t MAKE.."
    make

    # Install ecBuild.
    info "==>\t MAKE INSTALL.."
    make install
    success "==> SUCCESFULLY INSTALLED ECBUILD"
}

# Build and install FIAT.
_build_install_fiat () {
    # Build and Install FIAT.
    info "==> INSTALLING FIAT.."
    cd ${SOURCEDIR}/fiat
    # small fix to include OpenMP in linking of C programs
    sed -i -e "s/target_link_libraries( fiat-printbinding OpenMP::OpenMP_C )/target_link_libraries( fiat-printbinding \$\{OpenMP_C_FLAGS\} OpenMP::OpenMP_C )/" src/programs/CMakeLists.txt
    
    # Create build directory and build FIAT.
    rm -rf ${BUILDDIR}/${FIAT_DIR}
    mkdir -p ${BUILDDIR}/${FIAT_DIR}
    cd ${BUILDDIR}/${FIAT_DIR}
    info "==>\t ECBUILD.."
    ecbuild -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=${INSTALLDIR}/${FIAT_DIR} -DENABLE_MPI=ON -DBUILD_SHARED_LIBS=OFF -DENABLE_TESTS=OFF ${SOURCEDIR}/fiat
    info "==>\t MAKE.."
    make -j16

    # Install FIAT.
    info "==>\t MAKE INSTALL.."
    make install
    success "==> SUCCESFULLY INSTALLED FIAT"
}

# Build and install ecTrans.
_build_install_ectrans () {
    # Build and Install ecTrans.
    info "==> Installing ecTrans.."

    # Create build directory and build ecTrans.
    rm -rf ${BUILDDIR}/${ECTRANS_DIR} ${INSTALLDIR}/${ECTRANS_DIR}
    mkdir -p ${BUILDDIR}/${ECTRANS_DIR}
    cd ${BUILDDIR}/${ECTRANS_DIR}
    info "==>\t ECBUILD.."
    ecbuild --prefix=${INSTALLDIR}/${ECTRANS_DIR} -DCMAKE_BUILD_TYPE=RelWithDebInfo -Dfiat_ROOT=${INSTALLDIR}/${FIAT_DIR} -DBUILD_SHARED_LIBS=OFF -DENABLE_FFTW=OFF -DENABLE_GPU=ON -DENABLE_OMPGPU=OFF -DENABLE_ACCGPU=ON -DENABLE_TESTS=OFF -DENABLE_GPU_AWARE_MPI=ON -DENABLE_CPU=ON -DENABLE_ETRANS=ON  -DENABLE_DOUBLE_PRECISION=ON -DENABLE_SINGLE_PRECISION=OFF ${SOURCEDIR}/ectrans
    info "==>\t MAKE (supposed to fail).."
    make LIBRARY_PATH=/opt/cray/pe/cce/16.0.1/cce-clang/x86_64/lib -j32
    # Make needs to be executed twice as the first time it somehow fails.
    info "==>\t MAKE (again, should succeed).."
    make LIBRARY_PATH=/opt/cray/pe/cce/16.0.1/cce-clang/x86_64/lib -j32

    # Install ecTrans.
    info "==>\t MAKE INSTALL.."
    make install
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
    export FC90=ftn
    export FC=ftn
    export CC=cc
    export CXX=CC

    # Export environment variables used during installation.
    export PATH=${PATH}:${INSTALLDIR}/ecbuild/bin/
    export TOOLCHAIN_FILE=${SOURCEDIR}/ectrans/toolchain_lumi.cmake
    export ECBUILD_TOOLCHAIN="${TOOLCHAIN_FILE}"

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
