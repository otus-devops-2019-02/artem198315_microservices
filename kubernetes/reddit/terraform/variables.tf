variable project {
  type        = "string"
  description = "project id"
}

variable zone {
  type    = "string"
  default = "europe-west3-c"
}

variable region {
  type    = "string"
  default = "europe-west3"
}

variable public_key_path {
  type = "string"
}

variable private_key_path {
  type = "string"
}

variable node_count {
  type = "string"
  default = "1"
}
