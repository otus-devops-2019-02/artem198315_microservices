resource "google_compute_instance" "workers" {
  count        = "${var.workers_count}"
  name         = "worker-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"
  can_ip_forward = true

  tags = ["workers"]

  metadata { 
    pod-cidr = "10.200.${count.index}.0/24"
  }

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
      size = 200
    }
  }

  network_interface {
    network = "${google_compute_network.kubernetes.self_link}"
    subnetwork = "${google_compute_subnetwork.kubernetes.self_link}"
    network_ip  = "10.240.0.2${count.index}"

    access_config { }

  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file("${var.private_key_path}")}"
  }

  depends_on = ["google_compute_subnetwork.kubernetes","null_resource.admin_cert"]
}


