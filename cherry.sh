#!/bin/sh

export LC_ALL=C  # vital for sed regex parsing

swapn()
{
    tr ';\n' '\n;'
}

transcode()
{
    sed -E -e '1s~^[^[:punct:][:alnum:]]+~~' -e 's~[[:space:]]*//.*$~~' "$1" \
        | swapn \
        | sed -nE -f "$sed_script" \
        | swapn
}

transcode_with_guard()
{
    echo '#pragma once'
    transcode "$1"
}

transcode_with_include()
{
    header_file=${1%.cry}.hpp
    test -r "${header_file%pp}ry" && echo "#include \"${header_file##*/}\""
    transcode "$1"
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
        test "$quiet_mode" = yes \
            || echo "🌸 [${1##*with_}] ${2#$source_dir} -> ${3##*/}"

        mkdir -p "${3%/*}"
        "$1" "$2" > "$3"

        test "$verbose" = yes -a -n "$3" && diff "$2" "$3"
    fi
}

regenerate_digest()
{
    ( cd "$1" || exit 1

    test -r 'digest.sed' \
        -a 'digest.sed' -nt 'src.digest.sed' \
        -a 'digest.sed' -nt 'make_digest.sed' \
        || sed -E -f 'make_digest.sed' \
                'src.digest.sed' > 'digest.sed' )
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
quiet_mode=no

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
        if ! test -r "$sed_script"
        then
            echo "Error: sed script '${sed_script:-<empty string>}' is unreadable"  # ha!
            exit 1
        fi
        ;;

    -R|--regen)
        test -z "$1" -o ! -d "$1" \
            && die "-R|--regen command requires an additional argument pointing to the script directory to be regenerated"
        regenerate_digest "${1%/}" || exit 1
        shift
        ;;

    -h|--headers)
        auto_headers=yes
        ;;

    -q|--quiet)
        verbose=no
        quiet_mode=yes
        ;;

    -v|--verbose)
        verbose=yes
        ;;

    *.hry)
        digest transcode_with_guard "$source_dir$out_name" "$dest_dir/${out_name%ry}pp"
        ;;

    *.cry)
        digest transcode_with_include "$source_dir$out_name" "$dest_dir/${out_name%ry}pp"

        out_name=${out_name%.cry}.hry

        if test "$auto_headers" = yes -a -r "$source_dir$out_name"
        then
            digest transcode_with_guard "$source_dir$out_name" "$dest_dir/${out_name%ry}pp"
        fi
        ;;

    *)
        if test -r "$source_dir$out_name"
        then
            digest transcode "$source_dir$out_name" "$dest_dir/$out_name.cpp"
        else
            echo "Ignoring argument '$out_name'"
        fi
        ;;
    esac
done

:
