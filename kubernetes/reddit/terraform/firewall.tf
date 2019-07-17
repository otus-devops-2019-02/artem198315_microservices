resource "google_compute_firewall" "kubernetes" {
  name    = "kubernetes-allow-all"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  allow {
    protocol = "udp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}

