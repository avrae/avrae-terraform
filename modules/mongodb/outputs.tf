output "hostname" {
    value = "${aws_docdb_cluster.default.endpoint}"
}
