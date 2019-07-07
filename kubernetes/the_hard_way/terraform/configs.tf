resource "null_resource" "kube_proxy_config" {
  depends_on = ["google_compute_address.kubernetes-ext-ip", "null_resource.admin_cert","null_resource.kube_cert","null_resource.encryption_key"]

  provisioner "local-exec" {
    command = "../certs/gen_proxy_config.sh"

    environment = {
      CONFIG_PATH = "${var.config_path}"
      CERTS_PATH = "${var.certs_path}"
      KUBERNETES_PUBLIC_ADDRESS = "${google_compute_address.kubernetes-ext-ip.address}"
    }
  }
}


resource "null_resource" "kube_manager_config" {
  depends_on = ["google_compute_address.kubernetes-ext-ip", "null_resource.admin_cert","null_resource.kube_cert","null_resource.kube_proxy_config","null_resource.encryption_key"]

  provisioner "local-exec" {
    command = "../certs/gen_manager_config.sh"

    environment = {
      CONFIG_PATH = "${var.config_path}"
      CERTS_PATH = "${var.certs_path}"
    }
  }
}

resource "null_resource" "kube_scheduler_config" {
  depends_on = ["null_resource.admin_cert","null_resource.kube_cert","null_resource.kube_manager_config","null_resource.encryption_key"]

  provisioner "local-exec" {
    command = "../certs/gen_scheduler_config.sh"

    environment = {
      CONFIG_PATH = "${var.config_path}"
      CERTS_PATH = "${var.certs_path}"
    }
  }
}


resource "null_resource" "kube_admin_config" {
  depends_on = ["null_resource.admin_cert","null_resource.kube_cert","null_resource.kube_scheduler_config","null_resource.encryption_key"]

  provisioner "local-exec" {
    command = "../certs/gen_admin_config.sh"

    environment = {
      CONFIG_PATH = "${var.config_path}"
      CERTS_PATH = "${var.certs_path}"
    }
  }
}

resource "null_resource" "workers_config" {
  count        = "${var.workers_count}"
  depends_on = ["google_compute_instance.workers","null_resource.admin_cert", "null_resource.kube_cert", "null_resource.workers_cert","null_resource.encryption_key","null_resource.kube_admin_config"]

  provisioner "local-exec" {
   command = "../certs/gen_worker_config.sh"

   environment = {
      CONFIG_PATH = "${var.config_path}"
      CERTS_PATH = "${var.certs_path}"
      WORKER = "${element(google_compute_instance.workers.*.name, count.index)}"
      KUBERNETES_PUBLIC_ADDRESS = "${google_compute_address.kubernetes-ext-ip.address}"
    }
  }
}
