---
## Установка ingress controller
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && helm repo update


helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```
## Описание

Этот проект содержит Helm-чарты для деплоя микросервисов **Momo Store** на Kubernetes с использованием GitLab CI/CD. В чартах описаны два компонента:
- **backend**: бэкенд-микросервис.
- **frontend**: фронтенд-микросервис.

Вся конфигурация и деплой происходят через GitLab pipeline с использованием Helm.

## Структура проекта

```
helm-chart/
├── .gitlab-ci.yml                 # CI/CD пайплайн для GitLab
├── .helmignore                    # Игнорируемые файлы для Helm
├── Chart.yaml                     # Главный чарт для Momo Store
├── README.md                      # Этот файл
├── values.yaml                    # Общие значения для чарта
└── charts/
    ├── backend/                   # Чарт для бэкенда
    │   ├── Chart.yaml             # Информация о чарте для бэкенда
    │   ├── templates/             # Шаблоны для деплоя бэкенда
    │   │   ├── deployment.yaml   # Шаблон деплоя для бэкенда
    │   │   ├── secrets.yaml      # Шаблон секретов для бэкенда
    │   │   └── service.yaml      # Шаблон сервиса для бэкенда
    └── frontend/                  # Чарт для фронтенда
        ├── Chart.yaml             # Информация о чарте для фронтенда
        ├── templates/             # Шаблоны для деплоя фронтенда
        │   ├── deployment.yaml   # Шаблон деплоя для фронтенда
        │   ├── secrets.yaml      # Шаблон секретов для фронтенда
        │   ├── ingress.yaml      # Шаблон ингресса для фронтенда
        │   ├── service.yaml      # Шаблон сервиса для фронтенда
        │   └── configmap.yaml    # Шаблон конфигурации для фронтенда
```

## Описание Chart.yaml

### Корневой чарт (momo-store)

```yaml
apiVersion: v2
type: application
name: momo-store
description: Momo Store Helm Chart
version: 0.0.2
appVersion: "latest"

dependencies:
  - name: backend
    version: 0.1.0
    repository: "file://charts/backend"
    
  - name: frontend
    version: 0.1.0
    repository: "file://charts/frontend"
```

В корневом чарт файле описаны два зависимых чарт:
- **backend**: чарт для бэкенд-микросервиса.
- **frontend**: чарт для фронтенд-микросервиса.

Зависимости указываются с локальными репозиториями (используется путь `file://`), и они должны быть расположены в папке `charts`.

### Чарт для Backend и Frontend

Каждый из чартов (для backend и frontend) имеет свой файл `Chart.yaml`, который описывает метаданные чарта и его версию.

## Переменные конфигурации

### `values.yaml`

Конфигурации для компонентов (backend и frontend) указаны в `values.yaml`, который настраивает количество реплик, порты контейнеров, ресурсы и другие параметры.

```yaml
backend:
  backend:
    deployment:
      replicas: 3
      maxSurge: 20%
      maxUnavailable: 1
      repository: gitlab.praktikum-services.ru:5050/std-031-05/momo-store/backend
      containerPort: 8081
      limit:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "128Mi"
          cpu: "200m"
      gitLabJson: git-lab-token

frontend:
  frontend:
    deployment:
      replicas: 3
      maxSurge: 20%
      maxUnavailable: 1
      repository: gitlab.praktikum-services.ru:5050/std-031-05/momo-store/frontend
      containerPort: 80
      limit:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "128Mi"
          cpu: "200m"
      gitLabJson: git-lab-token
```

#### Параметры:

- **replicas**: Количество реплик для каждого сервиса (backend и frontend).
- **maxSurge**: Максимальная допустимая дополнительная реплика.
- **maxUnavailable**: Максимальное количество недоступных реплик.
- **repository**: URL репозитория Docker-образа.
- **containerPort**: Порт, на котором работает приложение в контейнере.
- **limit**:
  - **requests**: Минимальные ресурсы (память и CPU), которые должны быть выделены.
  - **limits**: Максимальные ресурсы (память и CPU), которые могут быть использованы.
