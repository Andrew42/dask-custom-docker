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
    
ENTRYPOINT ["tini", "-g", "--"]
