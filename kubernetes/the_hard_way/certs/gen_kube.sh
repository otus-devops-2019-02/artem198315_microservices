#!/bin/bash

cat > $CONFIG_PATH/kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

echo "kube-controller"
echo $CERTS_PATH
echo $CONFIG_PATH
cat $CONFIG_PATH/ca-config.json
cat $CONFIG_PATH/kube-controller-manager-csr.json 
cfssl gencert \
  -ca=$CERTS_PATH/ca.pem \
  -ca-key=$CERTS_PATH/ca-key.pem \
  -config=$CONFIG_PATH/ca-config.json \
  -profile=kubernetes \
  $CONFIG_PATH/kube-controller-manager-csr.json | cfssljson -bare $CERTS_PATH/kube-controller-manager

cat > $CONFIG_PATH/kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

echo "kube-proxy"
cfssl gencert \
  -ca=$CERTS_PATH/ca.pem \
  -ca-key=$CERTS_PATH/ca-key.pem \
  -config=$CONFIG_PATH/ca-config.json \
  -profile=kubernetes \
  $CONFIG_PATH/kube-proxy-csr.json | cfssljson -bare $CERTS_PATH/kube-proxy

cat > $CONFIG_PATH/kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

echo "kube-scheduler"
cfssl gencert \
  -ca=$CERTS_PATH/ca.pem \
  -ca-key=$CERTS_PATH/ca-key.pem \
  -config=$CONFIG_PATH/ca-config.json \
  -profile=kubernetes \
  $CONFIG_PATH/kube-scheduler-csr.json | cfssljson -bare $CERTS_PATH/kube-scheduler


{

cat > $CONFIG_PATH/kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

echo "kubernates"
cfssl gencert \
  -ca=$CERTS_PATH/ca.pem \
  -ca-key=$CERTS_PATH/ca-key.pem \
  -config=$CONFIG_PATH/ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  $CONFIG_PATH/kubernetes-csr.json | cfssljson -bare $CERTS_PATH/kubernetes

}

cat > $CONFIG_PATH/service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=$CERTS_PATH/ca.pem \
  -ca-key=$CERTS_PATH/ca-key.pem \
  -config=$CONFIG_PATH/ca-config.json \
  -profile=kubernetes \
  $CONFIG_PATH/service-account-csr.json | cfssljson -bare $CERTS_PATH/service-account

