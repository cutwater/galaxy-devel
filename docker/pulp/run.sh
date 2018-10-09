#!/bin/bash

set -o nounset
set -o errexit

run_server() {
    exec "${PULP_VENV}/bin/pulp-manager" runserver '0.0.0.0:8000'
}

run_resource_manager() {
    exec "${PULP_VENV}/bin/rq" worker \
        -w 'pulpcore.tasking.worker.PulpWorker' \
        -n 'resource_manager@%%h' \
        -c 'pulpcore.rqconfig' \
        --pid='/var/run/pulp/resource_manager.pid'
}

run_worker() {
    local _worker_id="$1"

    exec "${PULP_VENV}/bin/rq" worker \
        -w 'pulpcore.tasking.worker.PulpWorker' \
        -n "reserved_resource_worker_${_worker_id}@%h" \
        -c 'pulpcore.rqconfig' \
        --pid="/var/run/pulp/worker_${_worker_id}.pid"
}

main() {
    case "$1" in
        server)
            run_server
        ;;
        resource_manager)
            run_resource_manager
        ;;
        worker)
            run_worker "${@:2}"
        ;;
    esac
}

main "$@"
