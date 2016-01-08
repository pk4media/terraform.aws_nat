output "user" {
  value = "${var.user}"
}

output "instance_ids" {
  value = "${join(",", aws_instance.nat.*.id)}"
}

output "public_ips" {
  value = "${join(",", aws_instance.nat.*.public_id)}"
}

output "private_ips" {
  value = "${join(",", aws_instance.nat.*.private_ip)}"
}

output "route_table_ids" {
  value = "${join(",", aws_route_table.nat.*.id)}"
}
