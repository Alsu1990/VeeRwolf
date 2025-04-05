#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script must be sourced. Use 'source scripts/set_venv.sh' or '. scripts/set_venv.sh'"
    return 1
fi

# getting os release
get_os() {
    if [ -f /etc/os-release ]; then
        uname=$(sh -c '. /etc/os-release && echo "$ID"')
    elif [ -f /usr/lib/os-release ]; then
        uname=$(sh -c '. /usr/lib/os-release && echo "$ID"')
    else
        echo "OS release cannot be determined" >&2
        return 1
    fi
    echo "$uname"
}

case $(get_os) in
ubuntu | darwin)
    base_python=$(which python3)
    ;;
debian)
    base_python="/tools/common/pkgs/pyenv/debian/versions/3.10.0/bin/python3"
    ;;
centos)
    base_python="/tools/common/pkgs/pyenv/centos/versions/3.10.0-with-openssl11/bin/python3"
    ;;
rhel)
    base_python="/tools/common/pkgs/pyenv/rhel8/versions/3.10.0/bin/python3"
    ;;
rocky)
    base_python="/tools/common/pkgs/pyenv/rocky9/versions/3.10.13/bin/python3"
    ;;
*)
    echo "INTERNAL ERROR" >/dev/stderr
    exit 1
    ;;
esac

if [ ! -f "${base_python}" ]; then
    base_python=$(which python3)

    if [ ! -f "${base_python}" ]; then
        echo "error: base python ${base_python} not found" >/dev/stderr
        exit 1
    fi
fi

python_version=$(${base_python} -V | cut -f2 -d" ")
python_major_version=$(echo "${python_version}" | cut -f1 -d.)
if [[ "${python_major_version}" != "3" ]]; then
    echo "error: could not find python 3" >/dev/stderr
    exit 1
fi

python_minor_version=$(echo "${python_version}" | cut -f2 -d.)
# if [[ "${python_minor_version}" -le 10 ]]; then
#     echo "error: unsupported python version: ${python_version}" >/dev/stderr
#     exit 1
# fi
echo "base python: ${base_python} (v${python_version})"

hostname=$(hostname -s)
venv_dir="$(pwd)/.venv_${hostname}"

if [[ ! -d "$venv_dir" ]]; then
    echo "Creating venv ${venv_dir}..."
    "$base_python" -m venv "$venv_dir"
    . "$venv_dir/bin/activate"
    echo "Activated new virtual environment: ${venv_dir}"
    pip install --upgrade pip
    pip install -r "requirements.txt"
else
    echo "venv ${venv_dir} already exists."
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "Deactivating current virtual environment: ${VIRTUAL_ENV}"
        deactivate
    fi
    . "$venv_dir/bin/activate"
    echo "Reactivated existing virtual environment: ${venv_dir}"
fi
