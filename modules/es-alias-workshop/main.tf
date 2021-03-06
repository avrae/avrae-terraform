# ==== ElasticSearch: Avrae Alias Workshop ====

# ---- security groups ----
resource "aws_security_group" "es" {
  name = "${var.service}-${var.env}-workshop-elasticsearch-access"
  description = "Managed by Terraform"
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = var.es_whitelist_sgs
  }
}

# ---- elasticsearch domain ----
resource "aws_elasticsearch_domain" "workshop_es" {
  domain_name = "${var.service}-${var.env}-workshop"

  elasticsearch_version = "7.7"

  cluster_config {
    instance_type = "r5.large.elasticsearch"
    instance_count = 2
    zone_awareness_enabled = true
  }

  vpc_options {
    subnet_ids = var.subnet_ids
    security_group_ids = [aws_security_group.es.id]
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:*:*:domain/${var.service}-${var.env}-workshop/*"
        }
    ]
}
CONFIG

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  tags = {
    Component = var.service
    Environment = var.env
  }
}

