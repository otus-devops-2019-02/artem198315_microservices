variable project {
  type        = "string"
  description = "project id"
}

variable region {
  type    = "string"
  default = "europe-west3"
}

variable zone {
  type    = "string"
  default = "europe-west3-c"
}

variable disk_image {
  type = "string"
}

variable public_key_path {
  type = "string"
}

variable private_key_path {
  type = "string"
}

variable controllers_count {
  type = "string"
}

variable workers_count {
  type = "string"
}

variable config_path {}

variable certs_path {}
