# GoIT DevOps - Автоматичне встановлення інструментів розробки

Репозиторій містить Bash-скрипт для автоматичного встановлення необхідних інструментів розробки на Linux системах.

## 🚀 Скрипт install_dev_tools.sh

### 📦 Що встановлюється:

- **Docker** - платформа контейнеризації
- **Docker Compose** - управління multi-container додатками  
- **Python 3.9+** - мова програмування
- **Django** - веб-фреймворк для Python

### 🎯 Підтримувані системи:

- ✅ Ubuntu/Debian
- ✅ CentOS/RHEL/Fedora
- ✅ Arch Linux/Manjaro
- ✅ WSL 2 (Windows Subsystem for Linux)

## 📋 Інструкція з використання

### 1️⃣ Клонування репозиторію
```bash
git clone https://github.com/ArturMykhailiuk/goit-devops.git
cd goit-devops
```

### 2️⃣ Надання прав на виконання
```bash
chmod +x install_dev_tools.sh
```

### 3️⃣ Запуск скрипта
```bash
./install_dev_tools.sh
```

## 🔧 Особливості скрипта

### ✨ Розумне встановлення:
- 🔍 Перевіряє наявність інструментів перед встановленням
- 🚫 Уникає дублювання
- 🌐 Автоматично визначає дистрибутив Linux
- 📡 Перевіряє інтернет з'єднання
- 🎨 Кольоровий вивід повідомлень

### 🖥️ Спеціальна підтримка WSL 2:
- Автоматичне визначення WSL середовища
- Інтеграція з Docker Desktop
- Створення аліасів для сумісності
- Спеціальні інструкції для налаштування

## 🐳 Налаштування Docker в WSL 2

Якщо ви використовуєте WSL 2:

1. **Встановіть Docker Desktop для Windows**
2. **Налаштуйте WSL інтеграцію:**
   - Відкрийте Docker Desktop
   - Settings → Resources → WSL Integration
   - Увімкніть "Enable integration with my default WSL distro"
   - Виберіть ваш дистрибутив
   - Apply & Restart

## 🚀 Швидкий старт

### Django проект:
```bash
# Створення проекту
django-admin startproject myproject
cd myproject

# Запуск сервера
python3 manage.py runserver
```

### Python віртуальне середовище:
```bash
# Створення venv
python3 -m venv myenv

# Активація
source myenv/bin/activate

# Деактивація
deactivate
```

### Docker контейнер:
```bash
# Тестовий контейнер
docker run hello-world

# Python контейнер
docker run -it python:3.9 python
```

## 📊 Структура репозиторію

```
goit-devops/
├── install_dev_tools.sh    # Основний скрипт встановлення
├── README.md              # Документація
└── .git/                  # Git репозиторій
```

## 📝 Приклади використання

### Встановлення всіх інструментів:
```bash
./install_dev_tools.sh
```

### Після встановлення - створення Django проекту:
```bash
django-admin startproject blog
cd blog
python3 manage.py migrate
python3 manage.py runserver
```

### Робота з Docker:
```bash
# Завантажити образ Python
docker pull python:3.9

# Запустити інтерактивний Python
docker run -it python:3.9 python

# Створити простий Dockerfile
echo 'FROM python:3.9' > Dockerfile
echo 'COPY . /app' >> Dockerfile
echo 'WORKDIR /app' >> Dockerfile
echo 'CMD ["python", "app.py"]' >> Dockerfile
```
