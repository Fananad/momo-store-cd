variable "name_cluster" {
  type = string
}
variable "user_id" {
  type = string
}
variable "zone" {
  type = string
}
variable "network_id" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "name_node" {
  type = string
  default = ""
}
variable "node_mem" {
  type = number
}
variable "node_cpu" {
  type = number
}
variable "core_fraction" {
  type = number
}
variable "group_id" {
  type = string
  default = ""
}
variable "labels" {
  type = map(string)
  default = {
    environment = ""
    owner       = ""
  }
}