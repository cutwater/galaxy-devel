FROM fedora:27

ENV PIP_NO_CACHE_DIR off

ENV PULP_VENV /var/lib/pulp/venv
ENV DJANGO_SETTINGS_MODULE pulpcore.app.settings

RUN dnf -y install \
        procps \
        tmux \
    && dnf -y clean all \
    && rm -rf /var/cache/dnf

RUN mkdir -p /etc/pulp \
             /var/lib/pulp \
             /var/run/pulp \
             /src \
             /tmp/build

COPY pulp-requirements.txt \
     pulp-plugin-requirements.txt \
     pulp-galaxy-requirements.txt \
     /tmp/build/

RUN python3 -m venv ${PULP_VENV}
RUN ${PULP_VENV}/bin/pip install -U pip \
    && ${PULP_VENV}/bin/pip install \
        -r /tmp/build/pulp-requirements.txt \
        -r /tmp/build/pulp-plugin-requirements.txt \
        -r /tmp/build/pulp-galaxy-requirements.txt \
    && rm -rfv /tmp/build/


COPY settings.py /etc/pulp/settings.py
COPY tmux.conf /var/lib/pulp/tmux.conf

COPY run.sh /run.sh
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]
