output docker-instances {
  value = "${google_compute_instance.docker.*.network_interface.0.access_config.0.nat_ip}"
}
