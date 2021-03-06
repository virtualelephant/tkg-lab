#!/bin/bash -e

kubectl config use-context $CLUSTER_NAME-admin@$CLUSTER_NAME

helm upgrade -n tanzu-system-auth --create-namespace --install gangway ./tkg-extensions-helm-charts/gangway-0.1.0.tgz \
--set gangway.secret=$(echo -n $SECRET | base64) \
--set gangway.secretKey=$(openssl rand -base64 32) \
--set cluster.name=$CLUSTER_NAME \
--set cluster.apiServerName=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}") \
--set dex.hostname=$(yq r $PARAM_FILE dex.host) \
--set ingress.host=$GANGWAY_INGRESS

kubectl create cm dex-ca -n tanzu-system-auth --from-file=dex-ca.crt=./management-cluster-setup/generated/dex-ca.crt