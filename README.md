# AWS Infrastructure with Terraform

## Опис

Цей проект автоматизує розгортання інфраструктури в AWS за допомогою Terraform. Основні компоненти:

- **VPC** — ізольована мережа для сервісів
- **EKS** — Kubernetes кластер для запуску контейнеризованих додатків
- **RDS** — керована база даних
- **ECR** — реєстр Docker-образів
- **Jenkins** — CI/CD сервер
- **Argo CD** — GitOps для Kubernetes
- **Prometheus** — моніторинг (Helm chart Argo CD)
- **Grafana** — візуалізація метрик (Helm chart Argo CD)
- **Django-app** - application (Helm chart Argo CD)

## Структура проекту

- `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars` — основні файли Terraform
- `modules/` — модулі для кожного компонента (VPC, EKS, RDS, ECR, Jenkins, Argo CD)
- `charts/` — Helm charts для деплою додатків
- `configs/` — додаткові конфігурації (додано можливість зазначати модулі, які будуть встановлюватись)
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
  або
  terraform apply -var-file="configs\modules.tfvars"
  для встановлення лише зазначених в configs\modules.tfvar модулів
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
<img width="1907" height="597" alt="image" src="https://github.com/user-attachments/assets/199fb6d1-5e6d-41de-911d-115a81f7a9a9" />

  
- **Argo CD:**
  ```sh
  kubectl port-forward svc/argocd-server 8081:443 -n argocd
  ```
<img width="1908" height="842" alt="image" src="https://github.com/user-attachments/assets/23ff58f5-193d-4496-89d5-80e05999a665" />


### 4. Моніторинг та перевірка метрик

- **Grafana:**
  ```sh
  kubectl port-forward svc/grafana 3000:80 -n monitoring 
  ```
<img width="1917" height="950" alt="image" src="https://github.com/user-attachments/assets/b71ecd62-c195-4da4-9dcd-2add9ef89c7d" />

---

> **Увага!** Перед запуском переконайтесь, що у вас налаштовані AWS credentials та всі необхідні змінні у `terraform.tfvars`.
