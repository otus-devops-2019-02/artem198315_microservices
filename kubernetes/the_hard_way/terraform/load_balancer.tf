resource "google_compute_http_health_check" "kubernetes" {
  name               = "kubernetes"
  request_path       = "/healthz"
  check_interval_sec = 5
  timeout_sec        = 5
}

resource "google_compute_firewall" "kubernetes-the-hard-way-allow-health-check" {
  depends_on = ["google_compute_network.kubernetes"]
  name    = "kubernetes-the-hard-way-allow-health-check"
  network = "${google_compute_network.kubernetes.name}"

  allow {
    protocol = "tcp"
  }
  source_ranges = ["209.85.152.0/22","209.85.204.0/22","35.191.0.0/16"]

}
resource "google_compute_target_pool" "kubernetes-target-pool" {
  name = "kubernetes"
  instances = ["${google_compute_instance.controllers.*.self_link}"]
  health_checks = ["${google_compute_http_health_check.kubernetes.name}"]
}

resource "google_compute_forwarding_rule" "kubernetes-forwarding-rule" {
  name       = "kubernetes"
  target     = "${google_compute_target_pool.default.self_link}"
  port_range = "6443"
  target = "${google_compute_target_pool.kubernetes-target-pool.self_link}"
  ip_address = "${google_compute_address.kubernetes-ext-ip.address}"
}

