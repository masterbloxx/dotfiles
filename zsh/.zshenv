typeset -U PATH path FPATH fpath

if [[ $OSTYPE = darwin* ]]; then
    if [[ -o login && -x /usr/libexec/path_helper ]]; then
        eval "$(/usr/libexec/path_helper -s)"
        unsetopt global_rcs
    fi
    case "$(uname -m)" in
        arm64)
            if [[ -x /opt/homebrew/bin/brew ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
                fpath=(/opt/homebrew/share/zsh/site-functions "${fpath[@]}")
            fi
            ;;
        x86_64)
            if [[ -x /usr/local/bin/brew ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
                fpath=(/usr/local/share/zsh/site-functions "${fpath[@]}")
            fi
            ;;
    esac
    [[ -o interactive && $TERM_PROGRAM = Apple_Terminal ]] && SHELL_SESSIONS_DISABLE=1
fi

append_to_path() {
    if [[ -d $1 ]]; then path+=("$1"); fi
}

prepend_to_path() {
    if [[ -d $1 ]]; then path=("$1" "${path[@]}"); fi
}

prepend_to_path "$HOME/.local/bin"

ZDOTDIR=${XDG_CONFIG_HOME:-$HOME/.config}/zsh

source_if_readable() {
    if [[ -r $1 ]]; then . "$1"; fi
}

source_if_readable "$ZDOTDIR/local/env"

if [[ -o login || -o interactive ]]; then
    zsh_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
    zsh_state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/zsh
    zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
    mkdir -p "$zsh_data_dir" "$zsh_state_dir" "$zsh_cache_dir"
    [[ -o interactive ]] && mkdir -p "$ZDOTDIR/local"
fi
