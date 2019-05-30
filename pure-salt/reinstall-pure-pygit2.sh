#!/bin/bash

PS4=$'\e'"[1;32m"" +++ "$'\e[m'
LG2V="${1:-${LG2V:-v0.27.1}}"
PREFIX="${2:-${PREFIX:-/usr}}"

source /etc/profile.d/dl-repo.sh # gives dl_repo command

function pure_libgit2 {
    unset PYTHONPATH LD_LIBRARY_PATH LDFLAGS CFLAGS
    export PATH=/usr/bin:/bin:/usr/sbin:/sbin
    LG2V="${1:-${LG2V:-v0.27.1}}"
    PREFIX="${2:-${PREFIX:-/usr}}"

    [ "X$PYG2_ONLY" = X1 ] || \
        dl_repo https://github.com/libgit2/libgit2.git "$LG2V" || return 1

    ( set -e

      umask 0022

      if [ ! "X$PYG2_ONLY" = X1 ]; then
          set -x
          # we run into rare build (actually test) problems if tests/.clarcache and
          # tests/clar.suite are populated in the repo dir before we invoke cmake
          cd /root/dlds/libgit2.git
          git clean -dfx

          bdir="$HOME/build/libgit2-$LG2V"
          mkdir -p "$bdir" || true
          cd "$bdir"

          cmake /root/dlds/libgit2.git "-DCMAKE_INSTALL_PREFIX=$PREFIX" -DTHREADSAFE=on -DCMAKE_BUILD_TYPE=Release
          p=$(grep bogo /proc/cpuinfo | wc -l)
          make -j $(( p + 3 )) -l $(( p + 1 )) install
          ldconfig
          set +x
      fi

      if [ -d /opt/venv/salt/bin -a -x /opt/venv/salt/bin/pip ]; then
          cd /root
          PATH=/opt/venv/salt/bin:$PATH
          source /opt/venv/salt/bin/activate

          # NOTE: pygit2 is a total cunt
          # to test flipping versions, use something like this:
          #
          # PREFIX=/usr LG2V=0.27.1 bash ~jettero/salt/state/salt/reinstall-pure-libgit2.sh
          # PREFIX=/usr/local LG2V=0.26.0 bash ~jettero/salt/state/salt/reinstall-pure-libgit2.sh
          # PREFIX=/usr LG2V=0.27.1 bash ~jettero/salt/state/salt/reinstall-pure-libgit2.sh
          #
          # we print the ldd output at the end, and you can clearly see it working like this:
          # Successfully installed cffi-1.11.5 pycparser-2.18 pygit2-0.27.1 six-1.11.0
          # /opt/venv/salt/lib/python2.7/site-packages/_pygit2.so
          #         libgit2.so.27 => /usr/lib/libgit2.so.27 (0x00007f72416e7000)

          # you really do need LIBGIT2 set I guess (used in
          # pygit2/_build.py:get_libgit2_paths)
          export LIBGIT2="$PREFIX"     
          export LIBGIT2_LIB="$PREFIX/lib"
          export C_INCLUDE_PATH="$PREFIX/include"         
          export LIBRARY_PATH="$PREFIX/lib"    
          export LD_LIBRARY_PATH="$PREFIX/lib"
          export LDFLAGS="-Wl,-rpath='$PREFIX/lib',--enable-new-dtags"
          (set -x; pip install --force-reinstall --no-binary --ignore-installed pygit2==${LG2V#v} )

          for i in $(find /opt/venv/salt -name _pygit2.so)
          do echo "$i"; ldd "$i" | grep libgit2
          done

          iv="$(python -c 'import pygit2; print(pygit2.__version__)')"
          # assert correct installation
          [ "$iv" = "${LG2V#v}" ] || exit 1
      fi
    )
}

pure_libgit2 "$LG2V" &> "/root/pure-libgit2-$LG2V.log"
