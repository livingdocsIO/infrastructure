resource "random_id" "prometheus" {
  count = "1"
  prefix = "prometheus-"
  byte_length = 8
}

resource "digitalocean_tag" "prometheus" {name = "prometheus"}

data "template_file" "cloud_init_prometheus" {
  template = "${file("${path.module}/templates/cloud-config.yml")}"
  vars {}
}

resource "digitalocean_droplet" "prometheus" {
  count = "1"
  name = "${element(random_id.prometheus.*.hex, count.index)}"
  image = "rancheros"
  region = "fra1"
  size = "s-2vcpu-4gb"
  private_networking = true
  backups = false
  ipv6 = false
  ssh_keys = ["${digitalocean_ssh_key.bastion.fingerprint}"]
  user_data = "${data.template_file.cloud_init_prometheus.rendered}"
  tags = ["${digitalocean_tag.prometheus.id}"]

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "digitalocean_firewall" "prometheus" {
  name = "prometheus"
  droplet_ids = ["${digitalocean_droplet.prometheus.*.id}"]

  inbound_rule = [{
    protocol         = "tcp"
    port_range       = "22"
    source_tags      = ["${digitalocean_tag.bastion.name}"]
  }, { # Prometheus http port
    protocol         = "tcp"
    port_range       = "9090"
    source_tags      = ["${digitalocean_tag.bastion.name}", "${digitalocean_tag.monitoring.name}"]
    # source_addresses = ["0.0.0.0/0", "::/0"]
  }, { # node exporter
    protocol              = "tcp"
    port_range            = "9100"
    source_tags      = ["${digitalocean_tag.prometheus.name}"]
  }, { # cadvisor
    protocol              = "tcp"
    port_range            = "8080"
    source_tags      = ["${digitalocean_tag.prometheus.name}"]
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
    port_range            = "8080-9400"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }]
}

output "prometheus" {
  value = "${zipmap(digitalocean_droplet.prometheus.*.name, digitalocean_droplet.prometheus.*.ipv4_address)}"
}
