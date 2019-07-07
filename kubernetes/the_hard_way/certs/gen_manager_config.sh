#!/bin/bash
{
kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=${CERTS_PATH}/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=${CONFIG_PATH}/kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=${CERTS_PATH}/kube-controller-manager.pem \
    --client-key=${CERTS_PATH}/kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=${CONFIG_PATH}/kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=${CONFIG_PATH}/kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=${CONFIG_PATH}/kube-controller-manager.kubeconfig
}
