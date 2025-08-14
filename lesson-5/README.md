# Lesson 5 - AWS Infrastructure with Terraform

Цей проект містить Terraform-конфігурацію для створення базової AWS інфраструктури, включаючи:

- S3 bucket для зберігання Terraform state з DynamoDB для блокування
- VPC з публічними та приватними підмережами
- ECR (Elastic Container Registry) для зберігання Docker-образів

## 📁 Структура проекту

```
lesson-5/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальне виведення ресурсів
├── deploy.ps1               # Автоматичний скрипт розгортання (Windows)
├── deploy.sh                # Автоматичний скрипт розгортання (Linux/Mac)
│
├── bootstrap/               # Bootstrap конфігурація (S3 + DynamoDB)
│   ├── main.tf              # Створення тільки S3 та DynamoDB
│   └── outputs.tf           # Outputs для bootstrap
│
└── modules/                 # Каталог з усіма модулями
    │
    ├── s3-backend/          # Модуль для S3 та DynamoDB
    │   ├── s3.tf            # Створення S3-бакета
    │   ├── dynamodb.tf      # Створення DynamoDB
    │   ├── variables.tf     # Змінні для S3
    │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
    │
    ├── vpc/                 # Модуль для VPC
    │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
    │   ├── routes.tf        # Налаштування маршрутизації
    │   ├── variables.tf     # Змінні для VPC
    │   └── outputs.tf       # Виведення інформації про VPC
    │
    └── ecr/                 # Модуль для ECR
        ├── ecr.tf           # Створення ECR репозиторію
        ├── variables.tf     # Змінні для ECR
        └── outputs.tf       # Виведення URL репозиторію ECR
```

## 📋 Передумови

1. Встановлений Terraform (>= 1.0)
2. AWS CLI налаштований з відповідними правами доступу
3. AWS акаунт з необхідними правами для створення:
   - S3 buckets
   - DynamoDB tables
   - VPC та пов'язані ресурси
   - ECR repositories

## ⚙️ Конфігурація

Основні параметри можна змінити в `main.tf` та `bootstrap/main.tf`:

- **S3 bucket name**: Змініть `bucket_name` на унікальну назву
- **VPC CIDR**: Змініть `vpc_cidr_block` за потреби
- **Підмережі**: Модифікуйте `public_subnets` та `private_subnets`
- **Зони доступності**: Оновіть `availability_zones` для вашого регіону
- **ECR name**: Змініть `ecr_name` на потрібну назву

## 🗂️ Компоненти інфраструктури

### 1. S3 Backend (modules/s3-backend/)

**Створювані ресурси:**

- S3 bucket для зберігання Terraform state файлів
- DynamoDB table для блокування state файлів
- Налаштування шифрування та версіювання

**Особливості:**

- Автоматичне версіювання state файлів
- Шифрування AES256
- Блокування публічного доступу
- Lifecycle policy для очищення старих версій (90 днів)
- Point-in-time recovery для DynamoDB

### 2. VPC (modules/vpc/)

**Створювані ресурси:**

- VPC з CIDR блоком 10.0.0.0/16
- 3 публічні підмережі (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
- 3 приватні підмережі (10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24)
- Internet Gateway для публічних підмереж
- NAT Gateway для кожної приватної підмережі
- Route tables для маршрутизації трафіку

**Особливості:**

- Високодоступність через розподіл по 3 зонах доступності
- Окремий NAT Gateway для кожної приватної підмережі
- DNS підтримка включена

### 3. ECR (modules/ecr/)

**Створювані ресурси:**

- ECR repository для зберігання Docker образів
- Repository policy для контролю доступу
- Lifecycle policy для автоматичного очищення образів

**Особливості:**

- Автоматичне сканування образів на вразливості
- Шифрування AES256
- Lifecycle policies:
  - Збереження останніх 30 продакшн образів (prod, release)
  - Збереження останніх 10 девелопмент образів (dev, staging)
  - Видалення нетегованих образів через 1 день

### Встановлення та використання

## 🚀 Швидкий старт

```bash
# 1. Bootstrap
cd bootstrap
terraform init
terraform plan
terraform apply
cd ..

# 2. Main infrastructure
terraform init
terraform plan
terraform apply
```

**Результат:**

- ✅ S3 bucket для Terraform state
- ✅ DynamoDB table для блокування
- ✅ VPC з публічними та приватними підмережами
- ✅ ECR repository для Docker образів

## 📊 Виведення (Outputs)

Після успішного розгортання будуть доступні наступні outputs:

### VPC:

- `vpc_id` - ID VPC
- `vpc_cidr_block` - CIDR блок VPC
- `public_subnet_ids` - ID публічних підмереж
- `private_subnet_ids` - ID приватних підмереж
- `internet_gateway_id` - ID Internet Gateway
- `nat_gateway_ids` - ID NAT Gateways

### ECR:

- `ecr_repository_url` - URL ECR repository
- `ecr_repository_arn` - ARN ECR repository
- `ecr_registry_id` - Registry ID

### Bootstrap (з папки bootstrap/):

- `s3_bucket_name` - Назва S3 bucket
- `dynamodb_table_name` - Назва DynamoDB table

## 🐳 Використання ECR

### Аутентифікація Docker з ECR:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

### Пуш образу в ECR:

```bash
# Збірка образу
docker build -t my-app .

# Тегування для ECR
docker tag my-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/lesson-5-ecr:latest

# Пуш в ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/lesson-5-ecr:latest
```

## 🗑️ Видалення інфраструктури

**Автоматично:**

```bash
# Спочатку основна інфраструктура
terraform destroy

# Потім bootstrap ресурси
cd bootstrap
terraform destroy
cd ..
```

**Важливо:** Перед видаленням переконайтеся, що:

- ECR repository порожній (видаліть всі образи)
- S3 bucket порожній (якщо потрібно зберегти state файли, зробіть backup)

### Корисні команди:

```bash
# Перевірка стану інфраструктури
terraform show

# Форматування коду
terraform fmt -recursive

# Валідація конфігурації
terraform validate

# Планування змін
terraform plan

# Перевірка створених ресурсів
aws s3 ls | grep terraform-state
aws dynamodb list-tables --region us-east-1 | grep terraform-locks
aws ecr describe-repositories --region us-east-1
aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:Name,Values=lesson-5-vpc"
```
