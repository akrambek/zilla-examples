#!/bin/bash
set -ex

# Install Zilla to the Kubernetes cluster with helm and wait for the pod to start up
ZILLA_CHART=oci://ghcr.io/aklivity/charts/zilla
helm install mqtt-proxy-asyncapi $ZILLA_CHART --namespace mqtt-proxy-asyncapi --create-namespace --wait \
    --values values.yaml \
    --set-file zilla\\.yaml=zilla.yaml

# Install mosquitto mqtt broker to the Kubernetes cluster with helm and wait for the pod to start up
helm install mqtt-proxy-asyncapi-mosquitto chart --namespace mqtt-proxy-asyncapi --create-namespace --wait


# Start port forwarding
kubectl port-forward --namespace mqtt-proxy-asyncapi service/mqtt-proxy-asyncapi-zilla 1883 > /tmp/kubectl-zilla.log 2>&1 &
kubectl port-forward --namespace mqtt-proxy-asyncapi service/mosquitto 1884 > /tmp/kubectl-mosquitto.log 2>&1 &
until nc -z localhost 1883; do sleep 1; done
until nc -z localhost 1884; do sleep 1; done