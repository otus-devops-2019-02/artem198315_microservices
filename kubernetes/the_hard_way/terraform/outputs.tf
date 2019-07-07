output instance_ext_ip_addr {
  value = "${google_compute_address.kubernetes-ext-ip.address}"
}

