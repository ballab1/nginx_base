#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail
IFS=$'\t\n'

#---------------------------------------------------------------------------
function filter_relevant_lines()
{
    awk '{ gsub("#.*","",$0);
           gsub(";",";\n",$0);
           gsub("{","\n{\n",$0);
           gsub("}","\n}\n",$0);
           print;
         }' "$1"
}

#---------------------------------------------------------------------------
function expand_included_files()
{
    # recursively process includes using this bash script
    awk -v HK="'" -v CMD="$CMD" '{ gsub("[ \t]+"," ",$0);
                                   gsub("^[ \t]","",$0);
                                   gsub("[ \t]$","",$0);
                                   gsub(HK,"%%",$0);
                                   if ($1=="include") {
                                       sub(";$","",$2);
                                       print CMD" "HK$2HK; }
                                   else {
                                       print "echo "HK$0HK; }
                                 }' "$1" | sh
}

#---------------------------------------------------------------------------
function delete_blank_lines()
{
    awk -v HK="'" '{ gsub("%%",HK,$0);
                     if (length($0) > 0) {
                         print; }
                   }' "$1"
}

#---------------------------------------------------------------------------
function pretty_print()
{
    # TODO
    cat "$1"
}

#---------------------------------------------------------------------------

cd /etc/nginx

export CMD="$( [ -x "$0" ] || "$( pwd )/" )$0"
FILE="${1:-nginx.conf}"

echo "# start: $FILE"
cat "$FILE" | filter_relevant_lines | expand_included_files | delete_blank_lines | pretty_print
echo "# stop: $FILE"
