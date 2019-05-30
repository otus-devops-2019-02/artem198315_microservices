output instance_ext_ip_addr {
  value = "${google_compute_address.gitlab_ip.address}"
}

