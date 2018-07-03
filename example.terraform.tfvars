do_token = "your digitalocean token"
ssh_key_public = "./.ssh/id_rsa.pub"

aws_access_key = "your aws access key"
aws_secret_key = "your aws secret key"

cluster_domain_zone = "example.com"
cluster_domain_namespace = "fra1.example.com" # used in ansible
cluster_domain_monitoring = "monitoring.example.com"
cluster_domain_prometheus = "prometheus.example.com"
cluster_domain_rancher = "hosted.example.com"


// production-dependencies variables
// terraform workspace select production-dependencies
// terraform apply ./production-dependencies
aws_production_region = "eu-west-1"
aws_production_access_key = "separate-aws-access-key"
aws_production_secret_key = "separate-aws-secret-key"

postgres_instance_id = "rds-instance-identifier"
postgres_main_username = "main"
postgres_main_password = "main-user-postgres-password"


# Ansible variables for rancher playbook
rancher_docker_image = "rancher/server:v1.6.18"
rancher_database_host = "example-rds-db.eu-central-1.rds.amazonaws.com"
rancher_database_port = "3306"
rancher_database_name = "rancher"
rancher_database_username = "rancher-db-username"
rancher_database_password = "rancher-db-password"

# the mysql setup is not done at the moment, we've set that up separately
mysql_password = "123fjadsfladsjflasdkfasdf"

# Ansible variables for monitoring-frontend playbook
grafana_admin_user = "admin"
grafana_admin_password = "grafana-admin-password"
grafana_db_url = "mysql://username:password@example-rds-db.eu-central-1.rds.amazonaws.com:3306/grafana"
grafana_s3_bucket = "grafana-images-example.com"
grafana_s3_bucket_region = "eu-central-1"
grafana_s3_access_key = "s3-access-key"
grafana_s3_secret_key = "s3-secret-key"

OAUTH2_PROXY_GITHUB_ORG = "exampleOrg"
OAUTH2_PROXY_GITHUB_TEAM = "exampleTeam"
OAUTH2_PROXY_PROVIDER = "github"
OAUTH2_PROXY_CLIENT_ID = "github-client-id"
OAUTH2_PROXY_CLIENT_SECRET = "github-client-secret"
OAUTH2_PROXY_EMAIL_DOMAIN = "*"
OAUTH2_PROXY_COOKIE_DOMAIN = ".example.com"

# Ansible variables for prometheus playbook
prometheus_federation_username = "example-federation-basic-auth-username"
prometheus_federation_password = "example-federation-basic-auth-password"
prometheus_federation_targets = ["upstream-prometheus-1.example.com:9090", "upstream-prometheus-2.example.com:9090"]
