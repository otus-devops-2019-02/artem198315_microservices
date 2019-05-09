terraform {
  required_version = "~> 0.11"
}

provider "google" {
  //credentials = "${file("account.json")}"
  project = "${var.project}"
  region  = "${var.region}"
}


resource "google_compute_instance" "docker" {
  count        = "${var.hosts_count}"
  name         = "docker-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  tags = ["docker"]

  boot_disk {
    initialize_params {
      image = "${var.docker_disk_image}"
    }
  }

  network_interface {
    network = "default"

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
}

resource "google_compute_firewall" "firewall-puma" {
  name        = "allow-puma"
  description = "firewall rule for access to reddit app"
  priority    = "1000"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292","80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["docker"]
}



