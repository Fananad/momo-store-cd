# Модуль Network

Модуль предназначен для создания сети, подсети и группы безопасности в Yandex Cloud. 

## Ресурсы

- **Yandex VPC Network**: Создаёт виртуальную сеть.
- **Yandex VPC Subnet**: Создаёт подсеть.
- **Yandex VPC Security Group**: Настраивает группу безопасности.

## Переменные

- `network_name`: Имя создаваемой сети.
- `subnet_name`: Имя подсети.
- `group_name`: Имя группы безопасности.
- `zone`: Зона, в которой будет создана подсеть.
- `labels`: Метки для ресурсов.

## Использование

Пример использования:

```hcl
module "network" {
  source      = "./modules/network"
  network_name = "k8s-network"
  zone        = var.zone
  subnet_name = "momo-store"
  group_name  = "momo-store"
  labels      = var.labels
}
```

## Выходные данные

- `network_id`: ID созданной сети.
- `subnet_id`: ID созданной подсети.
- `group_id`: ID созданной группы безопасности.