- **gitLabJson**: Токен GitLab для аутентификации.

## Шаблоны (Templates)

Шаблоны в папках `charts/frontend/templates/` и `charts/backend/templates/` включают следующие файлы:

- **deployment.yaml**: Шаблон для деплоя приложения (backend или frontend).
- **secrets.yaml**: Шаблон для создания секретов (например, для хранения паролей или токенов).
- **service.yaml**: Шаблон для создания сервисов, чтобы контейнеры могли взаимодействовать с другими сервисами в Kubernetes.
- **ingress.yaml** (только для frontend): Шаблон для создания ингресса для маршрутизации внешних запросов.
- **configmap.yaml** (только для frontend): Шаблон для конфигурации приложений с использованием ConfigMap.

## Интеграция с GitLab CI/CD

В этом проекте используется GitLab CI/CD для автоматического деплоя Helm-чартов. Для этого настроен файл `.gitlab-ci.yml` для выполнения деплоя в Kubernetes.

### Пример пайплайна GitLab CI

```yaml
stages:
  - deploy

deploy-k8s:
  stage: deploy
  image: docker:24.0.7-alpine3.19
  before_script:
    - mkdir ~/.kube
    - echo ${kubeconfig} | base64 -d > ~/.kube/config
    - chmod 600 ~/.kube/config
    - apk add --no-cache curl bash gnupg helm yq
    - curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    - chmod +x kubectl
  script:
    - export VERSION=$(yq '.version' helm-chart/Chart.yaml)
    - echo "Install helm version ${VERSION}"
    - helm repo add momo-store ${nexus_helm_url} --username ${nexus_login} --password ${nexus_pass}
    - helm repo list
    - helm repo update
    - helm lint helm-chart
    - helm package helm-chart --destination . 
    - echo  -u ${nexus_login}:${nexus_pass} --upload-file momo-store-${VERSION}.tgz ${nexus_helm_url}
    - curl -i -u ${nexus_login}:${nexus_pass} --upload-file momo-store-${VERSION}.tgz ${nexus_helm_url}
    - helm upgrade --install momo-store momo-store-${VERSION}.tgz -n default
    - rm -f ~/.kube/config
  rules:
    - changes:
      - helm-chart/**/*

  environment:
    name: prod
    url: http://momo-store-podionov.ru
```

### Пояснение шагов:

1. **before_script**:
   - Создается конфигурация Kubernetes и загружаются необходимые инструменты для работы с Kubernetes (например, `kubectl`, `helm`).

2. **script**:
   - Извлекается версия Helm-чарта и пакуется чарт.
   - Упакованный чарт загружается в Nexus и устанавливается или обновляется с помощью Helm.

3. **environment**:
   - Указан URL окружения, где будет развернут сервис (например, для продакшн-окружения).

## Использование

1. **Скачайте и установите Helm**:

   Для установки Helm, следуйте [официальным инструкциям по установке](https://helm.sh/docs/intro/install/).

2. **Установите чарт через GitLab CI/CD**:

   После того как вы настроите GitLab CI/CD пайплайн, чарт автоматически будет развернут при каждом пуше в репозиторий.

3. **Конфигурация переменных**:

   Убедитесь, что все переменные окружения (например, `kubeconfig`, `nexus_helm_url`, `nexus_login`, `nexus_pass`) правильно настроены в GitLab CI/CD.

## Примечания

- Проверьте доступность Nexus-репозитория и правильность настроек для загрузки чарта.
- Убедитесь, что Kubernetes кластер настроен правильно и доступен через `kubeconfig`.
- Для кастомизации конфигурации используйте `values.yaml` или передавайте собственный файл конфигурации с помощью `-f` в командной строке Helm.

---