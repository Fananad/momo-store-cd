# 🚀 Развёртывание Kubernetes-кластера в Яндекс Облаке через Terraform

Этот проект позволяет автоматизировано разворачивать Kubernetes-кластер в Яндекс Облаке с помощью Terraform и сервисного аккаунта.

---

## 📦 Содержание

- [📋 Предварительные требования](#-предварительные-требования)
- [☁️ Настройка Яндекс Облака](#-настройка-яндекс-облака)
- [🔑 Создание сервисного аккаунта и ролей](#-создание-сервисного-аккаунта-и-ролей)
- [⚙️ Конфигурация Terraform](#️-конфигурация-terraform)
- [🚀 Развёртывание](#-развёртывание)
- [✅ Дополнительно](#-дополнительно)

---

## 📋 Предварительные требования

- Установлен [Terraform](https://developer.hashicorp.com/terraform/downloads)
- Установлен [YC CLI](https://cloud.yandex.ru/docs/cli/quickstart)
- Аккаунт в [Яндекс Облаке](https://cloud.yandex.ru)

---

## ☁️ Настройка Яндекс Облака

### 1. Авторизация и выбор каталога

```bash
yc init
yc resource-manager cloud list
yc resource-manager folder list

yc iam service-account create \
  --name terraform-k8s \
  --description "For Kubernetes cluster via Terraform"


# Управление Kubernetes
yc resource-manager folder add-access-binding \
  --id <FOLDER_ID> \
  --role k8s.editor \
  --subject serviceAccount:<SERVICE_ACCOUNT_ID>

# Управление сетью
yc resource-manager folder add-access-binding \
  --id <FOLDER_ID> \
  --role vpc.publicAdmin \
  --subject serviceAccount:<SERVICE_ACCOUNT_ID>

# Управление виртуальными машинами
yc resource-manager folder add-access-binding \
  --id <FOLDER_ID> \
  --role compute.editor \
  --subject serviceAccount:<SERVICE_ACCOUNT_ID>

# Доступ к IAM-аккаунтам
yc resource-manager folder add-access-binding \
  --id <FOLDER_ID> \
  --role iam.serviceAccounts.user \
  --subject serviceAccount:<SERVICE_ACCOUNT_ID>

# (опционально) Балансировщик
yc resource-manager folder add-access-binding \
  --id <FOLDER_ID> \
  --role load-balancer.admin \
  --subject serviceAccount:<SERVICE_ACCOUNT_ID>

```

# Главный модуль Terraform

Этот модуль служит для создания инфраструктуры Kubernetes-кластера в Yandex Cloud. Он объединяет два модуля:

- `network`: создаёт сеть, подсеть и группу безопасности.
- `k8s`: разворачивает Kubernetes-кластер и конфигурирует группы узлов.

## Структура

- `modules/`
  - `network/`: модуль для настройки сети.
  - `k8s/`: модуль для настройки Kubernetes-кластера.
- `variables.tf`: входные переменные проекта.
- `main.tf`: основной конфигурационный файл Terraform.
- `outputs.tf`: выходные переменные для удобного доступа к данным.

## Использование

1. Инициализируйте Terraform:

   ```bash
   terraform init
   ```

2. Просмотрите план изменений:

   ```bash
   terraform plan
   ```

3. Примените изменения:

   ```bash
   terraform apply
   ```

## Переменные

- **Сервисные аккаунты**: 
  - `service_account_key_file`: Путь к ключу сервисного аккаунта.
  - `user_id`: ID сервисного пользователя.
- **Сеть**:
  - `network_name`: Имя сети.
  - `zone`: Зона для создания ресурсов.
- **Кластер**:
  - `name_cluster`: Имя Kubernetes-кластера.
  - `node_mem`, `node_cpu`, `core_fraction`: Ресурсы узлов кластера.

## Выходные данные

- `network_id`: ID созданной сети.
- `subnet_id`: ID созданной подсети.
- `k8s_cluster_id`: ID созданного Kubernetes-кластера.
