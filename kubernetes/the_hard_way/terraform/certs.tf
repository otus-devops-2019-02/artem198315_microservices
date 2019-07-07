resource "null_resource" "admin_cert" {
  depends_on = ["google_compute_instance.controllers"]

  provisioner "local-exec" {
    command = "../certs/gen_admin.sh"

    environment = {
      CONFIG_PATH = "${var.config_path}"
      CERTS_PATH = "${var.certs_path}"
    }
  }
}

resource "null_resource" "kube_cert" {
  depends_on = ["google_compute_address.kubernetes-ext-ip","null_resource.workers_cert"]

  provisioner "local-exec" {
    command = "../certs/gen_kube.sh"

    environment = {
      CONFIG_PATH = "${var.config_path}"
      CERTS_PATH = "${var.certs_path}"
      KUBERNETES_PUBLIC_ADDRESS = "${google_compute_address.kubernetes-ext-ip.address}"
    }
  }
}

resource "null_resource" "workers_cert" {
  count        = "${var.workers_count}"
  depends_on = ["google_compute_instance.workers","null_resource.admin_cert"]

  provisioner "local-exec" {
   command = "../certs/gen_worker.sh"

   environment = {
      CONFIG_PATH = "${var.config_path}"
      CERTS_PATH = "${var.certs_path}"
      WORKER = "${element(google_compute_instance.workers.*.name, count.index)}"
      EXTERNAL_IP = "${element(google_compute_instance.workers.*.network_interface.0.access_config.0.nat_ip, count.index)}"
      INTERNAL_IP = "${element(google_compute_instance.workers.*.network_interface.0.network_ip, count.index)}"
    }
  }
}

resource "null_resource" "encryption_key" {

  provisioner "local-exec" {
   command = "../certs/gen_encryption.sh"

   environment = {
      CONFIG_PATH = "${var.config_path}"
   }
  }
}


