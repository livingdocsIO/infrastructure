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
  tags = ["${digitalocean_tag.cluster_infrastructure.id}", "${digitalocean_tag.monitoring.id}"]

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "digitalocean_firewall" "monitoring" {
  name = "monitoring"
  droplet_ids = ["${digitalocean_droplet.monitoring.*.id}"]

  inbound_rule = [{
    protocol         = "tcp"
    port_range       = "22"
    source_tags      = ["${digitalocean_tag.bastion.name}"]
  }, { # ntp
    protocol         = "udp"
    port_range       = "123"
    source_addresses = ["0.0.0.0/0", "::/0"]
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
  }, {
    protocol              = "tcp"
    port_range            = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }, {
    protocol              = "tcp"
    port_range            = "81"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }, {
    protocol              = "tcp"
    port_range            = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  # , { # temporarily open kibana for testing
  #   protocol              = "tcp"
  #   port_range            = "5601"
  #   source_addresses = ["0.0.0.0/0", "::/0"]
  # }, { # temporarily open grafana for testing
  #   protocol              = "tcp"
  #   port_range            = "3000"
  #   source_addresses = ["0.0.0.0/0", "::/0"]
  # }, { # temporarily open elastic-hq for testing
  #   protocol              = "tcp"
  #   port_range            = "5000"
  #   source_addresses = ["0.0.0.0/0", "::/0"]
  # }
  ]

  outbound_rule = [{
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
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

output "monitoring" {
  value = "${zipmap(digitalocean_droplet.monitoring.*.name, digitalocean_droplet.monitoring.*.ipv4_address)}"
}
