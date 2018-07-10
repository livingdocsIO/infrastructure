# Infrastructure

## Prerequesites

- A Digitalocean account and token
- An AWS Account set up with a Route53 Zone
- Set up and edit the config file: `mv example.terraform.tfvars terraform.tfvars`
- External Mysql (for grafana and rancher)

## Setup
Create a terraform workspace
```
terraform workspace new development
npm install // to set up the dependencies of the dynamic ansible inventory
```

```

```

copy the example.terraform.tfvars file to terraform.tfvars
and insert the digital ocean access key

Then create an ssh key that will be used for the hosts
```
ansible-playbook ./playbooks/create-ssh-keys.yml
```

launch all the servers and other resources
```
terraform apply ./infrastructure
```

wait a few minutes until everything is started and then start
with the setup of the nodes. This will set up elasticsearch, kibana, elasticsearch-hq, rancher and prometheus exporters
```
ansible-playbook ./playbooks/bootstrap.yml
```

If you like you can destroy everything again
```
terraform destroy ./infrastructure
```

#### TODO
- [x] protect the elasticsearch dashboards (kibana, elasticsearch-hq)
- [x] make elasticsearch private again
- [x] log agent setup (probably filebeat)
- [x] setup prometheus with the node-, cadvisor- and elasticsearch exporters
- [x] install rancher (to port current system, use kubernetes in the future)
- [ ] Move mysql into stack (currently it's set up outside of this setup)
- [ ] install backup software for prometheus (to s3 or digital ocean spaces)
- [ ] install etcd (for postgres stolon and maybe kubernetes)

##### Backup (mysql is currently managed externally)
- [ ] Grafana (mysql)
- [ ] Rancher (mysql)

## Urls
Grafana, Kibana & ES cluster dashboard:
monitoring.{{ domain }}
monitoring.{{ domain }}/kibana/
monitoring.{{ domain }}/elasticsearch-hq/

Rancher
hosted.{{ domain }}

Prometheus
prometheus.{{ domain }}

## Elasticsearch
Elasticsearch is used for logs

### Kibana
Used to query logs and for debugging

### Elasticsearch-HQ
Elasticsearch cluster status dashboard

### Worker Nodes
```
ansible -m shell -a "sudo docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.10 registrationurl" worker
```

## Bastion host

Used as ssh entry point into the private network.
The bastion host is accessible on the default ssh port 22.
The ssh key provided during the setup has access to that host.

### Teleport (might come later)

Teleport is an ssh server bastion software that supports two factor authentication and records all sessions. It  offers a web gui to connect to hosts and watch recorded sessions.

```
https://localhost:3080/v1/webapi/github/callback
```

```
docker run --name teleport -v $PWD/github.yml:/github.yml -v $PWD/teleport.yml:/teleport.yml -it -p 3022-3080:3022-3
080 -it marcbachmann/teleport:2.5.6 teleport start -c /teleport.yml

docker exec -it teleport tctl create /github.yml
```


