#!/bin/bash

promptExitCode() {
    # Only when non-zero and no SIGINT
    [[ $1 != 0 && $1 != 130 ]] && printf "(%s)" "$1"
}

shitty_webm_vid() {
    local esc="\033["
    local BOLD="$esc""4m"
    local NORMAL="$esc""0m"

    [[ -z $1 || $1 =~ --help|-h ]] && {
        echo creates a shitty webm vid from \
             an mp4 using ffmpeg inside the current directory.
        echo
        echo -e "Add ${BOLD}1$NORMAL before adding \
                 the name of file to show its streams"
        return 1
    }

# ----------------------------------------------

    [[ $1 == 1 ]] && {
        ffprobe -show_streams "$2"
        return
    }

    ffmpeg \
        -y \
        -hide_banner \
        -i "$1" \
        -speed 5 \
        -fs 10000000 \
        -b:v 2M -b:a 192k \
        -c:v libvpx -c:a libvorbis \
            "${1//\.[a-z]*/\.webm}"
}

shitty_GIF() {
    local esc="\033["
    local BOLD="$esc""4m"
    local NORMAL="$esc""0m"

    [[ -z $1 || $1 =~ --help|-h ]] && {
        echo Creates a shitty GIF from an mp4 using \
             ffmpeg inside the current directory.
        echo
        echo -e "Add ${BOLD}1$NORMAL before adding \
                 the name of file to show its streams"
        return 1
    }

# ----------------------------------------------

    [[ $1 == 1 ]] && {
        ffprobe -show_streams "$2"
        return
    }

    ffmpeg \
        -y \
        -hide_banner \
        -i "$1" \
        -r 30 \
        -fs 10000000 \
        "${1//\.[a-z]*/\.gif}"
}

