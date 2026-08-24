#!/usr/bin/env bash

sigwinchHandler() (:)
usage() {
    printf '%s\n' \
        'file_selector [options]' \
        '   Like the name implies, it shows a list of filenames available and' \
        $'   lets you select them, then returns the selected files\n' \
        'Options:' \
        '   --sort|-s:' \
        '       change glob sorting of files' \
        '   --still|-S:' \
        "       don't move the cursor after pressing space" \
        ""
    return 1
}
cleanUp() {
    printf '\e[?1049l'
    trap - "${signals[@]}"
    return "${BASH_TRAPSIG:-0}"
}
trapHandler() {
    printf '\e[?1049l'
    # Needed because read -s can break
    # the echoing of input characters
    # (see "stty echo")
    trap - $BASH_TRAPSIG
    kill -$BASH_TRAPSIG $BASHPID
}

renderer() {
    local line file loopPos=0 curTotLines=0 lines=()
    for file in "${files[@]}" ;{
        (( curTotLines+=filenameLengths[loopPos] ))
        (( curTotLines - curPos >= LINES )) && break

        # Selection highlighter
        [[ -n ${selection[loopPos]} ]] &&
        (( selection[loopPos] == loopPos )) && {
            # Makes easier to know where
            # the cursor is on selected files
            (( curPos == loopPos )) && line=$'\e[3;1m'
            lines+=( "$line"$'\e[90;7;40m'"$file"$'\e[0m\n' )
            ((loopPos++))
            unset line
            continue
        }
        # Cursor highlighter
        (( curPos == loopPos )) && {
            lines+=( $'\e[7m'"$file"$'\e[0m\n' )
            ((loopPos++))
            continue
        }
        # Normal printing
        lines+=("$file\n")
        ((loopPos++))
    }
    IFS= lines="${lines[*]}"
    printf '\e[H\e[0J%b' "$lines"
}
inputHandler() {
    local input needsToStop="false"
    local upRegex="A|w|k" downRegex="B|s|j" arrowRegex="^\["
    local wholeInput=""

    # TODO: Emacs bindings?
    # TODO: vim shortcuts like 3k?
    while read -rsN 1 input ;do
        case "$input" in
            # Up and down arrows
            A|B|w|s|j|k)
                # Broken up/down arrow escape sequences
                [[ $input =~ A|B ]] &&
                [[ ! $wholeInput =~ $arrowRegex ]] && {
                    wholeInput=""
                    continue
                }

                [[ $input =~ $upRegex ]] && ((
                    curPos > 0
                        ? curPos--
                        : ( curPos=$((${#files[@]}-1)) )
                ))
                [[ $input =~ $downRegex ]] && ((
                    curPos < ${#files[@]}-1
                        ? curPos++
                        : ( curPos=0 )
                ))
                needsToStop="true"
            ;;
            # Selector
            " ")
                if [[ -n ${selection[$curPos]} ]] ;then
                    unset "selection[curPos]"
                    $moveTheCursor && ((curPos++))
                else
                    selection[curPos]="$curPos"
                    $moveTheCursor && ((curPos++))
                fi
                needsToStop="true"
            ;;
            # Accept selection
            $'\n')
                [[ -z ${selection[*]} ]] && {
                    selection[curPos]="$curPos"
                }
                keepLooping="false"
                needsToStop="true"
            ;;
            # Quit command
            q|Q|e|E) return 1 ;;
            # Ignore everything else
            *) ;;
        esac
        "$needsToStop" && break
        wholeInput+="$input"
    done
}

file_selector() {
    [[ -z "$*" ]] && { usage; return $?; }
    local i GLOBSORT moveTheCursor="true"
    for (( i = 1; i <= $#; ++i )) ;{
        local arg="${*:i:1}" nextArg="${*:i+1:1}"
        case "$arg" in
            -s|--sort)  GLOBSORT="$nextArg" ;;
            -S|--still) moveTheCursor="false" ;;
            -h|--help)  usage; return $? ;;
        esac
    }
    i= # resets it
    trap trapHandler SIGINT SIGTERM
    trap sigwinchHandler SIGWINCH
    local signals=( SIGINT SIGTERM SIGWINCH )

    # Necessary for COLUMNS and LINES to be set
    (:)
    local curPos=0 keepLooping="true" selection=()
    shopt -s nullglob
    local files=(*.webm *.mkv *.mp4)
    shopt -u nullglob

    local filenameLengths=() totalLines file nameLength
    for file in "${files[@]}" ;{
        totalLines=0 nameLength=${#file}
        # Counts the lines that a string might take
        for (( i = 0; i < nameLength; )) ;{
            ((
                ++totalLines,
                (i += COLUMNS) >= nameLength
            )) \
                && break
        }
        filenameLengths+=("$totalLines")
    }
    # Opens alternate buffer + saves cursor
    printf '\e[?1049h'
        while "$keepLooping" ;do
            renderer
            # In case it's trying to quit
            ! inputHandler && {
                cleanUp
                return 1
            }
        done
    printf '\e[H\e[0J'

    # Show selected files
    local listOfSelectedFiles=() n
    for n in "${selection[@]}" ;{
        echo "${files[n]}"
        listOfSelectedFiles+=("${files[n]}")
    }
    echo

    # Confirmation prompt
    local doIt="false" answer
    while read -p "Use file [y|n]? " -r answer ;do
        case "$answer" in
            y|Y|s|S) doIt="true"; break ;;
            n|N)     break ;;
            *)       printf '\e[F' ;;
        esac
    done
    if "$doIt" ;then
        # Uses the selected files
        REPLY=( "${listOfSelectedFiles[@]}" )
    fi
    # Closes alternate buffer + restores cursor
    printf '\e[?1049l'
}

# Equivalent to python's if __name__ == "__main__" check
if ! ( return &>/dev/null ) ;then
    # Interactive, run it
    file_selector "$@"
else
    # Sourced, do nothing and exit with 0
    :
fi

