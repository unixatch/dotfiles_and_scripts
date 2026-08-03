#!/usr/bin/env bash


sigwinchHandler() (:)
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
    local file loopPos=0 curTotLines=0 lines=()
    for file in "${files[@]}" ;do
        (( curTotLines+=filenameLengths[loopPos] ))
        (( curTotLines - curPos > LINES )) && break

        # Selection highlighter
        [[ -n ${selection[loopPos]} ]] &&
        (( selection[loopPos] == loopPos )) && {
            lines+=( $'\e[41m'"$file"$'\e[0m\n' )
            ((loopPos++))
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
    done
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
                else
                    selection[curPos]="$curPos"
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
    trap trapHandler SIGINT SIGTERM
    trap sigwinchHandler SIGWINCH
    local signals=( SIGINT SIGTERM SIGWINCH )

    # Necessary for COLUMNS and LINES to be set
    (:)
    local curPos=0 keepLooping="true" selection=()
    shopt -s nullglob
    local files=(*.webm *.mkv *.mp4)
    shopt -u nullglob

    local filenameLengths=() totalLines=0 file i
    for file in "${files[@]}" ;do
        totalLines=0
        # Counts the lines that a string might take
        for (( i = 0; i < ${#file}; )) ;{
            (( totalLines++ ))
            i=$((i + LINES))
        }
        filenameLengths+=(
            $(( totalLines != 1 ? totalLines - 1 : 1 ))
        )
        totalLines=0
    done
    # Opens alternate buffer + saves cursor
    printf '\e[?1049h'
        while "$keepLooping" ;do
            renderer
            # In case it's trying to quit
            ! inputHandler && {
                cleanUp
                return 0
            }
        done
    # Closes alternate buffer + restores cursor
    printf '\e[?1049l'

    # Show selected files
    local listOfSelectedFiles=() file n
    for n in "${selection[@]}" ;{
        echo "${files[n]}"
        printf -v file '%q' "${files[n]}"
        listOfSelectedFiles+=("$file")
    }

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
}
if ! ( return &>/dev/null ) ;then
    # Interactive, run it
    file_selector
else
    # Sourced, do nothing
    :
fi

