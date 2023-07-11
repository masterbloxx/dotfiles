command_exists() {
    command -v $1 &>/dev/null
}

command_exists nvim && export VISUAL=nvim

if command_exists fzf; then
    export FZF_DEFAULT_OPTS='--no-info --color=fg+:-1,bg+:-1,prompt:green,pointer:cyan'
    command_exists fd && export FZF_DEFAULT_COMMAND='fd --type file --strip-cwd-prefix'
fi

setopt auto_cd \
    hist_ignore_all_dups \
    hist_ignore_space \
    list_packed \
    list_rows_first \
    menu_complete \
    prompt_subst \
    transient_rprompt

unsetopt beep

HISTFILE=$zsh_state_dir/history
HISTSIZE=40000
SAVEHIST=40000

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats '%F{magenta}%b%f%F{white}%u%f%F{green}%c%f'
zstyle ':vcs_info:git:*' actionformats '%F{magenta}%b%f%F{white}%u%f%F{green}%c%f %F{yellow}%a%f'

autoload -Uz vcs_info && precmd_functions+=(vcs_info)

if [[ -v SSH_CONNECTION ]]; then
    PROMPT=$'\n%F{yellow}%n%f%F{green}@%f%F{blue}%m%f %F{cyan}%4~%f $vcs_info_msg_0_\n%F{%(?.green.red)}%(!.#.\u276F)%f '
else
    PROMPT=$'%F{cyan}%3~%f %F{%(?.green.red)}%(!.#.\u276F)%f '
    RPROMPT='$vcs_info_msg_0_'
fi

command_exists rg && alias grep=rg

if command_exists exa; then
    alias ls=exa
    alias la='exa -a'
    alias ll='exa -la'
else
    alias la='ls -A'
    alias ll='ls -lA'
fi

typeset -a zsh_plugins

use_plugin() {
    local plugin_dir=$zsh_data_dir/plugins/${1//[:.\/]/_}
    if [[ ! -d $plugin_dir/.git ]]; then
        rm -rf "$plugin_dir"
        git clone --depth 1 $1.git "$plugin_dir" || return
        use_plugin $1
    fi
    source_if_readable "$plugin_dir/${1:t}.plugin.zsh"
    zsh_plugins+=($1)
}

use_plugin https://github.com/zsh-users/zsh-completions
use_plugin https://github.com/zdharma-continuum/fast-syntax-highlighting

fpath+=("$ZDOTDIR/functions")

autoload -Uz update_plugins

zmodload -e zsh/complist || zmodload zsh/complist

zstyle ':completion:*' menu select
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' complete-options true
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$zsh_cache_dir/compcache-$ZSH_VERSION"

autoload -Uz compinit && compinit -d "$zsh_cache_dir/compdump-$ZSH_VERSION"

KEYTIMEOUT=1

bindkey -v

bindkey '^?' backward-delete-char
bindkey '^E' end-of-line

bindkey -M menuselect '^[' send-break
bindkey -M menuselect '^[[Z' reverse-menu-complete

if command_exists fzf; then
    autoload -Uz fzf-history-search
    zle -N fzf-history-search
    bindkey '^F' fzf-history-search
    bindkey -a '^F' fzf-history-search
    if command_exists nvim; then
        autoload -Uz fzf-nvim-open
        zle -N fzf-nvim-open
        bindkey '^O' fzf-nvim-open
        bindkey -a '^O' fzf-nvim-open
    fi
fi

source_if_readable "$ZDOTDIR/local/interactive"
