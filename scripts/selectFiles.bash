#!/usr/bin/env bash

_fs_sigwinchHandler() (:)
_fs_usage() {
    printf '%s\n' \
        'videofile_selector [options]' \
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
_fs_cleanUpFuncs() {
    unset -f _fs_usage _fs_cleanUpFuncs \
             _fs_sigwinchHandler _fs_cleanUp _fs_trapHandler \
             _fs_isLastRender _fs_renderer _fs_inputHandler
}
_fs_cleanUp() {
    # Closes alternate buffer + restores cursor
    printf '\e[?1049l'
    trap - "${signals[@]}"
    [[ $1 != "funcsExcluded" ]] && _fs_cleanUpFuncs
    return "${BASH_TRAPSIG:-0}"
}
_fs_trapHandler() {
    printf '\e[?1049l'
    # Needed because read -s can break
    # the echoing of input characters
    # (see "stty echo")
    trap - $BASH_TRAPSIG
    _fs_cleanUpFuncs
    kill -$BASH_TRAPSIG $BASHPID
}

_fs_isLastRender() {
    local totLines=$((curTotLines + filenameLengths[loopPos+1]))

    return $(( totLines - curPos < LINES - longestFilenameLength ))
}
_fs_renderer() {
    local line file loopPos=0 curTotLines=0 lines=()
    for file in "${files[@]}" ;{
        (( curTotLines+=filenameLengths[loopPos] ))
        (( curTotLines - curPos >= LINES - longestFilenameLength )) && {
            break
        }
        ! _fs_isLastRender && line[1]=$'\n'

        # Selection highlighter
        [[ -n ${selection[loopPos]} ]] &&
        (( selection[loopPos] == loopPos )) && {
            # Makes easier to know where
            # the cursor is on selected files
            (( curPos == loopPos )) && line[0]=$'\e[3;1m'
            lines+=( "${line[0]}"$'\e[90;7;40m'"$file"$'\e[0m'"${line[1]}" )
            ((loopPos++))
            unset line
            continue
        }
        # Cursor highlighter
        (( curPos == loopPos )) && {
            lines+=( $'\e[7m'"$file"$'\e[0m'"${line[1]}" )
            ((loopPos++))
            unset line
            continue
        }
        # Normal printing
        lines+=("$file${line[1]}")
        ((loopPos++))
        unset line
    }
    IFS= lines="${lines[*]}"
    printf '\e[H\e[0J%b' "$lines"
}
_fs_inputHandler() {
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

                # Inverted controls
                if "$invertJK" ;then
                    case "$input" in
                        j) input="k" ;;
                        k) input="j" ;;
                    esac
                fi
                if "$invertControls" ;then
                    case "$input" in
                        A|w|j) input="B" ;;
                        B|s|k) input="A" ;;
                    esac
                fi
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

videofile_selector() {
    [[ -z "$*" ]] && { _fs_usage; return $?; }
    local i GLOBSORT moveTheCursor="true" \
          invertControls="false" invertJK="false"
    for (( i = 1; i <= $#; ++i )) ;{
        local arg="${*:i:1}" nextArg="${*:i+1:1}"
        case "$arg" in
            -invA|--invert-all) invertControls="true" ;;
            -inv|--invert-jk)   invertJK="true" ;;
            -s|--sort)  GLOBSORT="$nextArg" ;;
            -S|--still) moveTheCursor="false" ;;
            -h|--help)  _fs_usage; return $? ;;
        esac
    }
    i= # resets it
    # Necessary for COLUMNS and LINES to be set
    (:)
    local curPos=0 keepLooping="true" selection=()
    shopt -s nullglob
    local files=(*.webm *.mkv *.mp4)
    shopt -u nullglob

    [[ -z "${files[*]}" ]] && {
        printf '\e[90m%s\e[0m\n' \
               "The folder doesn't contain valid files, quitting..."
        return 1
    }

    trap _fs_trapHandler SIGINT SIGTERM
    trap _fs_sigwinchHandler SIGWINCH
    local signals=( SIGINT SIGTERM SIGWINCH )

    local filenameLengths=() longestFilenameLength=0 totalLines file nameLength
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
        ((
            totalLines > longestFilenameLength
            && ( longestFilenameLength=totalLines )
        ))
    }
    # Opens alternate buffer + saves cursor
    printf '\e[?1049h'
        while "$keepLooping" ;do
            _fs_renderer
            # In case it's trying to quit
            ! _fs_inputHandler && {
                _fs_cleanUp
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
    local doIt="false" back="false" answer
    while read -p "Use file [y|n|b]? " -r answer ;do
        case "$answer" in
            y|Y|s|S) doIt="true"; break ;;
            n|N)     break ;;
            b|B)
                back="true"
                _fs_cleanUp "funcsExcluded"
                videofile_selector "$@"
                break
            ;;
            *)  printf '\e[F' ;;
        esac
    done

    $back && return
    _fs_cleanUp
    # Uses the selected files
    "$doIt" && REPLY=( "${listOfSelectedFiles[@]}" )
}

# Equivalent to python's if __name__ == "__main__" check
if ! ( return &>/dev/null ) ;then
    # Interactive, run it
    videofile_selector "$@"
else
    # Sourced, do nothing and exit with 0
    :
fi

