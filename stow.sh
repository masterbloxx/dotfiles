#!/bin/sh

command -v stow >/dev/null 2>&1 || {
    echo 'Stow not found'
    exit 1
}

state=0

stow_special() {
    if [ -d "$arg/$1" ]; then
        mkdir -p "$2"
        stow --target="$2" --dir="$arg" --verbose $flags "$1"
    fi
}

for arg; do
    if [ "$(printf '%s' "$arg" | cut -c 1 --)" = '-' ]; then
        if [ $state -eq 1 ]; then
            flags+=" $arg"
        else
            state=1
            flags="$arg"
        fi
    else
        [ $state -eq 0 ] || state=0
        stow --target="$HOME" --ignore='_xdg_dir_.*' --verbose $flags "$arg"
        stow_special _xdg_dir_config "${XDG_CONFIG_HOME:-$HOME/.config}"
        stow_special _xdg_dir_data "${XDG_DATA_HOME:-$HOME/.local/share}"
        stow_special _xdg_dir_state "${XDG_STATE_HOME:-$HOME/.local/state}"
        stow_special _xdg_dir_cache "${XDG_CACHE_HOME:-$HOME/.cache}"
    fi
done

exit $state
