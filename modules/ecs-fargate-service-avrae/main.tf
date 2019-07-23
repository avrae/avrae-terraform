locals {
  common_tags = {
    Component   = "${var.service}"
    Environment = "${var.env}"
    Team        = "${var.group}"
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name = "${var.service}-${var.env}-ecs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = "${merge(local.common_tags,
            map(
            "Name", "${var.common_name} ECS Role",
            "Environment", "${var.env}"
            )
          )}"
}

resource "aws_iam_role_policy_attachment" "role_policy_attach" {
  count      = "${length(var.ecs_role_policy_arns)}"
  role       = "${aws_iam_role.ecs_service_role.name}"
  policy_arn = "${element(var.ecs_role_policy_arns, count.index)}"
}

resource "aws_ecs_task_definition" "service_task_definition" {
  family                   = "${var.service}-ecs-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  task_role_arn            = "${aws_iam_role.ecs_service_role.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_service_role.arn}"
  tags                     = "${merge(local.common_tags,
                                map(
                                "Name", "${var.common_name} Task Definition"
                                )
                              )}"

  container_definitions = <<DEFINITION
[
  {
    "image": "${var.docker_image}",
    "name": "${var.container_name}",
    "networkMode": "awsvpc",
    "portMappings": [],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options":{
          "awslogs-create-group": "True",
          "awslogs-region": "${var.region}",
          "awslogs-group": "${var.service}-ecs-logs",
          "awslogs-stream-prefix": "${var.service}-task"
        }
    },
    "environment": ${jsonencode(var.environment_variables)},
    "secrets": ${jsonencode(var.secrets)}
  }
]
DEFINITION
}

resource "aws_ecs_service" "service" {
  name                               = "${var.service_name}"
  cluster                            = "${var.cluster_id}" #"${aws_ecs_cluster.service_cluster.id}"
  task_definition                    = "${aws_ecs_task_definition.service_task_definition.arn}"
  desired_count                      = "${var.instance_count}"
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  deployment_maximum_percent         = "${var.deployment_maximum_percent}"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = ["${var.private_subnets}"]
  }
}