nsl() {
    local mainArgument="$1"
    whoisS() {
        whois "$mainArgument" \
            | grep Server --color=never
    }
    [[ -z $mainArgument || "$mainArgument" =~ --help|-h ]] && {
        echo Shows the nameservers of \
             the site and the \
             registrar\'s whois server
        return 1
    }

    whoisS > /dev/null || {
        echo Couldn\'t get the nameservers
        return 1
    }
    echo Results of "$mainArgument":
    whoisS
}
checksum() {
    # No arguments
    [[ -z $* ]] && return 1

    local esc="\033["
    local Green="$esc""32m"
    local NORMAL="$esc""0m"

    local algoritmoHash="sha256sum"
    arg=$*
    [[ $1 == "--algorithm" ]] && {
        local algoritmoHash="$2"
        arg=$3
    }

    clear
    echo -e "${Green}$algoritmoHash$NORMAL is in use\n"
    $algoritmoHash "$arg" | \
        grep --color=auto -o "^.* "
    echo -e "\n${arg//\s/\n}"
}
compareImgs() {
    magick "$1" "$2" -append SidebySideImg.png
    termux-open SidebySideImg.png
}
crc32() {
    for file in "$@" ;{
        # Gets only the result
        # and highlights the crc32 in bold, underlined and yellow
        local crcText
        crcText=${ rhash --crc32 "$file" | tail -n 1; }
        local crc
        crc=${
            echo "$crcText" |
                grep --only-matching "[A-Z0-9]*$";
        }

        echo -e "\e[04;01;33m$crc\e[0m" "$file"
    }
}
dumpUrls() {
    [[ ! $1 =~ (flac|mp3|wav|aac|ogg)$ ]] && return 1
    lynx \
        -dump \
        -listonly \
        -nonumbers "$2" | "grep" -P "\.$1$"
}
dumpYoutubePlaylistUrls() (
    case "$1" in
        "")
            echo "dumpYoutubePlaylistUrls [-f <filename>] <url>"
            return 1
        ;;
        "-f")
            local filename="$2"
            exec 1>>"$filename"
        ;;
    esac

    local index=0
    while read -r line ;do
        # Prints m3u compatible song titles
        ! (( index & 1 )) && {
            echo "#EXTINF:,$line"

            # Shows progress, kinda on stderr
            echo "$line" >&2
            ((index++))
            continue
        }

        # Prints urls
        echo "$line"
        ((index++))
    done < <(
        yt-dlp \
            --no-warnings \
            --skip-download \
            --print "title" \
            --print "original_url" \
            "${
                # Getting the url
                [[ "$filename" ]] && {
                    echo "$3"
                    return
                }
                echo "$1";
            }"
    )
)
showwavespic() {
    [[ -z "$1" || "$1" =~ --help|-h ]] && {
        echo "showwavespic <file> [immagine]"
        echo
        return 1
    }
    local outfile="out.png"
    [[ ! -z "$2" ]] && outfile="$2"

    ffmpeg \
        -i "$1" \
        -lavfi "showwavespic=\
                s=1920x1080:\
                colors=white|gray" \
        "$outfile"
}
showwaves() {
    [[ -z "$1" || "$1" =~ --help|-h ]] && {
        echo "showwaves <file> [video]"
        echo
        return 1
    }
    local outfile="out.mp4"
    [[ ! -z "$2" ]] && outfile="$2"

    ffmpeg \
        -i "$1" \
        -filter_complex "[0]showwaves=\
                         s=1920x1080:\
                         mode=cline:\
                         colors=white|gray" \
        -c:v libx264 \
        -b:v 4M \
        -preset ultrafast \
        -c:a copy "$outfile"
}
printPublicGPGKey() {
    [[ -z "$1" || "$1" =~ --help|-h ]] && {
        echo "printPublicGPGKey <key_id>"
        echo
        return 1
    }
    gpg --list-keys 2>/dev/null
    gpg --armour --export "$1" 2>/dev/null
}
printSecretGPGKey() {
    [[ -z "$1" || "$1" =~ --help|-h ]] && {
        echo "printSecretGPGKey <key_id>"
        echo
        return 1
    }
    gpg \
        --list-secret-keys \
        --keyid-format=long "$1" 2>/dev/null
}
createGPGKey() {
    [[ -z "$1" || "$1" =~ --help|-h ]] && {
        echo "createGPGKey <key_id>"
        echo "if there's an already existing key,"
        echo "it'll just update it and quit."
        echo
        return 1
    }
    local secretKeys
    secretKeys="${
        printSecretGPGKey "$1" \
        | pcre2grep \
            --multiline \
            --only-matching=1 'sec.*\[.*\]\n\s*([A-Z0-9]+)'
    }"
    subKeys="${
        gpg \
            --list-keys \
            --list-options show-unusable-subkeys \
            "$1" \
        | pcre2grep \
            --multiline \
            --only-matching=1 'sub.*\[.*\]\n\s*([A-Z0-9]+)'
    }"
    # Does it exist at least one key?
    [[ ! -z "$secretKeys" ]] && {
        # Main key (without \*)
        local args=(
            --quick-set-expire
            "$secretKeys"        # existing key
            1m                   # for 1 month
        )
        gpg "${args[@]}"

        # Subkeys
        args+=("$subKeys")
        gpg "${args[@]}"

        echo Updated key:
        echo "    sec"
        echo "      $secretKeys"
        echo "    sub"
        echo "      $subKeys"
        echo for 1 month
        return
    }
    pass init "$1"
    gpg --full-generate-key
    git config \
        set --global \
        user.signingkey \
        "${
            printSecretGPGKey "$1" \
            | pcre2grep \
                --only-matching=1 'sec.*/([A-Z0-9]+) 2'
        }"
}
updateGPGKeys() {
    [[ -z "$1" || "$1" =~ --help|-h ]] && {
        echo "updateGPGKey <key_id>"
        echo
        return 1
    }
    local secretKeys
    secretKeys="${
        printSecretGPGKey "$1" \
        | pcre2grep \
            --multiline \
            --only-matching=1 'sec.*\[.*\]\n\s*([A-Z0-9]+)'
    }"
    subKeys="${
        gpg \
            --list-keys \
            --list-options show-unusable-subkeys \
            "$1" \
        | pcre2grep \
            --multiline \
            --only-matching=1 'sub.*\[.*\]\n\s*([A-Z0-9]+)'
    }"
    # Does it exist at least one key?
    [[ -z "$secretKeys" ]] && return 1

    # Main key (without \*)
    local args=(
        --quick-set-expire
        "$secretKeys"       # existing key
        1m                  # for 1 month
    )
    gpg "${args[@]}"

    args+=("$subKeys")
    gpg "${args[@]}"

    echo Updated key:
    echo "    sec"
    echo "      $secretKeys"
    echo "    sub"
    echo "      $subKeys"
    echo for 1 month
    return
}
diffLines() {
    [[ -z "$1" || "$1" =~ --help|-h ]] && {
        echo "diffLines <line[,line2]> <line3[,line4]> <file>"
        echo
        return 1
    }
    local regex='[0-9],[0-9]'
    local singleLineRegex='[0-9]'
    [[ ! $1 =~ $regex ]] \
    && [[ ! $1 =~ $singleLineRegex ]] && {
        echo -e "\e[91mWrong format: \"$1\"\e[0m"
        return 1
    }
    [[ ! $2 =~ $regex ]] \
    && [[ ! $2 =~ $singleLineRegex ]] && {
        echo -e "\e[91mWrong format: \"$2\"\e[0m"
        return 1
    }
    [[ ! -f $3 ]] && {
        echo -e "\e[33mActual file needed\e[0m"
        return 1
    }
    deltaOutput=${ delta <(sed -n "$1p" "$3") <(sed -n "$2p" "$3"); }
    [[ -z $deltaOutput ]] && {
        echo "They're the same picture"
        return
    }
    echo "$deltaOutput"
}
eslintLess() {
    [[ -z "$1" || "$1" =~ --help|-h ]] && {
        echo "eslintLess <files...>"
        echo
        return 1
    }
    LESSOPEN='' less \
        -f \
        <(
            'eslint' \
                --color \
                -c ~/js-scripts/eslint/eslint.config.mjs \
                "$@"
        )
}
checkJSTypes() {
    [[ -z "$1" || "$1" =~ --help|-h ]] && {
        echo "checkJSTypes <main_file.mjs> [files.mjs...]"
        echo
        return 1
    }
    local typesFolder="$PREFIX/lib/node_modules/@types/"
    LESSOPEN='' less -R \
        -f \
        <(
            npx tsc \
                --target esnext \
                --lib esnext \
                --module esnext \
                --moduleResolution node \
                \
                --excludeDirectories "node_modules/" \
                --typeRoots "$typesFolder" \
                \
                --allowJs \
                --checkJs \
                --noEmit \
                --pretty \
                "$@"
        )
}
trash() {
    local esc="\033["
    local red="${esc}31m"
    local yellow="$esc""33m"
    local green="$esc""32m"
    local underline="$esc""4m"
    local exitUnderline="${esc}24m"
    local bold="${esc}1m"
    local exitBold="${esc}22m"
    local normal="$esc""0m"

    local files=("$@")
    [[ -z "${files[*]}" || "${files[*]}" =~ --help|-h ]] && {
        echo "trash <files>"
        return 1
    }
    for file in "${files[@]}" ;{
        [[ ! -e "$file" ]] && {
            echo -e "$red$bold$underline${file}$exitUnderline$exitBold doesn't exist$normal"
            return 1
        }
    }
    # shellcheck disable=2154
    [[ ! -f "$trashCleanupTimeFile" ]] && {
        local DAYS_TO_WAIT=4
        local days=$(( 60**2 * 24 * DAYS_TO_WAIT ))
        local nextDate=$(( EPOCHSECONDS + days ))

        echo "$nextDate" > "$trashCleanupTimeFile"
    }

    local trashedMsg="${green}trashed$normal $underline%s$normal\n"
    local notMmovedMsg="$yellow$underline%s$exitUnderline didn't move$normal\n"
    # subshell hides bash's text
    # when creating jobs
    (
        for file in "${files[@]}" ;{
            {
                mv "$file" "$HOME/.trash/" || exit

                # shellcheck disable=2059
                if [[ -e "$HOME/.trash/$file" ]] ;then
                    printf "$trashedMsg" "$file"
                else
                    printf "$notMmovedMsg" "$file"
                fi
            } &
        }
        wait -f
    )
}
showMarkdownOffline() {
    [[ -z "$*" || "$*" =~ --help|-h ]] && {
        echo "showMarkdownOffline [--browser|-b] <file.md>"
        return 1
    }
    local listOfArgs=("$@")
    for (( i = 0; i < "$#"; i++ )) ;{
        local arg="${listOfArgs[i]}"
        case "$arg" in
            --browser|-b)
                local destination=(
                    "--output"
                    "$TMPDIR/github_markdowns.html"
                )
                unset "listOfArgs[$i]"
            ;;
            *) ;;
        esac
    }

    [[ -n "${destination[*]}" ]] && {
        local pandocOutput
        pandocOutput="${
            pandoc \
                --from gfm \
                --standalone \
                "${listOfArgs[@]}" \
                "${destination[@]}"
        }"
        termux-open "${destination[1]}"
        return
    }
    local pandocOutput
    pandocOutput="${
        pandoc \
            --from gfm \
            --standalone \
            --to ansi \
            "${listOfArgs[@]}"
    }"
    echo "$pandocOutput" | less -R
}
unameAll() {
    mapfile -t -d ' ' unameResults <<< "${ uname -a; }"

    # Remove last newline since it's unnecessary
    local lastArgument=$(( ${#unameResults[@]} - 1 ))
    unameResults[lastArgument]="${unameResults[lastArgument]//$'\n'/}"

    local dateOfBuild=()
    printWithPadding() {
        local colorTag=$'\e[32m'
        local normal=$'\e[0m'
        local paddingToUse=$((COLUMNS - 50))

        [[ $1 =~ version ]] && {
            printf "$colorTag%${paddingToUse}s$normal" "$1"
            printf "%$((COLUMNS - 30))s\n" "$2"
            return
        }
        printf "$colorTag%${paddingToUse}s$normal" "$1"
        printf "%${paddingToUse}s\n" "$2"
    }

    for (( i = 0; i < ${#unameResults[@]}; i++ )) ;{
        case $i in
            0) printWithPadding "Kernel:" "${unameResults[i]}" ;;
            1) printWithPadding "Node name:" "${unameResults[i]}" ;;
            2) printWithPadding "Kernel release:" "${unameResults[i]}" ;;
            3|4|5|6|7|8|9|10|11)
                # date of build as separate arguments
                # so add to an array for now
                dateOfBuild+=("${unameResults[i]}")
                continue
            ;;
            12) ;; # Keeps the uname order
            13)
                printWithPadding \
                    "Kernel version:"   "${dateOfBuild[*]}"
                printWithPadding \
                    "Architecture:"     "${unameResults[i-1]}"
                printWithPadding \
                    "Operating System:" "${unameResults[i]}"
            ;;
        esac
    }
}
lv() {
    # Shows how many video there are
    # in the current folder
    shopt -s nullglob
    local videoFiles=(*.webm *.mp4 *.mkv)
    shopt -u nullglob

    echo Video files: ${#videoFiles[@]}
}
la() {
    # Shows how many audio files there are
    # in the current folder
    shopt -s nullglob
    local audioFiles=(*.opus *.mp3 *.flac *.wav)
    shopt -u nullglob

    echo Audio files: ${#audioFiles[@]}
}
storageUsed() {
    local dfOutput
    # Filesystem       1K-blocks   Used Available Use% Mounted on
    # /dev/block/dm-15    655792 655792         0 100% /
    # ...
    mapfile -t dfOutput < <(df -k)
    dfOutput=(
        "${dfOutput[0]}"
        "${dfOutput[@]:${#dfOutput[@]}-1}" # last line
    )
    local header storage
    mapfile -t -d '|' header  <<< "${dfOutput[0]//+( )/\|}"
    mapfile -t -d '|' storage <<< "${dfOutput[1]//+( )/\|}"
    header[1]="total"

    # Precision to .2f, but as an integer
    # so we need to build it later
    local total     totPrecStart   \
          used      usedPrecStart  \
          available availPrecStart
    total=$((     storage[1] * 10000 / 100 / 1000 ** 2 ))
    used=$((      storage[2] * 10000 / 100 / 1000 ** 2 ))
    available=$(( storage[3] * 10000 / 100 / 1000 ** 2 ))
    totPrecStart=$((   ${#total}     - 2 ))
    usedPrecStart=$((  ${#used}      - 2 ))
    availPrecStart=$(( ${#available} - 2 ))

    #   Used  Available ...
    # 100.52       8.63 ...
    printf '\e[32m%11s\e[0m' \
        "${header[@]:1:${#header[@]}-2}" "${header[*]:${#header}-2}"$'\n'
    printf '%11s' \
        "${total:0:$totPrecStart}.${total:$totPrecStart} Gb" \
        "${used:0:$usedPrecStart}.${used:$usedPrecStart} Gb" \
        "${available:0:$availPrecStart}.${available:$availPrecStart} Gb" \
        "${storage[4]}" "  ${storage[5]}"
}

