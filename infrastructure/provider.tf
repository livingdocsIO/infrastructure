variable "do_token" {}
variable "ssh_key_public" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "bastion" {
  name       = "terraform ${terraform.workspace}"
  public_key = "${file(var.ssh_key_public)}"
}
