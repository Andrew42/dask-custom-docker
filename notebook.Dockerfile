FROM coffeateam/coffea-dask:0.7.11-fastjet-3.3.4.0rc9-g18b0c8c

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    patch

# FIXME: merge PRs open in distributed.git (oshadura)
# Distributed: we need to install patched version of distributed version
COPY distributed /opt/conda/lib/python3.8/site-packages/distributed
RUN cd /opt/conda/lib/python3.8/site-packages/distributed && \
    patch -p2 < 0001-Patch-from-bbockelman-adaptive-scaling.patch && \
    patch -p2 < 0002-Allow-scheduler-to-preserve-worker-hostnames.patch && \
    patch -p2 < 0003-Activate-patch.patch && \
    patch -p2 < 0004-Add-possibility-to-setup-external_adress-for-schedul.patch && \
    patch -p2 < 0005-Add-patch-from-John-Thiltges.patch
    
ADD prepare-env.sh /usr/local/bin/
RUN chmod ugo+x /usr/local/bin/prepare-env.sh

# Copy local files as late as possible to avoid cache busting
COPY start.sh start-notebook.sh /usr/local/bin/

# Switch back to cms-jovyan to avoid accidental container runs as root
USER ${NB_UID}
WORKDIR $HOME
#ENTRYPOINT ["tini", "-g", "--"]
ENTRYPOINT ["tini", "-g", "--", "/usr/local/bin/prepare-env.sh"]

# Extra packages to be installed (apt, pip, conda) and commands to be executed
# Use bash login shell for entrypoint in order
# to automatically source user's .bashrc
CMD ["start-notebook.sh"]
