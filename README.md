---

# Инструкция по деплою микросервисов в Kubernetes

Этот README описывает процесс деплоя микросервиса с использованием Helm и Kubernetes через GitLab CI/CD pipeline.

## Описание пайплайна

В пайплайне GitLab есть этап деплоя `deploy-k8s`, который выполняет следующие шаги:

1. **Конфигурация Kubernetes**:
    - Создается каталог для конфигурации Kubernetes.
    - Загружается и декодируется `kubeconfig` из переменной окружения.
    - Устанавливаются необходимые утилиты (`curl`, `bash`, `gnupg`, `helm`, `yq`) и скачивается последняя версия `kubectl`.

2. **Деплой с использованием Helm**:
    - Извлекается версия Helm-чарта из `Chart.yaml`.
    - Регистрируется репозиторий Helm с использованием логина и пароля для Nexus.
    - Проверяются репозитории Helm.
    - Линтинг Helm-чарта.
    - Упаковывается Helm-чарт в `.tgz` файл.
    - Загружается полученный чарт в Nexus.
    - Выполняется деплой с помощью `helm upgrade --install`, устанавливается или обновляется релиз микросервиса.
    - Удаляется конфигурация Kubernetes.

## Переменные окружения

Для правильной работы пайплайна необходимо настроить следующие переменные окружения в GitLab CI:

- **`kubeconfig`**: Секретный файл конфигурации Kubernetes (должен быть закодирован в base64).
- **`nexus_helm_url`**: URL для репозитория Helm в Nexus.
- **`nexus_login`**: Логин для аутентификации в Nexus.
- **`nexus_pass`**: Пароль для аутентификации в Nexus.

## Структура GitLab CI пайплайна

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

## Пояснение шагов

1. **before_script**:
   - Создаем директорию для Kubernetes конфигурации и сохраняем `kubeconfig`.
   - Устанавливаем все необходимые утилиты для работы с Kubernetes и Helm.
   
2. **script**:
   - Получаем текущую версию Helm-чарта с помощью `yq`.
   - Добавляем репозиторий Nexus и обновляем его.
   - Выполняем линтинг Helm-чарта с помощью `helm lint`.
   - Упаковываем чарт в `.tgz` архив.
   - Загружаем упакованный чарт в Nexus.
   - Производим деплой приложения с помощью `helm upgrade --install`.

3. **environment**:
   - Указываем, что деплой происходит в продакшн-окружении.
   - Указываем URL для доступа к сервису.

## Примечания

- Для успешного выполнения пайплайна необходимо, чтобы репозиторий Helm был доступен и настроены правильные переменные для аутентификации в Nexus.
- Убедитесь, что Kubernetes кластер настроен правильно, и у вас есть доступ к его конфигурации через переменную `kubeconfig`.

---