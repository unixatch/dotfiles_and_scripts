#!/bin/bash

ulimit -n 1000      # max amount of file descriptors
ulimit -R 300000000 # real-time non-blocking time, 5 minutes
ulimit -m 4000000   # max memory size: 4GB in kB
ulimit -f 4000000   # file size:       2,048GB in 512 blocks
ulimit -u 1250      # amount of processes

trashCleanupTimeFile=~/.trash_cleanup_time
[[ -f $trashCleanupTimeFile ]] && {
    mapfile -t time < "$trashCleanupTimeFile"
    # Enough time has passed
    (( EPOCHSECONDS > time )) && {
        shopt -s nullglob
        # Runs only if something exists in the trash
        [[ "${ echo ~/.trash/* ~/.trash/.*; }" ]] && (
            rm --preserve-root=all \
               --recursive \
               --force \
               ~/.trash/* ~/.trash/.* \
               "$trashCleanupTimeFile" &>/dev/null &
        )
        shopt -u nullglob
        cleanupMsg="\n\e[107;38;5;232;1m Cleaning up the trash bin in the background... 🚮 \e[0m\n"
    }
    unset time
}

# Load functions
# shellcheck source=./.bash_functions
. ~/.bash_functions

# Limit nesting of functions
export FUNCNEST=10

# Man pages
export LESS_TERMCAP_mb=$'\e[1m'     # blink
export LESS_TERMCAP_md=$'\e[32m'    # bold
export LESS_TERMCAP_so=$'\e[33;44m' # standout
export LESS_TERMCAP_us=$'\e[4;31m'  # underline

export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
# Begin reverse-video mode
export LESS_TERMCAP_mr=$'\e[7m'
# Begin dim/half-bright mode
export LESS_TERMCAP_mh=$'\e[2m'

export PROMPT_DIRTRIM=3
# shellcheck disable=2168
${
    local SOFT_TERMINAL_RESET='\[\033[\041p\]'
    local EXIT_INSERT_MODE='\[\033[4l\]'
    local NORMAL_KEYPAD='\[\033>\]'
    local CLEAR_MARGINS='\[\033[?69l\]'

    # shellcheck disable=SC2016
    local EXIT_CODE='\[\033[31;4m\]${ promptExitCode $? && printf "\[\033[0m\] "; }\[\033[0m\]'
    local NORMAL='\[\033[0m\]'
    local START_COLOR='\[\033[48;2;0;0;100;38;2;227;227;227m\]'
    local CLOSING_COLOR='\[\033[0;38;2;0;0;100m\]'
    local DEFAULT_CURSOR_SHAPE='\[\033[5 q\]'

    local terminalPrompt=(
        # Prevents terminal breakage
        "$SOFT_TERMINAL_RESET"
        "$EXIT_INSERT_MODE"
        "$NORMAL_KEYPAD"
        "$CLEAR_MARGINS"

        # Visible prompt
        "$EXIT_CODE"
        "$START_COLOR \w/$NORMAL$START_COLOR"

        "$DEFAULT_CURSOR_SHAPE $CLOSING_COLOR$NORMAL "
    )
    IFS=
    PS1="${terminalPrompt[*]}"
    unset IFS

    # In here because this way
    # there's no extraneous array laying around
    local tmpPAGER=(
        "less"
        "--+no-init"
        "--incsearch"
        "--LONG-PROMPT"
        "--ignore-case"
        "--use-color"
        "--RAW-CONTROL-CHARS"
    )
    export PAGER="${tmpPAGER[*]}"
}
PS2="| "

# shellcheck source=./.bash_shopts
. ~/.bash_shopts
# shellcheck source=./.bash_aliases
. ~/.bash_aliases

set -o vi
bind -f ~/.inputrc
# Use full clear, not partial
bind -m vi-insert -x '"\C-l":"clear"'
# Like before, but also show folder's content
bind -m vi-insert -x '"\el":"clear; ls"'

export usr_bin="$PREFIX/bin/"
export EDITOR="vim"
export HISTIGNORE="giy*:git shoe*:git f:cld:c"
export HISTFILESIZE=2500
export HISTSIZE=2500
# To keep \n
export HISTTIMEFORMAT='%F '
GPG_TTY=$(tty)
export GPG_TTY
# Weird gpg stuff
[[ -f $HOME/.gnupg/public-keys.d/pubring.db.lock ]] && {
    rm "$HOME/.gnupg/public-keys.d/pubring.db.lock"
}

clear
cd ~/storage/downloads/ || exit 1
cal --monday
echo -ne "\n\033[91m"
echo \
﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊﹊
echo -ne "\033[0m"
ls
echo -ne "$cleanupMsg\n"

