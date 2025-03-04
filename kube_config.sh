#!/bin/bash
#yc managed-kubernetes cluster list
# Скрипт для генерации kubeconfig-файла для кластера в Yandex Cloud

# Запрос идентификатора кластера
read -p "Введите идентификатор кластера (CLUSTER_ID): " CLUSTER_ID

# Определение пути для kubeconfig
KUBECONFIG_PATH="kube/kubeconfig"

# Получение сертификата кластера
CERT_PATH="kube/ca.pem"
echo "Получение сертификата кластера..."
yc managed-kubernetes cluster get --id $CLUSTER_ID --format json |
    jq -r .master.master_auth.cluster_ca_certificate |
    awk '{gsub(/\\n/,"\n")}1' > $CERT_PATH || { echo "Ошибка получения сертификата."; exit 1; }

echo "Сертификат сохранён в $CERT_PATH."

# Создание ServiceAccount
SA_YAML="kube/sa.yaml"
cat <<EOF > $SA_YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
---
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: admin-user-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: "admin-user"
EOF

echo "Применение ServiceAccount..."
kubectl apply -f $SA_YAML || { echo "Ошибка создания ServiceAccount."; exit 1; }

# Получение токена ServiceAccount
echo "Получение токена ServiceAccount..."
SA_TOKEN=$(kubectl -n kube-system get secret $(kubectl -n kube-system get secret |
    grep admin-user-token |
    awk '{print $1}') -o json |
    jq -r .data.token |
    base64 -d) || { echo "Ошибка получения токена."; exit 1; }

# Получение IP-адреса кластера
MASTER_ENDPOINT=$(yc managed-kubernetes cluster get --id $CLUSTER_ID \
    --format json | \
    jq -r .master.endpoints.external_v4_endpoint) || { echo "Ошибка получения IP-адреса кластера."; exit 1; }

echo "IP-адрес кластера: $MASTER_ENDPOINT"

# Создание файла конфигурации
kubectl config set-cluster yandex-cluster \
    --certificate-authority=$CERT_PATH \
    --embed-certs \
    --server=$MASTER_ENDPOINT \
    --kubeconfig=$KUBECONFIG_PATH || { echo "Ошибка настройки кластера в kubeconfig."; exit 1; }

kubectl config set-credentials admin-user \
    --token=$SA_TOKEN \
    --kubeconfig=$KUBECONFIG_PATH || { echo "Ошибка настройки пользователя в kubeconfig."; exit 1; }

kubectl config set-context default \
    --cluster=yandex-cluster \
    --user=admin-user \
    --kubeconfig=$KUBECONFIG_PATH || { echo "Ошибка настройки контекста в kubeconfig."; exit 1; }

kubectl config use-context default \
    --kubeconfig=$KUBECONFIG_PATH || { echo "Ошибка выбора контекста в kubeconfig."; exit 1; }

echo "Файл kubeconfig создан: $KUBECONFIG_PATH"

# Проверка подключения
kubectl get namespace --kubeconfig=$KUBECONFIG_PATH || { echo "Ошибка проверки подключения к кластеру."; exit 1; }

echo "Подключение успешно проверено. Конфигурация завершена."
