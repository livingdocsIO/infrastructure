resource "random_id" "elasticsearch" {
  count = "3"
  prefix = "elasticsearch-"
  byte_length = 8
}

resource "digitalocean_tag" "elasticsearch" {name = "elasticsearch"}

data "template_file" "cloud_init_elasticsearch" {
  template = "${file("${path.module}/templates/cloud-config.yml")}"
  vars {}
}

resource "digitalocean_droplet" "elasticsearch" {
  count = "3"
  name = "${element(random_id.elasticsearch.*.hex, count.index)}"
  image = "rancheros"
  region = "fra1"
  size = "s-2vcpu-4gb"
  private_networking = true
  backups = false
  ipv6 = false
  ssh_keys = ["${digitalocean_ssh_key.bastion.fingerprint}"]
  user_data = "${data.template_file.cloud_init_elasticsearch.rendered}"
  tags = ["${digitalocean_tag.elasticsearch.id}"]
}

resource "digitalocean_firewall" "elasticsearch" {
  name = "elasticsearch"
  droplet_ids = ["${digitalocean_droplet.elasticsearch.*.id}"]

  inbound_rule = [{
    protocol         = "tcp"
    port_range       = "22"
    source_tags      = ["bastion"]
  }, {
    protocol         = "tcp"
    port_range       = "9200"
    source_tags      = ["elasticsearch", "monitoring", "prometheus", "bastion"]
  }, {
    protocol         = "tcp"
    port_range       = "9200-9400"
    source_tags      = ["elasticsearch"]
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
    destination_tags = ["elasticsearch"]
  }]
}

output "elasticsearch" {
  value = "${zipmap(digitalocean_droplet.elasticsearch.*.name, digitalocean_droplet.elasticsearch.*.ipv4_address)}"
}

