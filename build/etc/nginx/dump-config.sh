#!/bin/bash

#set -o errexit
set -o nounset
set -o pipefail
IFS=$'\t\n'

#---------------------------------------------------------------------------
function delete_blank_lines()
{
    while read -r data; do
        [ "${data:-}" ] || continue
        echo "$data" | \
        awk -v HK="'" '{ gsub("%%",HK,$0);
                         if (length($0) > 0) {
                             print; }
                        }'
    done
}

#---------------------------------------------------------------------------
function echo_file()
{
    local file=$1

    echo ">>>> start: $file;"
    cat "$file"
    echo "<<<< stop: $file;"
}

#---------------------------------------------------------------------------
function expand_included_files()
{
    # recursively process includes using this bash script
    while read -r data; do
        [ "${data:-}" ] || continue
        echo "$data" | \
        awk -v HK="'" -v CMD="$CMD -noPretty" '{ gsub("[ \t]+"," ",$0);
                                                 gsub("^[ \t]+","",$0);
                                                 gsub("[ \t]+$","",$0);
                                                 gsub(HK,"%%",$0);
                                                 if ($1=="include") {
                                                     sub(";$","",$2);
                                                     print CMD" "$2; }
                                                 else {
                                                     print "echo "HK$0HK; }
                                                }' | sh
    done
}

#---------------------------------------------------------------------------
function filter_relevant_lines()
{
    while read -r data; do
        [ "${data:-}" ] || continue
        echo "$data" | \
        awk '{ gsub("#.*","",$0);
               gsub(";",";\n",$0);
               gsub(/[\s\n]*\{\s*/," {\n",$0);
               gsub("}","\n}\n",$0);
               print;
             }'
    done
}

#---------------------------------------------------------------------------
function pretty_print()
{
    while read -r data; do
        [ "${data:0:1}" = '}' ] && (( tabs-- ))
        if [ "${data:0:12}" = '>>>> start: ' ]; then
            echo ''
            echo ''
            data="#include ${data:12}  #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        fi
        [ "${data:0:11}" = '<<<< stop: ' ] && data="# <<<<<<< ${data:11}  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        printf '%s%s\n' "$(tab_prefix "$tabs")" "${data}"
        [ "${data: -1}" = '{' ] && (( tabs++ ))
    done
}

#---------------------------------------------------------------------------
function tab_prefix()
{
    local -r tabs=${1:?}
    [ "$tabs" -gt 0 ] || return
    [ $recursiveInvocation -eq 0 ] || return

    for (( i=0; i<tabs; i++ )); do
        echo -n '  '
    done
}

#---------------------------------------------------------------------------

export DIR
declare -i tabs=0

# get our script name so we can recursively call ourselves
export CMD="$( [ -x "$0" ] || "$( pwd )/" )$0"


# determine whether or not we called ourself
declare -i recursiveInvocation=0
if [ "${1:-}" = '-noPretty' ]; then
    recursiveInvocation=1
    shift
fi

# get the list of files from command line
declare -a FILES=( "$@" )
if [ "${#FILES[*]}" -eq 0 ]; then
    declare __local="$(pwd)/nginx.conf"
    if [ -f nginx.conf ]; then
        DIR="$(pwd)"
    else
        DIR=/etc/nginx
    fi
    FILES=( "${DIR}/nginx.conf" )
fi

# process files
cd "$DIR" || exit
for file in "${FILES[@]}"; do
    echo_file "$file" | filter_relevant_lines | expand_included_files | delete_blank_lines | pretty_print
done

