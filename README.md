# AWS Infrastructure with Terraform

## Опис

Цей проект автоматизує розгортання інфраструктури в AWS за допомогою Terraform. Основні компоненти:

- **VPC** — ізольована мережа для сервісів
- **EKS** — Kubernetes кластер для запуску контейнеризованих додатків
- **RDS** — керована база даних
- **ECR** — реєстр Docker-образів
- **Jenkins** — CI/CD сервер
- **Argo CD** — GitOps для Kubernetes
- **Prometheus** — моніторинг
- **Grafana** — візуалізація метрик

## Структура проекту

- `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars` — основні файли Terraform
- `modules/` — модулі для кожного компонента (VPC, EKS, RDS, ECR, Jenkins, Argo CD, Prometheus, Grafana)
- `charts/` — Helm charts для деплою додатків
- `configs/` — додаткові конфігурації
- `complete-cleanup-aws.ps1` — скрипт для очищення ресурсів
- `Jenkinsfile` — pipeline для CI/CD

## Етапи виконання

### 1. Підготовка середовища

- Ініціалізувати Terraform:
  ```sh
  terraform init
  ```
- Перевірити всі необхідні змінні та параметри у `terraform.tfvars`.

### 2. Розгортання інфраструктури

- Виконати команду розгортання:
  ```sh
  terraform apply
  ```
- Перевірити стан ресурсів:
  ```sh
  kubectl get all -n jenkins
  kubectl get all -n argocd
  kubectl get all -n monitoring
  ```

### 3. Перевірка доступності

- **Jenkins:**
  ```sh
  kubectl port-forward svc/jenkins 8080:8080 -n jenkins
  ```
- **Argo CD:**
  ```sh
  kubectl port-forward svc/argocd-server 8081:443 -n argocd
  ```

### 4. Моніторинг та перевірка метрик

- **Grafana:**
  ```sh
  kubectl port-forward svc/grafana 3000:80 -n monitoring
  ```

## Необхідні інструменти

- [Terraform](https://www.terraform.io/)
- [AWS CLI](https://aws.amazon.com/cli/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/)
- [Jenkins](https://www.jenkins.io/)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)

## Автор

- [Ваше ім'я]

---

> **Увага!** Перед запуском переконайтесь, що у вас налаштовані AWS credentials та всі необхідні змінні у `terraform.tfvars`.
