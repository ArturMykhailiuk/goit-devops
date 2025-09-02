# Універсальний RDS модуль

Terraform модуль для створення PostgreSQL бази даних в AWS з підтримкою як стандартної RDS, так і Aurora кластера.

## � Функціонал модуля

### 🔄 **Два режими роботи:**

**🔹 Aurora Cluster (`use_aurora = true`)**

- Створюється Aurora Cluster
- Створюється writer instance
- Опціонально створюються reader instances

**🔹 Стандартний RDS (`use_aurora = false`)**

- Створюється одна `aws_db_instance`

### 🏗️ **В обох випадках створюються:**

- ✅ **DB Subnet Group** - група підмереж для розміщення БД
- ✅ **Security Group** - група безпеки з налаштуваннями доступу
- ✅ **Parameter Group** - з базовими параметрами:
  - `max_connections` - максимальна кількість з'єднань
  - `log_statement` - логування SQL запитів
  - `work_mem` - робоча пам'ять для операцій

### ⚙️ **Налаштовувані параметри через змінні:**

- `engine` - рушій БД (postgres, mysql тощо)
- `engine_version` - версія рушія
- `instance_class` - клас інстанса (розмір)
- `multi_az` - розміщення в декількох зонах доступності

## 🚀 Приклади використання модуля

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
  vpc_id             = module.vpc.vpc_id
  subnet_private_ids = module.vpc.private_subnet_ids
  subnet_public_ids  = module.vpc.public_subnet_ids

  # Налаштування резервного копіювання
  backup_retention_period = 7

  # Параметри продуктивності
  parameters = {
    max_connections            = "200"
    log_statement              = "all"
    work_mem                   = "4096"
    log_min_duration_statement = "500"
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
  instance_class                = "db.r6g.large"

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
    log_statement                = "all"
    work_mem                     = "8192"
    shared_preload_libraries     = "pg_stat_statements"
    log_min_duration_statement   = "1000"
  }

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

## � Опис змінних модуля

### Основні параметри

| Змінна       | Тип      | За замовчуванням | Опис                                                      |
| ------------ | -------- | ---------------- | --------------------------------------------------------- |
| `name`       | `string` | **обов'язково**  | Ім'я інстанса або кластера БД                             |
| `use_aurora` | `bool`   | `false`          | Використовувати Aurora (true) або стандартний RDS (false) |

### Налаштування рушія БД

| Змінна                   | Тип      | За замовчуванням      | Опис                                         |
| ------------------------ | -------- | --------------------- | -------------------------------------------- |
| `engine`                 | `string` | `"postgres"`          | Рушій для стандартного RDS (postgres, mysql) |
| `engine_version`         | `string` | `"14.7"`              | Версія рушія для стандартного RDS            |
| `engine_cluster`         | `string` | `"aurora-postgresql"` | Рушій для Aurora кластера                    |
| `engine_version_cluster` | `string` | `"15.3"`              | Версія рушія для Aurora                      |

### Налаштування інстансів

| Змінна                 | Тип      | За замовчуванням | Опис                                                          |
| ---------------------- | -------- | ---------------- | ------------------------------------------------------------- |
| `instance_class`       | `string` | `"db.t3.micro"`  | Клас інстанса БД (db.t3.micro, db.t3.small, db.r6g.large)     |
| `allocated_storage`    | `number` | `20`             | Розмір сховища в ГБ (тільки для стандартного RDS)             |
| `multi_az`             | `bool`   | `false`          | Розміщення в декількох зонах доступності для відмовостійкості |
| `aurora_replica_count` | `number` | `1`              | Кількість reader репліків для Aurora кластера                 |

### Налаштування підключення

| Змінна                | Тип      | За замовчуванням | Опис                                         |
| --------------------- | -------- | ---------------- | -------------------------------------------- |
| `db_name`             | `string` | **обов'язково**  | Ім'я бази даних, яка буде створена           |
| `username`            | `string` | **обов'язково**  | Ім'я головного користувача БД                |
| `password`            | `string` | **обов'язково**  | Пароль для головного користувача (sensitive) |
| `publicly_accessible` | `bool`   | `false`          | Чи доступна БД з інтернету                   |

