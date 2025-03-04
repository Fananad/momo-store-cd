# Модуль Kubernetes

Этот модуль предназначен для создания Kubernetes-кластера и групп узлов в Yandex Cloud.

## Ресурсы

- **Yandex Kubernetes Cluster**: Разворачивает мастер-узлы кластера.
- **Yandex Kubernetes Node Group**: Настраивает группы узлов.

## Переменные

- `name_cluster`: Имя Kubernetes-кластера.
- `zone`: Зона, в которой будет создан кластер.
- `network_id`: ID сети, к которой будет подключён кластер.
- `subnet_id`: ID подсети, в которой будет размещён кластер.
- `user_id`: ID сервисного аккаунта.
- `name_node`: Имя группы узлов.
- `node_mem`: Объём памяти узлов (в ГБ).
- `node_cpu`: Количество ядер CPU на узел.
- `core_fraction`: Доля вычислительных ресурсов CPU.
- `group_id`: ID группы безопасности для узлов.
- `labels`: Метки для ресурсов.

## Использование

Пример использования:

```hcl
module "cluster_k8s" {
  source       = "./modules/k8s"
  name_cluster = "k8s-cluster"
  zone         = var.zone
  network_id   = module.network.network_id
  subnet_id    = module.network.subnet_id
  user_id      = var.user_id

  name_node    = "k8s-cluster"
  node_mem     = 2
  node_cpu     = 2
  core_fraction = 50
  group_id     = module.network.group_id
  labels       = var.labels
}
```

## Выходные данные

- `k8s_cluster_id`: ID созданного Kubernetes-кластера.
- `node_group_id`: ID созданной группы узлов.
