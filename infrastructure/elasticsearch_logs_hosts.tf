variable "elasticsearch_node_prefix" {default = "elasticsearch-logs"}
variable "elasticsearch_cluster_name" {default = "cluster_fra1_elasticsearch_logs"}
variable "elasticsearch_cluster_region" {default = "fra1"}

resource "random_id" "elasticsearch_logs" {
  count = "3"
  prefix = "${var.elasticsearch_node_prefix}-"
  byte_length = 8
}

resource "digitalocean_tag" "elasticsearch" {name = "elasticsearch"}
resource "digitalocean_tag" "cluster_fra1_elasticsearch_logs" {name = "${var.elasticsearch_cluster_name}"}

data "template_file" "cloud_init_elasticsearch" {
  template = "${file("${path.module}/templates/cloud-config.yml")}"
  vars {}
}

resource "digitalocean_droplet" "elasticsearch_logs" {
  count = "3"
  name = "${element(random_id.elasticsearch_logs.*.hex, count.index)}"
  image = "rancheros"
  region = "${var.elasticsearch_cluster_region}"
  size = "s-2vcpu-4gb"
  private_networking = true
  backups = false
  ipv6 = false
  ssh_keys = ["${digitalocean_ssh_key.bastion.fingerprint}"]
  user_data = "${data.template_file.cloud_init_elasticsearch.rendered}"
  tags = ["${digitalocean_tag.cluster_fra1_elasticsearch_logs.id}", "${digitalocean_tag.cluster_infrastructure.id}", "${digitalocean_tag.elasticsearch.id}"]

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "digitalocean_firewall" "elasticsearch" {
  name = "elasticsearch"
  droplet_ids = ["${digitalocean_droplet.elasticsearch_logs.*.id}"]

  inbound_rule = [{
    protocol         = "tcp"
    port_range       = "22"
    source_tags      = ["${digitalocean_tag.bastion.name}"]
  }, {
    protocol         = "tcp"
    port_range       = "9200"
    source_tags      = ["${digitalocean_tag.monitoring.name}", "${digitalocean_tag.prometheus.name}", "${digitalocean_tag.bastion.name}", "${digitalocean_tag.cluster_fra1_elasticsearch_logs.name}", "worker", "role_worker"]
  }, {
    protocol         = "tcp"
    port_range       = "9200-9400"
    source_tags      = ["${digitalocean_tag.cluster_fra1_elasticsearch_logs.name}"]
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
    destination_tags = ["${digitalocean_tag.cluster_fra1_elasticsearch_logs.name}"]
  }]
}

output "elasticsearch_logs" {
  value = "${zipmap(digitalocean_droplet.elasticsearch_logs.*.name, digitalocean_droplet.elasticsearch_logs.*.ipv4_address)}"
}

