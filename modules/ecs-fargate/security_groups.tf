# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.service}-ecs-tasks"
  description = "allow inbound access from the LB only for ${var.service}"
  vpc_id      = var.vpc_id
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.common_name} ECS Tasks"
    },
  )

  ingress {
    protocol        = "tcp"
    from_port       = var.service_port
    to_port         = var.service_port
    security_groups = [var.lb_sg_id] #["${aws_security_group.lb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

