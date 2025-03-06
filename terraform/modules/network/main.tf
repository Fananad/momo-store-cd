resource "yandex_vpc_network" "mynet" {
  name = var.network_name
  labels         = var.labels
}

resource "yandex_vpc_subnet" "mysubnet" {
  name           = var.subnet_name
  labels         = var.labels
  v4_cidr_blocks = ["10.1.0.0/16"]
  zone           = var.zone
  network_id     = yandex_vpc_network.mynet.id
}

