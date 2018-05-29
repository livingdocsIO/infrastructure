# "logs.livingdocs.io"
# "monitoring.livingdocs.io"
# "hosted.livingdocs.io"

# "production.livingdocs.io"
# "logs.production.livingdocs.io"
# "monitoring.production.livingdocs.io"
# "rancher.production.livingdocs.io"


# resource "aws_route53_zone" "workspace" {
#   name = "${terraform.workspace}.livingdocs.io"

#   tags {
#     Environment = "development"
#   }
# }

# resource "aws_route53_record" "workspace_root" {
#   zone_id = "${aws_route53_zone.workspace.zone_id}"
#   name    = "${terraform.workspace}.livingdocs.io"
#   type    = "NS"
#   ttl     = "30"

#   records = [
#     "${aws_route53_zone.workspace.name_servers.0}",
#     "${aws_route53_zone.workspace.name_servers.1}",
#     "${aws_route53_zone.workspace.name_servers.2}",
#     "${aws_route53_zone.workspace.name_servers.3}",
#   ]
# }

# resource "aws_route53_record" "logs" {
#   zone_id = "${aws_route53_zone.workspace.zone_id}"
#   name    = "logs.${terraform.workspace}.livingdocs.io"
#   type    = "A"
#   ttl     = "30"

#   records = [
#     "${aws_route53_zone.workspace.name_servers.0}",
#     "${aws_route53_zone.workspace.name_servers.1}",
#     "${aws_route53_zone.workspace.name_servers.2}",
#     "${aws_route53_zone.workspace.name_servers.3}",
#   ]
# }

# resource "aws_route53_record" "logs" {
#   zone_id = "${aws_route53_zone.workspace.zone_id}"
#   name    = "logs.${terraform.workspace}.livingdocs.io"
#   type    = "A"
#   ttl     = "30"

#   records = [
#     "${aws_route53_zone.workspace.name_servers.0}",
#     "${aws_route53_zone.workspace.name_servers.1}",
#     "${aws_route53_zone.workspace.name_servers.2}",
#     "${aws_route53_zone.workspace.name_servers.3}",
#   ]
# }

# resource "aws_route53_health_check" "logs" {
#   fqdn              = "logs.${terraform.workspace}.livingdocs.io"
#   port              = 80
#   type              = "HTTP"
#   resource_path     = "/"
#   failure_threshold = "5"
#   request_interval  = "10"

#   tags = {
#     Name = "logs-server-${terraform.workspace}-health-check"
#   }
# }
