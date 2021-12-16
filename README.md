# Docker image dask-custom-docker (Coffea + patched Dask Distributed)


_(To be tested on dask/dask deployment)_

## How to build an image

(_instead of `oshadura` please select preferable Dockerhub username_)

```
sudo docker build -t oshadura/coffea-custom-docker:2021.12.15 .

```

## How to push an image

(_instead of `oshadura` please select preferable Dockerhub username_)

```
sudo docker push oshadura/coffea-custom-docker:2021.12.15
```

# How to test it with dask/dask Helm charts on Minikube 

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

Try in the browser Dask dashboard:
```
echo http://$DASK_SCHEDULER_UI_IP:$DASK_SCHEDULER_UI_PORT
```
and  Jupyter notebook adress:
```
echo http://$JUPYTER_NOTEBOOK_IP:$JUPYTER_NOTEBOOK_PORT
```

To check Dask Client connection:
```
echo tcp://$DASK_SCHEDULER:$DASK_SCHEDULER_PORT
```
and try in Jyputernotebook using the code snippet:

```
from distributed import Client

client = Client('tcp://127.0.0.1:8080')

client
```
