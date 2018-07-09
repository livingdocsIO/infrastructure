resource "random_id" "worker" {
  count = "3"
  prefix = "worker-"
  byte_length = 8
}

resource "random_id" "worker_development" {
  count = "3"
  prefix = "worker-"
  byte_length = 8
}

resource "digitalocean_tag" "role_worker" {name = "role_worker"}

resource "digitalocean_tag" "worker" {name = "worker"}
resource "digitalocean_tag" "worker_development" {name = "worker_development"}

resource "digitalocean_tag" "cluster_production" {name = "cluster_production"}
resource "digitalocean_tag" "cluster_development" {name = "cluster_development"}

# resource "digitalocean_tag" "worker_production" {name = "worker_production"}
# resource "digitalocean_tag" "worker_ci" {name = "worker_cluster_ci"}

data "template_file" "cloud_init_worker" {
  template = "${file("${path.module}/templates/cloud-config.yml")}"
  vars {}
}

resource "digitalocean_droplet" "worker_production" {
  count = "3"
  name = "${random_id.worker.*.hex[count.index]}"
  image = "rancheros"
  region = "fra1"
  size = "s-4vcpu-8gb"
  private_networking = true
  backups = false
  ipv6 = false
  ssh_keys = ["${digitalocean_ssh_key.bastion.fingerprint}"]
  user_data = "${data.template_file.cloud_init_worker.rendered}"
  tags = ["${digitalocean_tag.cluster_production.id}", "${digitalocean_tag.role_worker.id}", "${digitalocean_tag.worker.id}"]

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "digitalocean_droplet" "worker_development" {
  count = "3"
  name = "${random_id.worker_development.*.hex[count.index]}"
  image = "rancheros"
  region = "fra1"
  size = "s-4vcpu-8gb"
  private_networking = true
  backups = false
  ipv6 = false
  ssh_keys = ["${digitalocean_ssh_key.bastion.fingerprint}"]
  user_data = "${data.template_file.cloud_init_worker.rendered}"
  tags = ["${digitalocean_tag.cluster_development.id}", "${digitalocean_tag.role_worker.id}", "${digitalocean_tag.worker_development.id}"]

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "digitalocean_firewall" "worker_production" {
  name = "worker-production"
  droplet_ids = ["${digitalocean_droplet.worker_production.*.id}", "${digitalocean_droplet.worker_development.*.id}"]

  inbound_rule = [{
    protocol         = "tcp"
    port_range       = "22"
    source_tags      = ["${digitalocean_tag.bastion.name}"]
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
    # Expose prometheus for federation
    # Prometheus and a load balancer will be set up within rancher/kubernetes
    protocol              = "tcp"
    port_range            = "9090"
    source_addresses      = ["0.0.0.0/0", "::/0"]
  }, { # Ports needed for the rancher ipsec network
    protocol              = "udp"
    port_range            = "4500"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }, {
    protocol              = "udp"
    port_range            = "500"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }, { # http
    protocol              = "tcp"
    port_range            = "443"
    source_addresses      = ["0.0.0.0/0", "::/0"]
  }, { # https
    protocol              = "tcp"
    port_range            = "80"
    source_addresses      = ["0.0.0.0/0", "::/0"]
  }, { # traefik admin port
    protocol              = "tcp"
    port_range            = "8000"
    source_addresses      = ["0.0.0.0/0", "::/0"]
  }]

  outbound_rule = [{
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

output "worker_production" {
  value = "${zipmap(digitalocean_droplet.worker_production.*.name, digitalocean_droplet.worker_production.*.ipv4_address)}"
}

output "worker_development" {
  value = "${zipmap(digitalocean_droplet.worker_development.*.name, digitalocean_droplet.worker_development.*.ipv4_address)}"
}
