#!/bin/bash

pgpat="${1:-salt-m[a-z]*}"; shift

pgrep -fa "$pgpat" | grep -v opt-env-process-current | \
while read line; do
    pid=$(cut -d' ' -f1 <<< "$line")
    cmd="$(sed -e 's/^[0-9 ]*//' <<< "$line")"
    for file in "$@" ; do
        echo "considering pid=$pid compared to file=$file"
        echo " (cmd: $cmd)"
        if [ "$file" -nt /proc/$pid/stat ]; then
            echo "dang, we should restart that"
            exit 1
        fi
    done
done
