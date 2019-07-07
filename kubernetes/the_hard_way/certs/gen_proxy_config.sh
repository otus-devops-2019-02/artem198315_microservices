#!/bin/bash
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=${CERTS_PATH}/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${CONFIG_PATH}/kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=${CERTS_PATH}/kube-proxy.pem \
    --client-key=${CERTS_PATH}/kube-proxy-key.pem \
    --embed-certs=true  \
    --kubeconfig=${CONFIG_PATH}/kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=${CONFIG_PATH}/kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=${CONFIG_PATH}/kube-proxy.kubeconfig
}
