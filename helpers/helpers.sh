#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# This file contains helper functions usefull in other scripts.
# ------------------------------------------------------------------------------

# Global color definitions.
NC='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'

# Display fatal styled message with given argument.
function fatal {
    echo -e "\n$RED \u274c FATAL: $1$NC\n" 1>&2
    exit 1
}

# Display success styled message with given argument.
function success {
    echo -e "\n$GREEN \u2714 ~ $1$NC\n" 1>&2
}

# Display info styled message with given argument.
function info {
    echo -e "\n$YELLOW \u003F ~ $1$NC\n" 1>&2
}

