#output "service_name" {
#    value = "${aws_ecs_service.service.name}"
#}

output "cluster_name" {
    value = "${aws_ecs_cluster.service_cluster.name}"
}
