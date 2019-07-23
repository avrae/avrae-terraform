
# No inbound traffic
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.service}-ecs-tasks"
  description = "SG attached to ${var.service} (outbound only)"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(local.common_tags,
                  map(
                  "Name", "${var.common_name} ECS Tasks"
                  )
                )}"

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}