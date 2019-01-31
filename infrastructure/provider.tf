variable "do_token" {}
variable "ssh_key_public" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "bastion" {
  name       = "terraform ${terraform.workspace}"
  public_key = "${file(var.ssh_key_public)}"
}

resource "digitalocean_tag" "cluster_infrastructure" {name = "cluster_infrastructure"}
resource "digitalocean_tag" "elasticsearch" {name = "elasticsearch"}
