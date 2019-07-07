#!/bin/bash

cat > $CONFIG_PATH/${WORKER}-csr.json <<EOF
{
  "CN": "system:node:${WORKER}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
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
  -hostname=${WORKER},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  $CONFIG_PATH/${WORKER}-csr.json | cfssljson -bare $CERTS_PATH/${WORKER}

