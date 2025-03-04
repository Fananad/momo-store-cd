resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name        = var.name_cluster
  network_id  = var.network_id
  labels      = var.labels
 master {
    public_ip = true
   master_location {
     zone      = var.zone
     subnet_id = var.subnet_id
   }
 }
 service_account_id      = var.user_id
 node_service_account_id = var.user_id
 
   depends_on = [
     
   ]
}

resource "yandex_kubernetes_node_group" "k8s_node_group" {
  name        = var.name_node
  cluster_id  = yandex_kubernetes_cluster.k8s_cluster.id
  labels      = var.labels
  scale_policy {
    fixed_scale {
      size = 1
    }
  }
  instance_template {
    name        = "node-{instance.short_id}-{instance_group.id}"
    platform_id = "standard-v3"
    resources {
      memory        = var.node_mem 
      cores         = var.node_cpu
      core_fraction = var.core_fraction
    }
    boot_disk {
      type = "network-hdd"
      size = 64  
    }
    network_interface {
      subnet_ids             = [var.subnet_id]
      # security_group_ids     = [var.group_id]
      nat                    = true
    }
    scheduling_policy {
      preemptible = false
    }
    metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
    }
    network_acceleration_type = "standard"
    labels = {
      "node-label1" = "node-value1"
    }
}
}

