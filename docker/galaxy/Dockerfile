FROM fedora:27

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV PYTHONUNBUFFERED 1
ENV PYTHONIOENCODING utf8
ENV PIP_NO_CACHE_DIR off

ENV GALAXY_HOME /var/lib/galaxy
ENV GALAXY_VENV /var/lib/galaxy/venv
ENV DJANGO_SETTINGS_MODULE galaxy.settings.development

ENV C_FORCE_ROOT 1

# Install node.js and yarn
RUN curl -sL -o '/tmp/nodesource-release-fc27-1.noarch.rpm' \
        'https://rpm.nodesource.com/pub_8.x/fc/27/x86_64/nodesource-release-fc27-1.noarch.rpm' \
    && rpm -i --nosignature --force '/tmp/nodesource-release-fc27-1.noarch.rpm' \
    && rm -f '/tmp/nodesource-release-fc27-1.noarch.rpm' \
    && curl -sL -o '/etc/yum.repos.d/yarn.repo' 'https://dl.yarnpkg.com/rpm/yarn.repo' \
    && dnf -y install nodejs yarn \
    && dnf -y clean all \
    && rm -rf /var/cache/yum

RUN dnf -y install \
        findutils gcc git make \
        vim tmux ShellCheck \
        python-devel \
    && dnf -y clean all \
    && rm -rf /var/cache/dnf

# Install node dependencies
RUN yarn global add @angular/cli@6.1.2 \
    && ng set --global packageManager=yarn

# Install python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN mkdir -p "${GALAXY_VENV}" \
    && pip install virtualenv \
    && virtualenv /var/lib/galaxy/venv \
    && "${GALAXY_VENV}/bin/pip" install -U pip wheel flake8 \
    && "${GALAXY_VENV}/bin/pip" install -r /tmp/requirements.txt

RUN git clone https://github.com/ansible/galaxy-lint-rules.git /usr/local/galaxy-lint-rules

COPY tmux.conf "${GALAXY_HOME}/tmux.conf"
COPY run.sh /run.sh
COPY entrypoint.sh /entrypoint.sh

WORKDIR /galaxy
ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]
