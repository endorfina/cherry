#!/bin/bash

export LC_ALL=C

die()
{
    [[ -n $tmp_dir && -d $tmp_dir ]] && rm -rf "$tmp_dir"
    echo >&2 "!! ${BASH_SOURCE[0]}: $*"
    exit 1
}

ws_trim()
{
    sed -E -e 's~//.*$~~' \
        -e 's~^[[:space:]]+~~' \
        -e 's~[[:space:]]+$~~' \
        -e '/^$/d'
}

[[ $# -gt 0 ]] || die "Not enough arguments"

cd "${0%/*}" || die

readonly script_file=./cherry.sh
readonly sed_file=scr/digest.sed
readonly regex_elem='[[:space:]]+([^@]+)[[:space:]]+'
readonly regex_str="@cherry_test${regex_elem}@expects${regex_elem}(@.*)?\$"

[[ -r $sed_file ]] || make -s || die "Make failed"

failed=no

counter=0

while [[ $# -gt 0 ]]
do
    [[ -r $1 ]] || die "File \"$1\" could not be read"

    SOURCE=$(ws_trim < "$1")
    shift

    while [[ $SOURCE =~ $regex_str ]]
    do
        RESULT=$(echo -En "${BASH_REMATCH[1]}" | "$script_file" -q -f "$sed_file" -) || die "Error reading results"

        (( ++counter ))

        expected=${BASH_REMATCH[2]//[[:space:]]/}

        if [[ ! ${RESULT//[[:space:]]/} == *$expected* ]]
        then
            printf 'Test no. %d\nExpected:\n%s\n\n--\n\nGot:\n%s\n\n--\n\n' \
                        "$counter" "${BASH_REMATCH[2]// /.}" "${RESULT// /.}"

            failed=yes
        fi

        SOURCE=${BASH_REMATCH[3]}
    done
done

echo "[Tests run: $counter]"

[[ $failed == yes ]] && die "Cherry unit test failed"

echo '🌸 Success!'

