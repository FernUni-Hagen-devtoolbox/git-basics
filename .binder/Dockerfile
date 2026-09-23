FROM quay.io/jupyter/base-notebook:python-3.11.9

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        less \
        man-db \
        manpages \
        nano \
    && set +o pipefail \
    && yes | unminimize \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir bash_kernel==0.9.3 \
    && python -m bash_kernel.install \
    && rm -rf /home/jovyan/.ipython

RUN git config --system user.name "Jovyan User" \
    && git config --system user.email "jovyan@binder.org" \
    && git config --system init.defaultBranch main \
    && git config --system core.editor nano

RUN printf '%s\n' \
        "alias taskflow-initial='bash /home/jovyan/scripts/create-initial-files.sh >/dev/null 2>&1'" \
        "alias taskflow-modify-readme='bash /home/jovyan/scripts/modify-readme.sh >/dev/null 2>&1'" \
        "alias taskflow-conflict='bash /home/jovyan/scripts/create-conflict-state.sh >/dev/null 2>&1'" \
        "alias taskflow-analyse='bash /home/jovyan/scripts/prepare-taskflow-analyse.sh >/dev/null 2>&1'" \
        "alias taskflow-history='bash /home/jovyan/scripts/prepare-taskflow-history-undo.sh >/dev/null 2>&1'" \
        "alias taskflow-undo-challenge='bash /home/jovyan/scripts/prepare-taskflow-undo-challenge.sh >/dev/null 2>&1'" \
        "alias taskflow-branches='bash /home/jovyan/scripts/prepare-taskflow-branches.sh >/dev/null 2>&1'" \
        "alias taskflow-branch-challenge='bash /home/jovyan/scripts/prepare-taskflow-branch-challenge.sh >/dev/null 2>&1'" \
        "alias taskflow-remotes='bash /home/jovyan/scripts/prepare-taskflow-remotes.sh >/dev/null 2>&1'" \
        "alias taskflow-remotes-challenge='bash /home/jovyan/scripts/prepare-taskflow-remotes-challenge.sh >/dev/null 2>&1'" \
        "alias taskflow-simulate-remotes='bash /home/jovyan/scripts/simulate-taskflow-remotes.sh >/dev/null 2>&1'" \
        "alias taskflow-collaboration='bash /home/jovyan/scripts/prepare-taskflow-collaboration.sh >/dev/null 2>&1'" \
        "alias taskflow-collaboration-challenge='bash /home/jovyan/scripts/prepare-taskflow-collaboration-challenge.sh >/dev/null 2>&1'" \
        "alias taskflow-review='bash /home/jovyan/scripts/review-taskflow-collaboration.sh'" \
        "alias taskflow-final='bash /home/jovyan/scripts/prepare-taskflow-final.sh >/dev/null 2>&1'" \
        "alias taskflow-version='bash /home/jovyan/scripts/add-taskflow-version.sh >/dev/null 2>&1'" \
        "alias taskflow-simulate-final='bash /home/jovyan/scripts/simulate-taskflow-final.sh >/dev/null 2>&1'" \
        "alias taskflow-check-final='python3 /home/jovyan/scripts/check-taskflow-final.py'" \
        >> /home/jovyan/.bashrc

COPY --chown=${NB_UID}:${NB_GID} lesson-content/ /home/jovyan/
COPY --chown=${NB_UID}:${NB_GID} .binder/workspaces/ /tmp/git-basics-workspaces/

WORKDIR /home/jovyan

USER ${NB_UID}

RUN for workspace in /tmp/git-basics-workspaces/*.jupyterlab-workspace; do \
        workspace_name="$(basename "${workspace}" .jupyterlab-workspace)"; \
        jupyter lab workspaces import --name "${workspace_name}" "${workspace}"; \
    done \
    && rm -rf /tmp/git-basics-workspaces
