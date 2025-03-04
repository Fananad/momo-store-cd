#=================#
# Provider YC
#=================#
variable service_account_key_file {
  description = "path to key"
  default     = "/Users/gosharodionov/.terraform.d/key.json"
  type        = string
}
variable cloud_id {
  description = "id cloud"
  default     = "b1gljht5bbf8u60eioc6"
  type        = string
}
variable folder_id {
  description = "id folder"
  default     = "b1g6f7n2t2atqf4d036d"
  type        = string
}
variable user_id {
  description = "id servise user"
  default     = "ajeks8073uac0ojkl2h2"
  type        = string
}
#=================#
# NetWork
#=================#
variable zone {
  description = "virtual zone"
  default     = "ru-central1-a"
  type        = string
}
variable "subnet_name" {
  type = string
  default = ""
}
variable "group_name" {
  type = string
  default = ""
}
variable "labels" {
  type = map(string)
  default = {
    environment = "prod"
    owner       = "practicum"
  }
}
#=================#
# Cluster k8s
#=================#
variable "name_cluster" {
  type = string
  default = ""
}
variable "name_node" {
  type = string
  default = ""
}
variable "node_mem" {
  type = number
  default = 2
}
variable "node_cpu" {
  type = number
  default = 2
}
variable "core_fraction" {
  type = number
  default = 50
}