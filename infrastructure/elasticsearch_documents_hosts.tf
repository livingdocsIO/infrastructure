variable "es_ld_fra1_node_prefix" {default = "es-ld-fra1"}
variable "es_ld_fra1_cluster_name" {default = "es_ld_fra1"}
variable "es_ld_fra1_cluster_region" {default = "fra1"}

resource "random_id" "es_ld_fra1" {
  count = "3"
  prefix = "${var.es_ld_fra1_node_prefix}-"
  byte_length = 8
}

resource "digitalocean_tag" "es_ld_fra1" {name = "${var.es_ld_fra1_cluster_name}"}
resource "digitalocean_tag" "cluster_es_ld_fra1" {name = "cluster_${var.es_ld_fra1_cluster_name}"}

data "template_file" "es_ld_fra1_init" {
  template = "${file("${path.module}/templates/cloud-config.yml")}"
  vars {}
}

resource "digitalocean_droplet" "es_ld_fra1" {
  count = "3"
  name = "${element(random_id.es_ld_fra1.*.hex, count.index)}"
  image = "rancheros"
  region = "${var.es_ld_fra1_cluster_region}"
  size = "s-2vcpu-4gb"
  private_networking = true
  backups = false
  ipv6 = false
  ssh_keys = ["${digitalocean_ssh_key.bastion.fingerprint}"]
  user_data = "${data.template_file.es_ld_fra1_init.rendered}"
  tags = ["${digitalocean_tag.es_ld_fra1.id}", "${digitalocean_tag.cluster_es_ld_fra1.id}", "${digitalocean_tag.elasticsearch.id}"]

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "digitalocean_firewall" "es_ld_fra1" {
  name = "es-ld-fra1"
  droplet_ids = ["${digitalocean_droplet.es_ld_fra1.*.id}"]

  inbound_rule = [{
    protocol         = "tcp"
    port_range       = "22"
    source_tags      = ["${digitalocean_tag.bastion.name}"]
  }, { # ntp
    protocol         = "udp"
    port_range       = "123"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }, {
    protocol         = "tcp"
    port_range       = "9200"
    source_tags      = ["${digitalocean_tag.monitoring.name}", "${digitalocean_tag.prometheus.name}", "${digitalocean_tag.bastion.name}", "${digitalocean_tag.role_worker.name}"]
  }, {
    protocol         = "tcp"
    port_range       = "9200-9400"
    source_tags      = ["${digitalocean_tag.es_ld_fra1.name}"]
  }, { # node prometheus exporter
    protocol              = "tcp"
    port_range            = "9100"
    source_tags      = ["${digitalocean_tag.prometheus.name}"]
  }, { # cadvisor prometheus exporter
    protocol              = "tcp"
    port_range            = "8080"
    source_tags = ["${digitalocean_tag.prometheus.name}"]
  }, { # coredns prometheus exporter
    protocol              = "tcp"
    port_range            = "9153"
    source_tags = ["${digitalocean_tag.prometheus.name}"]
  }, { # elasticsearch exporter
    protocol              = "tcp"
    port_range            = "9108"
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
    protocol = "tcp"
    port_range = "9200-9400"
    destination_tags = ["${digitalocean_tag.es_ld_fra1.name}"]
  }, {
    protocol              = "tcp"
    port_range            = "53-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  },
  {
    protocol              = "udp"
    port_range            = "53-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }]
}

output "es_ld_fra1" {
  value = "${zipmap(digitalocean_droplet.es_ld_fra1.*.name, digitalocean_droplet.es_ld_fra1.*.ipv4_address)}"
}

