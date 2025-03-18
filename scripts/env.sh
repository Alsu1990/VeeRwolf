#!/bin/bash

# set -e
scripts_dir=$(dirname -- "${BASH_SOURCE[0]}")

if [[ ":$PATH:" != *":$scripts_dir:"* ]]; then
    echo "Adding $scripts_dir to PATH"
    export PATH="$scripts_dir:$PATH"
fi

# setup python virtual environment
. "${scripts_dir}/set_venv.sh"

export VEERWOLF_ROOT=$(pwd)
export PERL5LIB="${HOME}/perl5/lib/perl5:${PERL5LIB}"

fusesoc_add_lib.sh fusesoc-cores https://github.com/fusesoc/fusesoc-cores
fusesoc_add_lib.sh veerwolf .

# fusesoc library add fusesoc-cores https://github.com/fusesoc/fusesoc-cores
# fusesoc library add veerwolf .

# Make clangd happy
CPATH=$(find "$(pwd)" -type f \( -name "*.h" -o -name "*.hpp" \) -exec dirname {} \; | sort -u | tr '\n' ':')
CPATH="$VERILATOR_ROOT/include:$CPATH"
export CPATH
