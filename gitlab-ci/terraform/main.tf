terraform {
  required_version = "~> 0.11"
}

provider "google" {
  //credentials = "${file("account.json")}"
  project = "${var.project}"
  region  = "${var.region}"
}



