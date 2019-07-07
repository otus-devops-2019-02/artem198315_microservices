#!/bin/bash

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=${CERTS_PATH}/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=${CONFIG_PATH}/admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=${CERTS_PATH}/admin.pem \
    --client-key=${CERTS_PATH}/admin-key.pem \
    --embed-certs=true \
    --kubeconfig=${CONFIG_PATH}/admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=${CONFIG_PATH}/admin.kubeconfig

  kubectl config use-context default --kubeconfig=${CONFIG_PATH}/admin.kubeconfig
}
