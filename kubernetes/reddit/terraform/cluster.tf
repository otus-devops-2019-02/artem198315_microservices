resource "google_container_cluster" "reddit-cluster" {
  name               = "reddit-cluster"
  zone = "${var.zone}"
  initial_node_count = "${var.node_count}"

  node_config {
    preemptible  = true
    machine_type = "n1-standard-2"

    disk_size_gb = "40"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      app = "reddit"
    }
    tags = ["reddit-cluster"]
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
}
