FROM quay.io/jupyter/base-notebook:python-3.11.9

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        man-db \
        manpages \
        less \
        git \
    && set +o pipefail \
    && yes | unminimize \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir bash_kernel==0.9.3 \
    && python -m bash_kernel.install

COPY --chown=${NB_UID}:${NB_GID} lesson-content/ /home/jovyan/

WORKDIR /home/jovyan

USER ${NB_UID}