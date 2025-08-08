# GoIT DevOps - Django проєкт з Docker

Повний Django проєкт з PostgreSQL та Nginx, запакований в Docker контейнери.

## 🚀 Швидкий старт

### 1️⃣ Встановлення інструментів

```bash
# Зробити скрипт виконуваним
chmod +x install_dev_tools.sh
chmod +x init_project.sh

# Встановити Docker, Docker Compose, Python, Django
./install_dev_tools.sh
```

### 2️⃣ Ініціалізація проєкту

```bash
# Автоматична ініціалізація Django проєкту
./init_project.sh
```

### 3️⃣ Доступ до додатку

- **Головна сторінка:** http://localhost:8000 (прямо Django)
- **Головна сторінка:** http://localhost:8081 (через Nginx)
- **Адмін панель:** http://localhost:8000/admin або http://localhost:8081/admin
- **Логін:** admin / **Пароль:** 123Django123

## 🏗️ Архітектура проєкту

```
myproject/
├── web/          # Django додаток (Python 3.9)
├── db/           # PostgreSQL 15
├── nginx/        # Nginx проксі сервер
└── volumes/      # Постійне збереження даних
```

## 📦 Структура файлів

```
goit-devops/
├── myproject/              # Django проєкт
│   ├── __init__.py
│   ├── settings.py         # Налаштування Django
│   ├── urls.py            # URL маршрути
│   ├── wsgi.py            # WSGI конфігурація
│   └── asgi.py            # ASGI конфігурація
├── nginx/
│   └── nginx.conf         # Конфігурація Nginx
├── static/                # Статичні файли
├── media/                 # Медіа файли
├── templates/             # HTML шаблони
├── Dockerfile             # Образ Django
├── docker-compose.yml     # Оркестрація контейнерів
├── requirements.txt       # Python залежності
├── manage.py             # Django CLI
├── .env                  # Змінні середовища
├── install_dev_tools.sh  # Встановлення інструментів
├── init_project.sh       # Ініціалізація проєкту
└── README.md             # Документація
```

## 🛠️ Ручне управління

### Запуск проєкту:

```bash
# Збірка образів
docker-compose build

# Запуск у фоновому режимі
docker-compose up -d

# Перегляд статусу
docker-compose ps
```

### Робота з базою даних:

```bash
# Виконання міграцій
docker-compose run --rm web python manage.py migrate

# Створення суперкористувача
docker-compose run --rm web python manage.py createsuperuser

# Збір статичних файлів
docker-compose run --rm web python manage.py collectstatic
```

### Налагодження:

```bash
# Перегляд логів всіх сервісів
docker-compose logs -f

# Логи конкретного сервісу
docker-compose logs -f web
docker-compose logs -f db
docker-compose logs -f nginx

# Підключення до контейнера
docker-compose exec web bash
docker-compose exec db psql -U postgres -d myproject_db
```

### Зупинка та очищення:

```bash
# Зупинка сервісів
docker-compose down

# Зупинка з видаленням volumes
docker-compose down -v

# Видалення образів
docker-compose down --rmi all
```

## 🔧 Конфігурація

### Docker Compose сервіси:

**📱 Web (Django):**

- Порт: 8000
- Образ: Python 3.9
- WSGI: Gunicorn

**🗄️ Database (PostgreSQL):**

- Порт: 5432
- Версія: PostgreSQL 15
- База: myproject_db

**🌐 Nginx:**

- Порт: 8081 (замість 80 для уникнення конфліктів)
- Проксування на Django
- Статичні файли

## 🔍 Перевірка роботи

### 1. Статус контейнерів:

```bash
docker-compose ps
```

### 2. Доступність сайту:

```bash
curl http://localhost:8000
curl http://localhost:8081
```

### 3. Підключення до бази:

```bash
docker-compose exec db psql -U postgres -d myproject_db -c "\dt"
```

### 4. Журнали помилок:

```bash
docker-compose logs --tail=50 web
```

**🎯 Мета:** Повнофункціональний Django проєкт в Docker  
**👨‍💻 Автор:** Artur Mykhailiuk  
**📅 Створено:** Серпень 2025
