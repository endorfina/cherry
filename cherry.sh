#!/bin/sh

#echo "$@" test -n "$sed_script" -a -r "$sed_script" \
#    || (echo >&2 "💀 ${0##*/} error: sed script is unreadable" ; exit 1)

export LC_ALL=C

swapn()
{
    tr ';\n' '\n;'
}

transcode()
{
    sed -E -e '1s~^[^[:punct:][:alnum:]]+~~' -e 's~[[:space:]]*//.*$~~' \
        | swapn \
        | sed -nE -f "$sed_script" \
        | swapn
}

transcode_with_guard()
{
    echo '#pragma once'
    transcode < "$1"
}

transcode_with_include()
{
    header_file=${1%.cr}.hpp
    test -r "${header_file%pp}r" && echo "#include \"${header_file##*/}\""
    transcode < "$1"
}

check_outdated()
{
    ! test -r "$2" -a "$2" -nt "$1"
}

hint_script_path()
{
    while test "$#" -gt 0
    do
        test -r "$1" && sed_script=$1 && break
        shift
    done
}

digest()
{
    if check_outdated "$2" "$3" || test "$(wc -l < "$3")" -lt 1
    then
        echo "🌸 [${1##*with_}] ${2#$source_dir} -> ${3##*/}"
        mkdir -p "${3%/*}"
        "$1" "$2" > "$3"

        test "$verbose" = yes -a -n "$3" && diff --color=always "$2" "$3"
    fi
}

readonly sed_script_name='cherry.sh/digest.sed'
sed_script=$CHERRY_SED

test -z "$sed_script" && hint_script_path \
        "${XDG_DATA_HOME:-$HOME/.local/share}/$sed_script_name" \
        "/usr/share/$sed_script_name"

source_dir=
dest_dir=.
verbose=no
auto_headers=no

while test "$#" -gt 0
do
    out_name=$1
    shift

    case "$out_name" in
    -o|--out)
        dest_dir=${1%/}
        shift
        ;;

    -s|--src)
        source_dir=${1%/}/
        shift
        ;;

    -f|--sedfile)
        sed_script=$1
        shift
        ;;

    -h|--headers)
        auto_headers=yes
        ;;

    -v|--verbose)
        verbose=yes
        ;;

    *.hr)
        digest transcode_with_guard "$source_dir$out_name" "$dest_dir/${out_name%.hr}.hpp"
        ;;

    *.cr)
        digest transcode_with_include "$source_dir$out_name" "$dest_dir/${out_name%.cr}.cpp"

        out_name=${out_name%.cr}.hr

        if test "$auto_headers" = yes -a -r "$source_dir$out_name"
        then
            digest transcode_with_guard "$source_dir$out_name" "$dest_dir/${out_name%.hr}.hpp"
        fi
        ;;

    *)
        echo "Ignoring argument '$out_name'"
        ;;
    esac
done

:
