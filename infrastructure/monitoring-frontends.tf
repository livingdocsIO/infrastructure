resource "random_id" "monitoring" {
  count = "1"
  prefix = "monitoring-"
  byte_length = 8
}

resource "digitalocean_tag" "monitoring" {name = "monitoring"}

data "template_file" "cloud_init_monitoring" {
  template = "${file("${path.module}/templates/cloud-config.yml")}"
  vars {}
}

resource "digitalocean_droplet" "monitoring" {
  count = "1"
  name = "${element(random_id.monitoring.*.hex, count.index)}"
  image = "rancheros"
  region = "fra1"
  size = "s-2vcpu-4gb"
  private_networking = true
  backups = false
  ipv6 = false
  ssh_keys = ["${digitalocean_ssh_key.bastion.fingerprint}"]
  user_data = "${data.template_file.cloud_init_monitoring.rendered}"
  tags = ["${digitalocean_tag.monitoring.id}"]
}

resource "digitalocean_firewall" "monitoring" {
  name = "monitoring"
  droplet_ids = ["${digitalocean_droplet.monitoring.*.id}"]

  inbound_rule = [{
    protocol         = "tcp"
    port_range       = "22"
    source_tags      = ["bastion"]
  }, { # monitoring http port
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }, { # node exporter
    protocol              = "tcp"
    port_range            = "9100"
    source_tags = ["prometheus"]
  }, { # cadvisor
    protocol              = "tcp"
    port_range            = "8080"
    source_tags = ["prometheus"]
  }]

  outbound_rule = [{
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }, {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }, {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }, {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }, {
    protocol              = "tcp"
    port_range            = "9000-9400"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }]
}

output "monitoring" {
  value = "${zipmap(digitalocean_droplet.monitoring.*.name, digitalocean_droplet.monitoring.*.ipv4_address)}"
}
