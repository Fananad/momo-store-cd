output "network_id" {
  value = yandex_vpc_network.mynet.id
}
output "subnet_id" {
  value = yandex_vpc_subnet.mysubnet.id
}
# output "group_id" {
#   value = yandex_vpc_security_group.k8s_public_services.id
# }