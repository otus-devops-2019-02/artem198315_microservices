resource "google_compute_instance" "controllers" {
  count        = "${var.controllers_count}"
  name         = "controller-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"
  can_ip_forward = true

  tags = ["controllers"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
      size = 200
    }
  }

  network_interface {
    network = "${google_compute_network.kubernetes.self_link}"
    subnetwork = "${google_compute_subnetwork.kubernetes.name}"
    network_ip  = "10.240.0.1${count.index}"

    access_config {}

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


}


