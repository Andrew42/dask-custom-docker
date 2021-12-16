# Docker image dask-custom-docker (Coffea + patched Dask Distributed)


_(To be tested with dask/dask k8s deployment for coffea-casa AF project)_

## How to build a Docker image

(_instead of `oshadura` please select preferable Dockerhub username_)

```
sudo docker build -t oshadura/coffea-custom-docker:2021.12.15 .

```

## How to push a Docker image

(_instead of `oshadura` please select preferable Dockerhub username_)

```
sudo docker push oshadura/coffea-custom-docker:2021.12.15
```

## Helm charts: Kubernetes deployment of Dask scheduler and 3 Dask workers

(see https://github.com/dask/helm-chart/tree/main/dask)

Before to try to test images please adjust images to be used in `values.yaml` in this repository, particularly `scheduler.image` and `scheduler.tag`

```
scheduler:
  name: scheduler  # Dask scheduler name.
  enabled: true  # Enable/disable scheduler.
  image:
    repository: "oshadura/coffea-custom-docker"  # Container image repository.
    tag: 2021.12.16  # Container image tag.
 ....
 ```
 
 and `worker.image` and `worker.tag`
 
 ```
 worker:
  name: worker  # Dask worker name.
  image:
    repository: "oshadura/coffea-custom-docker"  # Container image repository.
    tag: 2021.12.16  # Container image tag.
 ```
 
## How to test it with dask/dask Helm charts on Minikube 

```
helm repo add dask https://helm.dask.org/

helm repo update

helm upgrade --install dask-test -f values.yaml dask/dask

export DASK_SCHEDULER="127.0.0.1"
export DASK_SCHEDULER_UI_IP="127.0.0.1"
export DASK_SCHEDULER_PORT=8080
export DASK_SCHEDULER_UI_PORT=8081
kubectl port-forward --namespace default svc/dask-test-scheduler $DASK_SCHEDULER_PORT:8786 &
kubectl port-forward --namespace default svc/dask-test-scheduler $DASK_SCHEDULER_UI_PORT:80 &

export JUPYTER_NOTEBOOK_IP="127.0.0.1"
export JUPYTER_NOTEBOOK_PORT=8082
kubectl port-forward --namespace default svc/dask-test-jupyter $JUPYTER_NOTEBOOK_PORT:80 &
```

Try in the browser Dask dashboard:
```
echo http://$DASK_SCHEDULER_UI_IP:$DASK_SCHEDULER_UI_PORT
```
and  Jupyter notebook adress:
```
echo http://$JUPYTER_NOTEBOOK_IP:$JUPYTER_NOTEBOOK_PORT
```

## The simple example to test correctness of deployment:

To check Dask Client connection in terminal check its IP address:
```
echo tcp://$DASK_SCHEDULER:$DASK_SCHEDULER_PORT
```
and try in Jupyter notebook available `http://$JUPYTER_NOTEBOOK_IP:$JUPYTER_NOTEBOOK_PORT` using next code snippet:

```
from distributed import Client

client = Client('tcp://127.0.0.1:8080')

client
```

__IMPORTANT:__

If client is not working try to open `http://$DASK_SCHEDULER_UI_IP:$DASK_SCHEDULER_UI_PORT/info/main/workers.html` and check a Dask Scheduler IP address there.

## How to check logs

Use command `kubectl get pods` to see which pods are available in deployment:

```
kubectl get pods                                               INT ✘ │ minikube ⎈ │ 12:31:05 
NAME                                  READY   STATUS    RESTARTS      AGE
dask-test-jupyter-6d476dc55-f445c     1/1     Running   2 (18h ago)   18h
dask-test-scheduler-7bf8db777-n724b   1/1     Running   0             93m
dask-test-worker-6cc5f84c47-2vkxd     1/1     Running   0             92m
dask-test-worker-6cc5f84c47-ff29d     1/1     Running   0             93m
dask-test-worker-6cc5f84c47-vswxf     1/1     Running   0             92m
```
e.g.

```
~ kubectl logs dask-test-worker-6cc5f84c47-2vkxd                     ✔ │ minikube ⎈ │ 12:28:40 
distributed.nanny - INFO -         Start Nanny at: 'tcp://172.17.0.10:46011'
distributed.worker - INFO -       Start worker at:    tcp://172.17.0.10:39093
distributed.worker - INFO -          Listening to:    tcp://172.17.0.10:39093
distributed.worker - INFO -          dashboard at:           172.17.0.10:8790
distributed.worker - INFO - Waiting to connect to: tcp://dask-test-scheduler:8786
distributed.worker - INFO - -------------------------------------------------
distributed.worker - INFO -               Threads:                          4
distributed.worker - INFO -                Memory:                  11.70 GiB
distributed.worker - INFO -       Local Directory: /dask-worker-space/worker-juplvzdj
distributed.worker - INFO - -------------------------------------------------
distributed.worker - INFO -         Registered to: tcp://dask-test-scheduler:8786
distributed.worker - INFO - -------------------------------------------------
distributed.core - INFO - Starting established connection
distributed.nanny - INFO - Starting Nanny plugin upload-directory-workflows
distributed.worker - INFO - Run out-of-band function 'get_info'
distributed.nanny - INFO - Starting Nanny plugin upload-directory-examples
distributed.worker - INFO - Run out-of-band function 'get_info'
distributed.nanny - INFO - Starting Nanny plugin upload-directory-examples
distributed.worker - INFO - Run out-of-band function 'get_info'
```
If you need to ssh to worker try `kubectl exec --stdin --tty dask-test-worker-6cc5f84c47-ff29d -- /bin/bash`:
```
kubectl exec --stdin --tty dask-test-worker-6cc5f84c47-ff29d -- /bin/bash
(base) root@dask-test-worker-6cc5f84c47-ff29d:/# ls -la
total 64
drwxr-xr-x   1 root root 4096 Dec 16 09:58 .
drwxr-xr-x   1 root root 4096 Dec 16 09:58 ..
-rwxr-xr-x   1 root root    0 Dec 16 09:58 .dockerenv
lrwxrwxrwx   1 root root    7 Oct  6 16:47 bin -> usr/bin
drwxr-xr-x   2 root root 4096 Apr 15  2020 boot
drwxr-xr-x   6 root root 4096 Dec 16 11:26 dask-worker-space
drwxr-xr-x   5 root root  360 Dec 16 09:58 dev
drwxr-xr-x   1 root root 4096 Dec 16 09:58 etc
drwxr-xr-x   2 root root 4096 Apr 15  2020 home
lrwxrwxrwx   1 root root    7 Oct  6 16:47 lib -> usr/lib
lrwxrwxrwx   1 root root    9 Oct  6 16:47 lib32 -> usr/lib32
lrwxrwxrwx   1 root root    9 Oct  6 16:47 lib64 -> usr/lib64
lrwxrwxrwx   1 root root   10 Oct  6 16:47 libx32 -> usr/libx32
drwxr-xr-x   2 root root 4096 Oct  6 16:47 media
drwxr-xr-x   2 root root 4096 Oct  6 16:47 mnt
drwxr-xr-x   1 root root 4096 Dec  1 20:40 opt
dr-xr-xr-x 253 root root    0 Dec 16 09:58 proc
drwx------   1 root root 4096 Dec  1 20:40 root
drwxr-xr-x   1 root root 4096 Dec 16 09:58 run
lrwxrwxrwx   1 root root    8 Oct  6 16:47 sbin -> usr/sbin
drwxr-xr-x   2 root root 4096 Oct  6 16:47 srv
dr-xr-xr-x  13 root root    0 Dec 16 09:57 sys
drwxrwxrwt   1 root root 4096 Dec 16 09:52 tmp
drwxr-xr-x   1 root root 4096 Oct  6 16:47 usr
drwxr-xr-x   1 root root 4096 Oct  6 16:58 var
```
