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

__If client is not working try to open `http://$DASK_SCHEDULER_UI_IP:$DASK_SCHEDULER_UI_PORT/info/main/workers.html` and check a Dask Scheduler IP address there.
