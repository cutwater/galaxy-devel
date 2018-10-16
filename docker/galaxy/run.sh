#!/bin/bash

set -o nounset
set -o errexit

run_server() {
    exec "${GALAXY_VENV}/bin/galaxy-manage" runserver '0.0.0.0:8888'
}

run_webproxy() {
    cd /galaxy/galaxyui
    exec ng serve --disable-host-check \
        --host 0.0.0.0 --port 8000 \
        --poll 5000 --watch --live-reload \
        --progress=false --proxy-config proxy.conf.js

}

run_galaxy_worker() {
    exec "${GALAXY_VENV}/bin/galaxy-manage" celeryd -B --autoreload \
        -Q 'celery,import_tasks,login_tasks,admin_tasks,user_tasks,star_tasks'
}

run_pulp_resource_manager() {
    exec "${GALAXY_VENV}/bin/rq" worker \
        -w 'pulpcore.tasking.worker.PulpWorker' \
        -n 'resource_manager@%%h' \
        -c 'pulpcore.rqconfig' \
        --pid='/var/run/pulp/resource_manager.pid'
}

run_pulp_worker() {
    local _worker_id="$1"

    exec "${GALAXY_VENV}/bin/rq" worker \
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
        webproxy)
            run_webproxy
        ;;
        galaxy_worker)
            run_galaxy_worker
        ;;
        pulp_resource_manager)
            run_pulp_resource_manager
        ;;
        pulp_worker)
            run_pulp_worker "${@:2}"
        ;;
    esac
}

main "$@"