### Мережеві налаштування

| Змінна               | Тип            | За замовчуванням | Опис                         |
| -------------------- | -------------- | ---------------- | ---------------------------- |
| `vpc_id`             | `string`       | **обов'язково**  | ID VPC, де розміститься БД   |
| `subnet_private_ids` | `list(string)` | **обов'язково**  | Список ID приватних підмереж |
| `subnet_public_ids`  | `list(string)` | **обов'язково**  | Список ID публічних підмереж |

### Налаштування Parameter Groups

| Змінна                          | Тип           | За замовчуванням        | Опис                                                  |
| ------------------------------- | ------------- | ----------------------- | ----------------------------------------------------- |
| `parameter_group_family_rds`    | `string`      | `"postgres15"`          | Сімейство параметрів для стандартного RDS             |
| `parameter_group_family_aurora` | `string`      | `"aurora-postgresql15"` | Сімейство параметрів для Aurora                       |
| `parameters`                    | `map(string)` | `{}`                    | Кастомні параметри БД для налаштування продуктивності |

### Інші налаштування

| Змінна                    | Тип           | За замовчуванням | Опис                                         |
| ------------------------- | ------------- | ---------------- | -------------------------------------------- |
| `backup_retention_period` | `string`      | `""`             | Період зберігання автоматичних бекапів (дні) |
| `tags`                    | `map(string)` | `{}`             | Теги AWS для всіх ресурсів модуля            |

## � Як змінити налаштування БД

### Зміна типу БД (RDS ↔ Aurora)

```hcl
# Переключення на Aurora
module "rds" {
  source = "./modules/rds"
  use_aurora = true    # Створить Aurora кластер

  engine_cluster         = "aurora-postgresql"
  engine_version_cluster = "15.3"
  aurora_replica_count   = 2
  # ...
}

# Переключення на стандартний RDS
module "rds" {
  source = "./modules/rds"
  use_aurora = false   # Створить звичайний RDS instance

  engine         = "postgres"
  engine_version = "17.2"
  # ...
}
```

### Зміна рушія та версії

```hcl
# Для стандартного RDS
engine                     = "postgres"        # або "mysql"
engine_version             = "17.2"            # Нова версія PostgreSQL
parameter_group_family_rds = "postgres17"      # Відповідне сімейство

# Для Aurora
engine_cluster                = "aurora-postgresql"  # або "aurora-mysql"
engine_version_cluster        = "15.3"               # Версія Aurora PostgreSQL
parameter_group_family_aurora = "aurora-postgresql15"
```

### Зміна класу інстанса

```hcl
# Для розробки (мало ресурсів)
instance_class = "db.t3.micro"    # 1 vCPU, 1 ГБ RAM

# Для тестування
instance_class = "db.t3.small"    # 1 vCPU, 2 ГБ RAM
instance_class = "db.t3.medium"   # 2 vCPU, 4 ГБ RAM

# Для production RDS
instance_class = "db.t3.large"    # 2 vCPU, 8 ГБ RAM
instance_class = "db.m6i.xlarge"  # 4 vCPU, 16 ГБ RAM

# Для production Aurora (memory-optimized)
instance_class = "db.r6g.large"   # 2 vCPU, 16 ГБ RAM
instance_class = "db.r6g.xlarge"  # 4 vCPU, 32 ГБ RAM
```

### Популярні класи інстансів:

**Burstable Performance (T класи) - для розробки:**

- `db.t3.micro` - 1 vCPU, 1 ГБ RAM - найдешевший
- `db.t3.small` - 1 vCPU, 2 ГБ RAM
- `db.t3.medium` - 2 vCPU, 4 ГБ RAM
- `db.t3.large` - 2 vCPU, 8 ГБ RAM

**General Purpose (M класи) - збалансовані:**

