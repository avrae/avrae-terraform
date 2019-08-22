resource "aws_appautoscaling_target" "ecs_autoscaling_target" {
  max_capacity       = var.max_instance_count
  min_capacity       = var.instance_count
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  role_arn           = "arn:aws:iam::${var.account_id}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.service]
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "${var.service}-${var.env}-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value       = var.scale_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = var.scale_metric
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_autoscaling_target]
}

