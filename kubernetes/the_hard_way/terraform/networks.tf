resource "google_compute_network" "kubernetes" {
  name = "kubernetes-the-hard-way"
  #zone = "${var.zone}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "kubernetes" {
  name   = "kubernetes"
  #zone = "${var.zone}"
  network = "${google_compute_network.kubernetes.self_link}" 
  ip_cidr_range = "10.240.0.0/24"
  depends_on = ["google_compute_network.kubernetes"]
  
}

resource "google_compute_address" "kubernetes-ext-ip" {
  name = "ext-ip"
}