- `db.m6i.large` - 2 vCPU, 8 ГБ RAM
- `db.m6i.xlarge` - 4 vCPU, 16 ГБ RAM
- `db.m6i.2xlarge` - 8 vCPU, 32 ГБ RAM

**Memory Optimized (R класи) - для Aurora та навантаженої БД:**

- `db.r6g.large` - 2 vCPU, 16 ГБ RAM
- `db.r6g.xlarge` - 4 vCPU, 32 ГБ RAM
- `db.r6g.2xlarge` - 8 vCPU, 64 ГБ RAM

### Налаштування базових параметрів

```hcl
parameters = {
  # Максимальна кількість одночасних з'єднань
  max_connections = "200"              # Стандартне значення
  max_connections = "500"              # Для великого навантаження

  # Логування SQL запитів
  log_statement = "none"               # Не логувати
  log_statement = "ddl"                # Тільки DDL (CREATE, ALTER, DROP)
  log_statement = "mod"                # DDL + DML (INSERT, UPDATE, DELETE)
  log_statement = "all"                # Всі запити

  # Робоча пам'ять для операцій (в КБ)
  work_mem = "4096"                    # 4 МБ - стандартне
  work_mem = "8192"                    # 8 МБ - для складних запитів
  work_mem = "16384"                   # 16 МБ - для аналітики

  # Логування повільних запитів (в мілісекундах)
  log_min_duration_statement = "1000"  # Логувати запити довші за 1 секунду
  log_min_duration_statement = "5000"  # Логувати запити довші за 5 секунд
}
```

### Налаштування Multi-AZ та відмовостійкості

```hcl
# Для production - обов'язково
multi_az = true                        # Розміщення в декількох зонах
backup_retention_period = 7           # Зберігати бекапи 7 днів

# Для Aurora - налаштування репліків
aurora_replica_count = 2               # 2 reader репліки
aurora_replica_count = 3               # 3 reader репліки для high availability
```

## 🏗️ Архітектура модуля

```
modules/rds/
├── variables.tf     # Всі змінні з типами та описами
├── shared.tf        # DB Subnet Group + Security Group
├── rds.tf          # Стандартний RDS instance + Parameter Group
├── aurora.tf       # Aurora Cluster + Writer + Readers + Parameter Group
└── README.md       # Детальна документація
```

### Ресурси, що створюються:

**Завжди створюються:**

- `aws_db_subnet_group` - група підмереж
- `aws_security_group` - правила доступу до БД

**При use_aurora = false:**

- `aws_db_instance` - стандартний RDS інстанс
- `aws_db_parameter_group` - параметри для RDS

**При use_aurora = true:**

- `aws_rds_cluster` - Aurora кластер
- `aws_rds_cluster_instance` (writer) - головний інстанс
- `aws_rds_cluster_instance` (readers) - репліки для читання
- `aws_rds_cluster_parameter_group` - параметри для Aurora

## 📊 Приклади параметрів продуктивності

### Базові параметри для всіх конфігурацій:

```hcl
parameters = {
  # Основні параметри з'єднань
  max_connections = "200"

  # Логування
  log_statement = "all"
  log_min_duration_statement = "1000"

  # Пам'ять
  work_mem = "4096"
}
```

### Для розробки (мінімальні ресурси):

```hcl
module "rds_dev" {
  source = "./modules/rds"

  name           = "myapp-dev"
  use_aurora     = false
  instance_class = "db.t3.micro"
  multi_az       = false

  parameters = {
    max_connections = "50"
    log_statement   = "ddl"
    work_mem        = "2048"
  }
}
```

### Для production (високі вимоги):

```hcl
module "rds_prod" {
  source = "./modules/rds"

  name                 = "myapp-prod"
  use_aurora           = true
  instance_class       = "db.r6g.large"
  aurora_replica_count = 2
  multi_az             = true

  parameters = {
    max_connections              = "500"
    log_statement                = "mod"
    work_mem                     = "8192"
    shared_preload_libraries     = "pg_stat_statements"
    log_min_duration_statement   = "5000"
  }
}
```

---

**Розроблено для GoIT DevOps курсу** 🎓
