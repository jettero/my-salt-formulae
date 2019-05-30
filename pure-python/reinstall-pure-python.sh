#!/usr/bin/env bash

export LANG=en_US.utf8
export LANGUAGE=en_US.utf8
export LC_ALL=en_US.utf8

PS4=$'\e'"[1;32m"" +++ "$'\e[m'
PYV="${1:-${PYV:-3.6}}"

source /etc/profile.d/dl-repo.sh # gives dl_repo command

function pure_python {
    PYV="${1:-$PYV}"
    dl_repo https://github.com/python/cpython.git $PYV || return 1
    find /root/dlds/get-pip.py -mtime +2 -print0 | xargs -r0 rm -v
    if [ ! -f /root/dlds/get-pip.py ]
    then curl -o /root/dlds/get-pip.py -L https://bootstrap.pypa.io/get-pip.py
    fi
    ( set -e -x;

      # build
      mkdir -vp /root/build/pp-$PYV
      cd /root/build/pp-$PYV
      /root/dlds/cpython.git/configure \
          --prefix=/opt/pure/python/$PYV \
          --srcdir /root/dlds/cpython.git
      p=$(grep bogo /proc/cpuinfo | wc -l)
      j=$(( p + 1 ))
      make -j $j -l $p

      # install
      umask 022
      make install

      # fix basenames
      n=$( cut -d. -f1 <<< "$PYV" )
      for i in pip pydoc python; do
          for j in $n ''; do
              if [ -x /opt/pure/python/$PYV/bin/$i$PYV -a ! -x /opt/pure/python/$PYV/bin/$i$j ]; then
                  ln -sv $i$PYV /opt/pure/python/$PYV/bin/$i$j
              fi
          done
      done

      # install pip and virtualenv
      /opt/pure/python/$PYV/bin/python /root/dlds/get-pip.py
      /opt/pure/python/$PYV/bin/pip install --upgrade pip virtualenv ipython
    )
}

pure_python "$PYV" &> "/root/pure-python-$PYV.log"
