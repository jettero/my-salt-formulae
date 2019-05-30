# vi:ft=sh

function dl_repo {
    local repo="$1"
    local branch="${2:-master}"
    local depth="${3:-1}"
    local dir="$HOME/dlds/$( basename "$repo" )"
    local origin="$( \grep -oP '(?<=://)([^/]+?)(?=\.\w+/)' <<< "$repo" )"
    local _pwd="$(pwd)"

    if [[ ! "$dir" =~ \.git$ ]]
    then dir="$dir.git"
    fi

    # --branch (-b) can also take tags
    if ( set -x; git clone "$repo" "$dir" -o "$origin" --depth "$depth" -b "$branch" )
    then return 0
    elif (set -x; GIT_DIR="$dir/.git" git fetch "$origin" "$branch:remotes/$origin/$branch"); then
        if (set -x; cd "$dir" && git checkout -B "$branch" "remotes/$origin/$branch"); then
            if (set -x; cd "$dir" && git reset --hard "remotes/$origin/$branch")
            then return 0
            fi
        fi
    fi

    return 1
}
