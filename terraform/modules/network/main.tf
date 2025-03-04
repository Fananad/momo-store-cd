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

# resource "yandex_vpc_security_group" "k8s_public_services" {
#   name        = var.group_name
#   labels         = var.labels
#   description = "Security group for Kubernetes cluster."
#   network_id  = yandex_vpc_network.mynet.id

#   ingress {
#     protocol          = "TCP"
#     description       = "Load balancer health checks."
#     predefined_target = "loadbalancer_healthchecks"
#     from_port         = 0
#     to_port           = 65535
#   }

#   ingress {
#     protocol       = "TCP"
#     description    = "Allow kubelet logs"
#     v4_cidr_blocks = ["0.0.0.0/0"]
#     from_port      = 10250
#     to_port        = 10250
#   }

#   ingress {
#     protocol          = "ANY"
#     description       = "Master-to-node and node-to-node communication."
#     predefined_target = "self_security_group"
#     from_port         = 0
#     to_port           = 65535
#   }

#   ingress {
#     protocol          = "ICMP"
#     description       = "Allow ICMP traffic for debugging."
#     v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
#   }

#   ingress {
#     protocol          = "TCP"
#     description       = "Allow NodePort traffic from the internet."
#     v4_cidr_blocks    = ["0.0.0.0/0"]
#     from_port         = 30000
#     to_port           = 32767
#   }
#   ingress {
#     protocol          = "TCP"
#     description       = "Allow SSH access."
#     v4_cidr_blocks    = ["0.0.0.0/0"]
#     from_port         = 22
#     to_port           = 22
#   }
#   ingress {
#   protocol          = "TCP"
#   description       = "Allow HTTP traffic to Ingress"
#   v4_cidr_blocks    = ["0.0.0.0/0"]
#   from_port         = 80
#   to_port           = 80
#   }

#   ingress {
#     protocol          = "TCP"
#     description       = "Allow HTTPS traffic to Ingress"
#     v4_cidr_blocks    = ["0.0.0.0/0"]
#     from_port         = 443
#     to_port           = 443
#   }

#   egress {
#     protocol          = "ANY"
#     description       = "Allow all outbound traffic."
#     v4_cidr_blocks    = ["0.0.0.0/0"]
#     from_port         = 0
#     to_port           = 65535
#   }
#   egress {
#     protocol          = "TCP"
#     description       = "Exit 80"
#     v4_cidr_blocks    = ["0.0.0.0/0"]
#     from_port         = 0
#     to_port           = 80
#   }
#   egress {
#     protocol          = "TCP"
#     description       = "Exit ssl"
#     v4_cidr_blocks    = ["0.0.0.0/0"]
#     from_port         = 0
#     to_port           = 443
#   }
# }
