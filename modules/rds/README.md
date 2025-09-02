# Універсальний RDS модуль

Універсальний Terraform модуль для створення PostgreSQL бази даних в AWS з підтримкою як стандартної RDS, так і Aurora кластера.

## Функціональність

### 🔄 Два режими роботи:

- **`use_aurora = true`** → створюється Aurora Cluster + writer + reader instances
- **`use_aurora = false`** → створюється стандартний RDS instance

### 🏗️ Загальні компоненти (створюються в обох випадках):

- **DB Subnet Group** - група підмереж для розміщення БД
- **Security Group** - група безпеки з налаштованим доступом
- **Parameter Group** - параметри БД з базовими налаштуваннями продуктивності

### ⚙️ Налаштовувані параметри:

- `engine`, `engine_version` - рушій та версія БД
- `instance_class` - клас інстанса (розмір)
- `multi_az` - розміщення в декількох зонах доступності
- Кастомні параметри БД через змінну `parameters`

## Приклади використання

### Стандартний RDS instance

```hcl
module "rds" {
  source = "./modules/rds"

  # Основні налаштування
  name       = "myapp-db"
  use_aurora = false

  # Налаштування рушія
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"
  instance_class             = "db.t3.medium"

  # Налаштування зберігання
  allocated_storage = 50
  multi_az         = true

  # Налаштування доступу
  db_name              = "myapp"
  username             = "postgres"
  password             = "secure_password_123"
  publicly_accessible  = false

  # Мережеві налаштування
  vpc_id                = module.vpc.vpc_id
  subnet_private_ids    = module.vpc.private_subnet_ids
  subnet_public_ids     = module.vpc.public_subnet_ids

  # Налаштування резервного копіювання
  backup_retention_period = 7

  # Параметри продуктивності
  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
    work_mem                   = "4096"
  }

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

### Aurora Cluster

```hcl
module "rds_aurora" {
  source = "./modules/rds"

  # Основні налаштування
  name       = "myapp-aurora"
  use_aurora = true

  # Aurora налаштування
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  aurora_replica_count          = 2
  instance_class               = "db.r6g.large"

  # Налаштування доступу
  db_name              = "myapp"
  username             = "postgres"
  password             = "secure_password_123"
  publicly_accessible  = false

  # Мережеві налаштування
  vpc_id             = module.vpc.vpc_id
  subnet_private_ids = module.vpc.private_subnet_ids
  subnet_public_ids  = module.vpc.public_subnet_ids

  # Налаштування резервного копіювання
  backup_retention_period = 14

