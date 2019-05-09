variable project {
  type = "string"
}

variable region {
  type = "string"
  default = "europe-west3"
}

variable zone {
  type = "string"
  default = "europe-west3-c"
}

variable disk_image {
  type = "string"
}

variable private_key_path {
  type = "string"
}

variable public_key_path {
  type = "string"
}

variable hosts_count {
  type    = "string"
  default = "1"
}

variable docker_disk_image {
  description = "Disk image for docker"
  default     = "ubuntu-1604-lts"
}
