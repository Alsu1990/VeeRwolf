# Function to add a FuseSoC library
fusesoc_add_lib() {
    local _lib="$1"
    local _url="$2"

    if [[ -z "$_lib" || -z "$_url" ]]; then
        echo "Usage: add_fusesoc_lib <lib> <url>"
        return 1
    fi

    if fusesoc_lib_in_cfg "fusesoc.conf" "$_lib"; then
        return 0
    else
        echo "Adding library $_lib"
        fusesoc library add "$_lib" "$_url"
    fi

}

# Function to check if a FuseSoC library is already in the configuration
fusesoc_lib_in_cfg() {
    local _config="$1"
    local _lib="$2"

    if [[ ! -f "$_config" ]]; then
        return 1
    fi
    if grep -q "$_lib" "$_config"; then
        echo "Library $_lib already in $_config"
        return 0
    fi
    return 1
}

lib="$1"
url="$2"

fusesoc_add_lib "$lib" "$url"
