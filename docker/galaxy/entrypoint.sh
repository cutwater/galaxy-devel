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
    echo "Installing pulp packages..."
    "${GALAXY_VENV}/bin/pip" install -e /pulp/pulpcore
    "${GALAXY_VENV}/bin/pip" install -e /pulp/plugin
    echo "Installing galaxy packages..."
    "${GALAXY_VENV}/bin/pip" install -e /galaxy
}

run_migrations() {
    "${GALAXY_VENV}/bin/galaxy-manage" makemigrations --noinput pulp_app
    "${GALAXY_VENV}/bin/galaxy-manage" makemigrations --noinput pulp_galaxy
    "${GALAXY_VENV}/bin/galaxy-manage" migrate --noinput
    "${GALAXY_VENV}/bin/galaxy-manage" reset-admin-password --password admin
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
