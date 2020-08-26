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
cherry_dir=$(pwd) || die
tmp_dir=$(mktemp -d) || die

readonly test_file_basename=cherry_test_file

test_file=$tmp_dir/$test_file_basename
script_file=$cherry_dir/cherry.sh
sed_file=$cherry_dir/scr/digest.sed

regex_str='@cherry_test([^@]+)@expects([^@]+)(@.*)$'

readonly {cherry,tmp}_dir regex_str {test,script,sed}_file

[[ -r $sed_file ]] || make -s || die "Make failed"
cd "$tmp_dir" || die "Couldn't enter temporary directory"

failed=no

counter=0

while [[ $# -gt 0 ]]
do
    [[ -r $cherry_dir/$1 ]] || die "File \"$cherry_dir/$1\" could not be read"

    SOURCE=$(ws_trim < "$cherry_dir/$1")
    shift

    while [[ $SOURCE =~ $regex_str ]]
    do
        echo -En "${BASH_REMATCH[1]}" > "$test_file"

        (( ++counter ))

        "$script_file" -q -f "$sed_file" "$test_file_basename"

        RESULT=$(cat "$test_file_basename.cpp") || die "Error reading results"

        rm "$test_file_basename.cpp"

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

rm -rf "$tmp_dir"

[[ $failed == yes ]] && die "Cherry unit test failed"

echo '🌸 Success!'

