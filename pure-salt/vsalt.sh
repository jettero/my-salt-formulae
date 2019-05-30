#!/bin/bash

unset PYTHONPATH LD_LIBRARY_PATH
export PATH=/opt/venv/salt/bin:/usr/bin:/bin

actual_cmd_path="$(readlink "$0" || realpath "$0")"
actual_cmd="$(basename "$actual_cmd_path")"
vlink_dir="$(dirname "$(realpath "$0")")"

wanted_cmd="${WANTED:-${CMD:-$(basename "$0")}}"

if [ "$wanted_cmd" = "$actual_cmd" ]
then wanted_cmd="salt-call"
fi

if [ "$wanted_cmd" = "vsalt-links" ]; then
    declare -A CHANGES=( )
    function do_link {
        bbin="$(basename "$1")"
        ubin="$vlink_dir/$bbin"
        if [ -L "$ubin" ]; then
            rlink="$(readlink "$ubin")"
            if [[ ! "$rlink" =~ vsalt ]]; then
                CHANGES[$ubin]="$actual_cmd"
                ln -svf $actual_cmd $ubin
            fi
        else
            CHANGES[$ubin]="$actual_cmd"
            ln -svf $actual_cmd $ubin
        fi
    }
    for sbin in /opt/venv/salt/bin/salt*
    do do_link "$sbin"
    done
    echo
    if [ ${#CHANGES[*]} -gt 0 ]; then
        echo -n "changed=yes "
        for k in "${!CHANGES[@]}"
        do echo -n "$k='${CHANGES[$k]}' "
        done
        echo "comment='links updated'"
    else echo "changed=no"
    fi
    exit 0
fi

if [ -z "$UID" ]
then UID=$(id -u)
fi

if [ $UID -gt 0 ]
then exec sudo WANTED="$wanted_cmd" "$0" "$@"
fi

umask 0022
export PATH="/opt/venv/salt/bin:/usr/bin:/bin:/usr/sbin:/sbin"

. /opt/venv/salt/bin/activate
exec "/opt/venv/salt/bin/$wanted_cmd" "$@"
echo "ULTIMATE FAILURE MODE"
exit 666
