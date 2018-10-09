#!/bin/bash

set -o nounset
set -o errexit

wait_tcp_port() {
    local _host="$1"
    local _port="$2"

    until timeout 1 bash -c "> /dev/tcp/${_host}/${_port} 2> /dev/null"; do
        echo "Waiting for TCP port ${_host}:${_port}..."
        sleep 1
    done
}

activate_virtualenv() {
    echo "Activating virtual environment \"${GALAXY_VENV}\"..."
    # shellcheck disable=SC1090
    VIRTUAL_ENV_DISABLE_PROMPT=1 \
        source "${GALAXY_VENV}/bin/activate"
}

install_dev_packages() {
    echo "Installing development packages..."
    "${GALAXY_VENV}/bin/pip" install -q -e /galaxy
}

run_migrations() {
    "${GALAXY_VENV}/bin/galaxy-manage" migrate --noinput
}

prepare_env() {
    activate_virtualenv
    install_dev_packages
    wait_tcp_port 'postgres' '5432'
    run_migrations
    wait_tcp_port 'rabbitmq' '5672'
}

run_tmux() {
    echo "Starting tmux..."
    tmux start \; source "/var/lib/galaxy/tmux.conf"
}

wait_forever() {
    while sleep 3600; do :; done
}

main() {
    case "$1" in
        run)
            prepare_env
            run_tmux
            wait_forever
        ;;
        *)
            exec "$@"
        ;;
    esac
}

main "$@"
