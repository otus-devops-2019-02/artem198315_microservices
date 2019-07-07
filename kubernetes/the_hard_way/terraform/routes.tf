resource "google_compute_route" "kubernetes-route" {
  count       = "${var.workers_count}"
  name        = "kubernetes-route-10-200-${count.index}-0-24"
  dest_range  = "10.200.${count.index}.0/24"
  network     = "${google_compute_network.kubernetes.name}"
  next_hop_ip = "10.240.0.2${count.index}"
  priority    = 100
}

