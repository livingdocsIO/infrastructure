resource "aws_security_group" "default" {
  name = "postgres_cluster_security_group"
  description = "RDS postgres servers (terraform-managed)"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "postgres_instance_id" {}
variable "postgres_main_username" {}
variable "postgres_main_password" {}

resource "aws_db_instance" "default" {
  identifier               = "${var.postgres_instance_id}"
  backup_retention_period  = 14 # in days
  engine                   = "postgres"
  engine_version           = "9.6.6"
  instance_class           = "db.t2.small"
  allocated_storage        = 10
  storage_type             = "gp2"
  port                     = 5432
  storage_encrypted        = true
  skip_final_snapshot      = true
  username                 = "${var.postgres_main_username}"
  password                 = "${var.postgres_main_password}"
  publicly_accessible      = true
  vpc_security_group_ids   = ["${aws_security_group.default.id}"]
}

output "postgres_instance_address" {
  value = "${aws_db_instance.default.address}"
}

output "postgres_main_username" {
  value = "${var.postgres_main_username}"
}

output "postgres_main_password" {
  value = "${var.postgres_main_password}"
}
