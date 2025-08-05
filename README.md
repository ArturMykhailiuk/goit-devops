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

3. **Перезапустіть WSL:**
   ```powershell
   # В PowerShell
   wsl --shutdown
   ```

## ✅ Перевірка встановлення

Після завершення роботи скрипта:

```bash
# Перевірка Docker
docker --version
docker run hello-world

# Перевірка Docker Compose
docker compose --version
# або
docker-compose --version

# Перевірка Python
python3 --version

# Перевірка Django
python3 -c "import django; print('Django:', django.get_version())"
```

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

## ⚠️ Вирішення проблем

### Docker без sudo:
```bash
# Додати користувача до групи docker
sudo usermod -aG docker $USER

# Перезавантажити групи
newgrp docker
```

### WSL Docker Compose помилки:
```bash
# Створити аліас
echo 'alias docker-compose="docker compose"' >> ~/.bashrc
source ~/.bashrc
```

### Помилки автентифікації Git:
- Використовуйте Personal Access Token замість пароля
- Налаштуйте SSH ключі

## 📊 Структура репозиторію

```
goit-devops/
├── install_dev_tools.sh    # Основний скрипт встановлення
├── README.md              # Документація
└── .git/                  # Git репозиторій
```

## 🤝 Внесок у проект

1. Створіть **Issue** для обговорення змін
2. Зробіть **Fork** репозиторію
3. Створіть **Pull Request** з описом змін

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

---

**🎯 Мета:** Швидке і надійне встановлення інструментів розробки  
**👨‍💻 Автор:** Artur Mykhailiuk  
**📅 Оновлено:** Серпень 2025  
**📄 Ліцензія:** MIT