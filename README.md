# Infrastructure

Create a terraform workspace
```
terraform workspace new development
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
with the setup of the nodes. This will configure the jump hosts.
```
ansible-playbook ./playbooks/node.yml
```

Install elasticsearch, kibana, elasticsearch-hq and prometheus exporters
currently they aren't protected..
an authentication server that uses github will come soon
```
ansible-playbook ./playbooks/elasticsearch.yml
```

If you like you can destroy everything again
```
terraform destroy ./infrastructure
```

#### TODO
- [] protect the elasticsearch dashboards (kibana, elasticsearch-hq)
- [] make elasticsearch private again
- [] log agent setup (probably filebeat)
- [] setup prometheus with the node-, cadvisor- and elasticsearch exporters
- [] install backup software for prometheus (to s3 or digital ocean spaces)
- [] install etcd (for postgres stolon and maybe kubernetes)
- [] install rancher (to port current system, use kubernetes in the future)

##### Backup
- [] Grafana
- []

## Urls
logs.{{ cluster }}.{{ domain }} // kibana
logs.{{ cluster }}.{{ domain }}:9200 // elasticsearch
logs.{{ cluster }}.{{ domain }}:5000 // elasticsearch-hq

monitoring.{{ cluster }}.{{ domain }} // grafana
monitoring.{{ cluster }}.{{ domain }}:9090 // prometheus

## Elasticsearch
Elasticsearch is used for logs

### Kibana
Used to display logs

### Elasticsearch-HQ
Cluster status dashboard


## Bastion host

Used as ssh entry point into the private network.
The bastion host is accessible on the default ssh port 22.

### Teleport

Teleport is an ssh server that supports two factor authentication and records all sessions. It also offers a web gui to connect to hosts and watch recorded sessions.

```
https://localhost:3080/v1/webapi/github/callback
```

```
docker run --name teleport -v $PWD/github.yml:/github.yml -v $PWD/teleport.yml:/teleport.yml -it -p 3022-3080:3022-3
080 -it marcbachmann/teleport:2.5.6 teleport start -c /teleport.yml

docker exec -it teleport tctl create /github.yml
```




