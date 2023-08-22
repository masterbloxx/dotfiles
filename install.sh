#!/bin/sh

__rm() {
    rm -Rf "$1" || exit
}

__mkdir() {
    mkdir -p "$1" || exit
}

__cp() {
    cp -R "$1" "$2" || exit
}

__ln() {
    ln -s "$1" "$2" || exit
}

__script_dir="$(pwd)"

__xdg_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
__xdg_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}"
__xdg_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
__xdg_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"

for arg; do
    case "$arg" in
        zsh)
            __rm "$HOME/.zshenv"
            __rm "$__xdg_config_dir/zsh"
            __rm "$__xdg_data_dir/zsh"
            __rm "$__xdg_state_dir/zsh"
            __rm "$__xdg_cache_dir/zsh"
            __mkdir "$__xdg_config_dir/zsh"
            __ln "$__script_dir/zsh/zshenv" "$__xdg_config_dir/zsh/.zshenv"
            __ln "$__script_dir/zsh/zprofile" "$__xdg_config_dir/zsh/.zprofile"
            __ln "$__script_dir/zsh/zshrc" "$__xdg_config_dir/zsh/.zshrc"
            __ln "$__script_dir/zsh/zlogin" "$__xdg_config_dir/zsh/.zlogin"
            __ln "$__script_dir/zsh/functions" "$__xdg_config_dir/zsh/."
            __ln "$__xdg_config_dir/zsh/.zshenv" "$HOME/."
            ;;
    esac
done
