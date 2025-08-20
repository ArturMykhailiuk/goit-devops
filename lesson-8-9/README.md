# Lesson 8-9 - AWS EKS + Django Deployment

## Опис проекту

Автоматичний деплой Django додатку в AWS EKS кластер з використанням Terraform та Helm.

## Архітектура

- **EKS Cluster**: `lesson-8-9-eks` з 2 worker nodes (t3.medium)
- **Django App**: Контейнеризований Django з PostgreSQL
- **Load Balancer**: AWS ELB для зовнішнього доступу
- **Auto Scaling**: HPA від 2 до 6 подів при CPU > 70%
- **Infrastructure**: VPC, ECR, S3 backend - все через Terraform

## Швидкий старт

### 1. Деплой інфраструктури

```bash
terraform init
terraform apply -auto-approve
```

### 2. Підключення до кластера

```bash
aws eks update-kubeconfig --region us-east-1 --name lesson-8-9-eks
```

### 3. Деплой Django

```bash
helm upgrade --install django-app charts/django-app
```

## Доступ до додатку

```bash
# Отримати URL
kubectl get services django-app

# Поточний URL
http://a31c730d1c9b642f6acb6c379e9e2716-1953379977.us-east-1.elb.amazonaws.com
```

## Компоненти

- **Django**: Python web framework
- **PostgreSQL**: База даних
- **Gunicorn**: WSGI HTTP сервер
- **Kubernetes**: Оркестрація контейнерів
- **Helm**: Package manager для K8s

## Очищення

```bash
helm uninstall django-app
terraform destroy -auto-approve
```
