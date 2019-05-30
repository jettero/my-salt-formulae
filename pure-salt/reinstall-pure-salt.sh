#!/usr/bin/env bash

PS4=$'\e'"[1;32m"" +++ "$'\e[m'
SLV="${1:-${SLV:-v2018.3.2}}"

source /etc/profile.d/dl-repo.sh # gives dl_repo command

[ -d /opt/venv/salt -a -f /opt/venv/salt/bin/activate ] || /opt/pure/python/2.7/bin/virtualenv /opt/venv/salt

function pure_salt {
    unset PYTHONPATH LD_LIBRARY_PATH
    export PATH=/opt/venv/salt/bin:/usr/bin:/bin
    SLV="${1:-$SLV}"
    dl_repo https://github.com/saltstack/salt.git $SLV || return 1
    ( set -e -x
      umask 0022
      source /opt/venv/salt/bin/activate || return 1
      cd "$HOME/dlds/salt.git"
      # XXX: it shouldn't be necessary to install a specific version of tornado
      # like this, but what can ya do?
      pip install tornado==4.5.3
      pip install .
      ./setup.py --with-salt-version "${SLV#v}" build
      find build -type f -name _version.py -exec cp {} salt \;
      pip install .
      # this is meant to make sure we have the right version after install
      # force resintall with marked version
    )
}

pure_salt "$SLV" &> "/root/pure-salt-$SLV.log"
[ -f /usr/bin/install-pure-salt-python-apt.sh ] && bash /usr/bin/install-pure-salt-python-apt.sh
