module "network" {
  source = "./modules/network"

  network_name = "k8s-network"
  zone = var.zone
  subnet_name = "momo-store"
  group_name = "momo-store"
  labels = var.labels
}

module "cluster_k8s" {
  source = "./modules/k8s"

  name_cluster = "k8s-cluster"
  zone = var.zone
  network_id = module.network.network_id
  subnet_id = module.network.subnet_id
  user_id = var.user_id

  name_node = "k8s-cluster"
  node_mem = 2
  node_cpu = 2
  core_fraction = 50
  # group_id = module.network.group_id
  labels = var.labels
}