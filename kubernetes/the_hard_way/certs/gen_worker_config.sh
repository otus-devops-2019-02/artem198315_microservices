#!/bin/bash
{

while test -f /tmp/kube.lock; do
  sleep $[ ( $RANDOM % 6 )  + 3 ]s
done

touch /tmp/kube.lock

kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=${CERTS_PATH}/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${CONFIG_PATH}/${WORKER}.kubeconfig

  kubectl config set-credentials system:node:${WORKER} \
    --client-certificate=${CERTS_PATH}/${WORKER}.pem \
    --client-key=${CERTS_PATH}/${WORKER}-key.pem \
    --embed-certs=true \
    --kubeconfig=${CONFIG_PATH}/${WORKER}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${WORKER} \
    --kubeconfig=${CONFIG_PATH}/${WORKER}.kubeconfig

  kubectl config use-context default --kubeconfig=${CONFIG_PATH}/${WORKER}.kubeconfig

rm -rf /tmp/kube.lock
}
