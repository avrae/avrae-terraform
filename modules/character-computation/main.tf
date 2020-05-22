# ==== Lambda ====

# character computation lambda function made manually

# Security Group: Lambda: Character Computation Worker
resource "aws_security_group" "character_computation_lambda" {
  name        = "${var.service}-${var.env}-character-computation-lambda-access"
  description = "Security group attached to Avrae character computation lambda"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.service}-${var.env} Character Computation Lambda Access"
    env  = var.env
  }
}

resource "aws_security_group_rule" "character_computation_lambda_egress" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.character_computation_lambda.id
}

# ==== VPC API Endpoint ====

# Security Group: API Endpoint: Character Computation Worker API
resource "aws_security_group" "character_computation_api" {
  name        = "${var.service}-${var.env}-character-computation-api-access"
  description = "Security group attached to Avrae character computation API Gateway"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.service}-${var.env} Character Computation API Gateway Access"
    env  = var.env
  }

  ingress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    security_groups   = var.whitelist_sgs
  }
}

# VPC Endpoint: execute-api endpoint
resource "aws_vpc_endpoint" "api" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.us-east-1.execute-api"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.character_computation_api.id]
  subnet_ids         = var.subnet_ids

  private_dns_enabled = true
}

# ==== API Gateway ====

resource "aws_api_gateway_rest_api" "character_computation_api" {
  name = "${var.service}-${var.env}-character-computation-api"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = [aws_vpc_endpoint.api.id]
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "execute-api:/*/*/*",
            "Condition": {
                "StringNotEquals": {
                    "aws:sourceVpc": "${var.vpc_id}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "execute-api:/*/*/*"
        }
    ]
}
EOF
}

