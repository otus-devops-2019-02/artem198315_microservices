{
    "insecure-registries": ["127.0.0.1:5000"],
    "hosts": ["unix://"],
    "labels": ["container_run=true"],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "50m",
      "max-file": "3"
    }
}