  # Параметри продуктивності
  parameters = {
    max_connections              = "500"
    shared_preload_libraries     = "pg_stat_statements"
    log_min_duration_statement   = "1000"
  }

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

## Змінні модуля

### Основні параметри

| Змінна       | Тип      | За замовчуванням | Опис                                                      |
| ------------ | -------- | ---------------- | --------------------------------------------------------- |
| `name`       | `string` | **обов'язково**  | Ім'я інстанса або кластера                                |
| `use_aurora` | `bool`   | `false`          | Використовувати Aurora (true) або стандартний RDS (false) |

### Налаштування рушія БД

| Змінна                   | Тип      | За замовчуванням      | Опис                              |
| ------------------------ | -------- | --------------------- | --------------------------------- |
| `engine`                 | `string` | `"postgres"`          | Рушій для стандартного RDS        |
| `engine_version`         | `string` | `"14.7"`              | Версія рушія для стандартного RDS |
| `engine_cluster`         | `string` | `"aurora-postgresql"` | Рушій для Aurora кластера         |
| `engine_version_cluster` | `string` | `"15.3"`              | Версія рушія для Aurora           |

### Налаштування інстансів

| Змінна                 | Тип      | За замовчуванням | Опис                                     |
| ---------------------- | -------- | ---------------- | ---------------------------------------- |
| `instance_class`       | `string` | `"db.t3.micro"`  | Клас інстанса БД                         |
| `allocated_storage`    | `number` | `20`             | Розмір сховища в ГБ (тільки для RDS)     |
| `multi_az`             | `bool`   | `false`          | Розміщення в декількох зонах доступності |
| `aurora_replica_count` | `number` | `1`              | Кількість reader репліків для Aurora     |

### Налаштування підключення

| Змінна                | Тип      | За замовчуванням | Опис                             |
| --------------------- | -------- | ---------------- | -------------------------------- |
| `db_name`             | `string` | **обов'язково**  | Ім'я бази даних                  |
| `username`            | `string` | **обов'язково**  | Ім'я користувача БД              |
| `password`            | `string` | **обов'язково**  | Пароль (позначений як sensitive) |
| `publicly_accessible` | `bool`   | `false`          | Публічний доступ до БД           |

### Мережеві налаштування

| Змінна               | Тип            | За замовчуванням | Опис                         |
| -------------------- | -------------- | ---------------- | ---------------------------- |
| `vpc_id`             | `string`       | **обов'язково**  | ID VPC                       |
| `subnet_private_ids` | `list(string)` | **обов'язково**  | Список ID приватних підмереж |
| `subnet_public_ids`  | `list(string)` | **обов'язково**  | Список ID публічних підмереж |

### Налаштування Parameter Groups

| Змінна                          | Тип           | За замовчуванням        | Опис                            |
| ------------------------------- | ------------- | ----------------------- | ------------------------------- |
| `parameter_group_family_rds`    | `string`      | `"postgres15"`          | Сімейство параметрів для RDS    |
| `parameter_group_family_aurora` | `string`      | `"aurora-postgresql15"` | Сімейство параметрів для Aurora |
| `parameters`                    | `map(string)` | `{}`                    | Кастомні параметри БД           |

### Інші налаштування

| Змінна                    | Тип           | За замовчуванням | Опис                            |
| ------------------------- | ------------- | ---------------- | ------------------------------- |
| `backup_retention_period` | `string`      | `""`             | Період зберігання бекапів (дні) |
| `tags`                    | `map(string)` | `{}`             | Теги для ресурсів               |

## Як змінити налаштування

### Зміна типу БД (RDS ↔ Aurora)

```hcl
# Переключення на Aurora
use_aurora = true

# Переключення на стандартний RDS
use_aurora = false
```

### Зміна рушія та версії

```hcl
# Для стандартного RDS
engine                     = "postgres"
engine_version             = "17.2"        # Нова версія
parameter_group_family_rds = "postgres17"  # Відповідне сімейство

# Для Aurora
engine_cluster                = "aurora-postgresql"
engine_version_cluster        = "15.3"        # Версія Aurora
parameter_group_family_aurora = "aurora-postgresql15"
```

### Зміна класу інстанса

```hcl
# Для розробки
instance_class = "db.t3.micro"

# Для production RDS
instance_class = "db.t3.large"

# Для production Aurora
instance_class = "db.r6g.large"
```

### Популярні класи інстансів:

**Burstable (T клас):**

- `db.t3.micro` - 1 vCPU, 1 ГБ RAM (для розробки)
- `db.t3.small` - 1 vCPU, 2 ГБ RAM
- `db.t3.medium` - 2 vCPU, 4 ГБ RAM
- `db.t3.large` - 2 vCPU, 8 ГБ RAM

**General Purpose (M клас):**

- `db.m6i.large` - 2 vCPU, 8 ГБ RAM
- `db.m6i.xlarge` - 4 vCPU, 16 ГБ RAM
- `db.m6i.2xlarge` - 8 vCPU, 32 ГБ RAM

**Memory Optimized (R клас, для Aurora):**

- `db.r6g.large` - 2 vCPU, 16 ГБ RAM
- `db.r6g.xlarge` - 4 vCPU, 32 ГБ RAM
- `db.r6g.2xlarge` - 8 vCPU, 64 ГБ RAM

### Налаштування продуктивності

```hcl
parameters = {
  # З'єднання
  max_connections = "500"

  # Пам'ять
  work_mem                = "8192"      # 8MB за операцію
  shared_buffers          = "256MB"     # Буфер кешу
  effective_cache_size    = "1GB"       # Доступна пам'ять для кешу

  # Логування
  log_min_duration_statement = "1000"   # Логувати запити > 1сек
  log_statement              = "all"    # Логувати всі SQL

  # Розширення
  shared_preload_libraries = "pg_stat_statements"
}
```

## Outputs модуля

Модуль повертає різні вихідні дані залежно від режиму:

### Загальні outputs:

- `db_subnet_group_name` - ім'я DB subnet group
- `security_group_id` - ID security group

### Для стандартного RDS:

- `rds_endpoint` - endpoint для підключення
- `rds_port` - порт БД
- `rds_instance_id` - ID інстанса

### Для Aurora:

- `aurora_cluster_endpoint` - writer endpoint
- `aurora_reader_endpoint` - reader endpoint
- `aurora_cluster_id` - ID кластера

## Особливості

### 🔒 Безпека:

- Пароль позначений як `sensitive`
- Security Group налаштований тільки для PostgreSQL (порт 5432)
- За замовчуванням БД не доступна публічно

### 🔄 Pre-destroy хуки:

- Автоматичне видалення snapshot'ів при знищенні Aurora кластера
- Запобігання конфліктам при повторному створенні

### 📊 Моніторинг:

- Можливість увімкнення розширеного логування
- Підтримка `pg_stat_statements` для аналізу запитів

### 💾 Резервне копіювання:

- Налаштований період зберігання бекапів
- Автоматичні snapshot'и для Aurora
