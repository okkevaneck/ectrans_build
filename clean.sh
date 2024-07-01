#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file cleans up everything generated from installing ecTrans.
# ------------------------------------------------------------------------------

# Load helpers for color printing.
source helpers/helpers.sh

# Load directory structure for installation paths.
source helpers/dirs.sh


if [[ "$1" == "all" ]]; then
    rm -rf  "${SOURCEDIR:?}"/* "${BUILDDIR:?}"/* "${INSTALLDIR:?}"/*
    success "Sucessfully cleaned ecTrans:  sources/ build/ install/"
elif [[ "$1" == "sources" ]]; then
    # If no arguments passed, clean all sources dirs.
    if [ $# -eq 1 ]; then
        rm -rf "${SOURCEDIR:?}"/*
        success "Sucessfully cleaned ecTrans:  sources/"
    else
        # Else remove specified folder.
        rm -rf "${SOURCEDIR:?}/$2"
        success "Sucessfully cleaned ecTrans:  sources/$2"
    fi
elif [[ "$1" == "build" ]]; then
    # If no arguments passed, clean all build dirs.
    if [ $# -eq 1 ]; then
        rm -rf "${BUILDDIR:?}"/*
        success "Sucessfully cleaned ecTrans:  build/"
    else
        # Else remove specified folder.
        rm -rf "${BUILDDIR:?}/$2"
        success "Sucessfully cleaned ecTrans:  build/$2"
    fi
elif [[ "$1" == "install" ]]; then
    # If no arguments passed, clean all installation dirs.
    if [ $# -eq 1 ]; then
        rm -rf "${INSTALLDIR:?}"/*
        success "Sucessfully cleaned ecTrans:  install/"
    else
        # Else remove specified folder.
        rm -rf "${INSTALLDIR:?}/$2"
        success "Sucessfully cleaned ecTrans:  install/$2"
    fi
else
    # Default to leaving the install dir as you can install different versions.
    rm -rf "${SOURCEDIR:?}"/* "${BUILDDIR:?}"/* 
    success "Sucessfully cleaned ecTrans:  sources/ build/"
fi
