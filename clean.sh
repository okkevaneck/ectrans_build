#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file cleans up everything generated from installing ecTrans.
# ------------------------------------------------------------------------------

# Global color definitions.
NC='\033[0m'
GREEN='\033[1;32m'

# Display success styled message with given argument.
function success {
    echo -e "\n$GREEN \u2714 ~ $1$NC\n" 1>&2
}

# --

if [[ "$1" == "all" ]]; then
    rm -rf  sources/* build/* install/*
    success "Sucessfully cleaned ecTrans:  sources/ build/ install/"
elif [[ "$1" == "sources" ]]; then
    # If no arguments passed, clean all sources dirs.
    if [ $# -eq 1 ]; then
        rm -rf sources/*
        success "Sucessfully cleaned ecTrans:  sources/"
    else
        # Else remove specified folder.
        rm -rf "sources/$2"
        success "Sucessfully cleaned ecTrans:  sources/$2"
    fi
elif [[ "$1" == "build" ]]; then
    # If no arguments passed, clean all build dirs.
    if [ $# -eq 1 ]; then
        rm -rf build/*
        success "Sucessfully cleaned ecTrans:  build/"
    else
        # Else remove specified folder.
        rm -rf "build/$2"
        success "Sucessfully cleaned ecTrans:  build/$2"
    fi
elif [[ "$1" == "install" ]]; then
    # If no arguments passed, clean all installation dirs.
    if [ $# -eq 1 ]; then
        rm -rf install/*
        success "Sucessfully cleaned ecTrans:  install/"
    else
        # Else remove specified folder.
        rm -rf "install/$2"
        success "Sucessfully cleaned ecTrans:  install/$2"
    fi
else
    # Default to leaving the install/ dir as you can install different versions.
    rm -rf sources/* build/* 
    success "Sucessfully cleaned ecTrans:  sources/ build/"
fi
