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

run_worker() {
    exec "${GALAXY_VENV}/bin/galaxy-manage" celeryd -B --autoreload \
        -Q 'celery,import_tasks,login_tasks,admin_tasks,user_tasks,star_tasks'
}

main() {
    case "$1" in
        server)
            run_server
        ;;
        webproxy)
            run_webproxy
        ;;
        worker)
            run_worker
        ;;
    esac
}

main "$@"
