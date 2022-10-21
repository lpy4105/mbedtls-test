#!/bin/sh

# Build the specified Dockerfile(s).
# Follow the image naming convention used on Jenkins, which uses a hash
# of the Dockerfile contents.

set -e

if [ $# -eq 0 ] || [ "$1" = "--help" ]; then
    cat <<EOF
Usage: $0 DIR/Dockerfile[...]
Build the specified Docker images.
EOF
    exit
fi

list_sh="$(dirname -- "$0")/list-docker-image-tags.sh"

USR_NAME=$(id -un)
USR_ID=$(id -u)
USR_GRP=$(id -g)

build () {
    name="mbedtls-test/$1"
    if [ -d "$1" ]; then
        set -- "$1/Dockerfile"
    fi
    tag="$("$list_sh" "$1")"
    sudo docker build \
        --build-arg USER_NAME="${USR_NAME}" \
        --build-arg USER_UID="${USR_ID}"\
        --build-arg USER_GID="${USR_GRP}" \
        --network=host -t "$name:$tag" -f "$1" "${1%/*}"
}

for d in "$@"; do
    build "$d"
done
