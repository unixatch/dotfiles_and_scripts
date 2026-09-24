#!/usr/bin/env bash

alias ls="
    ls \
        --human-readable \
        --group-directories-first \
        --classify --time-style=long-iso \
        --sort=size --reverse \
"
alias clear='printf "\e[H\e[2J\e[3J"'
alias cls='
    printf "%b%s\n\n%s\n" \
        "\e[H\e[2J\e[3J" \
        "$( ls --color=always -C -S )" \
        "$(
            [[ -d .git/ ]] && {
                git -c "color.status=always" s 
            } || printf "\e[A"
        )"
'
alias c="cls" l="ls"
alias ping="ping -c 5"
# For typos
alias cl="cls" cld="cls" clw="cls"
alias giy="git" got="git"

alias grep="grep --color=always --perl-regexp"
alias shred="shred --zero"
alias rm="trash"
alias rmdir="trash"
alias less="
    less \
        --ignore-case \
        --incsearch \
        --LONG-PROMPT \
        --use-color \
        --RAW-CONTROL-CHARS \
"
alias which="command -V"
alias wget="wget --adjust-extension --convert-links"
alias wget-local="
    'wget' \
        --adjust-extension \
        --convert-links \
        --page-requisites \
"
alias du="du --human-readable"
alias open="termux-open"
alias pwsh="proot-distro login debian"
# Enable colors always for tree
alias tree="tree -C"
alias ncdu="ncdu --extended --show-percent --color dark"
alias ip="ip -c=always"
alias ips="ip -brief -all address"
alias diff="
    diff \
        --color=always \
        --unified \
        --text \
        --report-identical-files \
"
alias jobs="jobs -l"
alias terminfo="less ~/terminfo.txt"
# Download with metadata, at 1080p
# with a normal filename for yt-dlp
alias yt-dlp="
    'yt-dlp' \
        --output '%(title)s [%(uploader)s].%(ext)s' \
        --embed-metadata --write-automatic-subs --embed-subs \
        --format-sort='width:1920,height:1080,fps:30' \
        --sponsorblock-remove sponsor,selfpromo,interaction \
        --sleep-subtitles 1.1 --sleep-requests 1.1 \
        --sleep-interval 0.2 --max-sleep-interval 0.5 \
        --concurrent-fragments 8 \
"
alias yt-dlp-no-subs="yt-dlp --no-embed-subs --no-write-automatic-subs"
# Best audio format for yt-dlp
alias yt-dlp-audio="
    yt-dlp \
        --output '%(title)s.%(ext)s' \
        --format-sort='' \
        --format='bestaudio/best' \
        --extract-audio \
        --audio-format opus \
        --audio-quality 0 \
"
alias ffprobe="ffprobe -hide_banner"
alias ffmpeg="ffmpeg -hide_banner"
alias ffplay="ffplay -hide_banner"
alias qalc="qalc --color"
alias showAllFunctions="compgen -c | less"
alias history="history | less" # | tac 
alias delta="delta --pager=less"
# Open vim with tabs for each file
alias vim="vim -p"
alias view="view -p"
alias wine="wine-stable"
alias bat="
    bat \
        --chop-long-lines \
        --pager \"\$PAGER\" \
        --map-syntax '*.conf:ini' \
"
alias uni-search="uni \
    --format '%(char l:auto)%(wide_padding)%(name t)' \
    --pager search \
"
alias updatePackageLock="npm i --package-lock-only"
alias showMarkdowns="grip"

# \n are kept if enabled in history
alias enableMultilineHistory="shopt -s cmdhist && shopt -s lithist"

