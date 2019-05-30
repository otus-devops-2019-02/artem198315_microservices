resource "google_compute_address" "gitlab_ip" {
  name = "ext-ip"
}

resource "google_compute_instance" "gitlab" {
  count        = "${var.gitlab_count}"
  name         = "gitlab-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"

  tags = ["gitlab"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
      size = 50
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.gitlab_ip.address}"
    }
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


  #provisioner "remote-exec" {
  #  script = "files/deploy.sh"
  #}
}

resource "google_compute_firewall" "firewall-gitlab" {
  name        = "allow-gitlab"
  description = "firewall rule for access to gitlab app"
  priority    = "1000"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = ["443","80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gitlab"]
}

