# CRMLite Docker Deployment

Документация по развёртыванию CRMLite с использованием Docker и Docker Compose.

## Структура проекта

```
FinalProjectGitHubDocker/
├── Dockerfile                 # Образ Django приложения
├── docker-compose.yml        # Оркестрация сервисов
├── nginx.conf                # Конфигурация Nginx
├── entrypoint.sh              # Скрипт запуска
├── .dockerignore              # Исключения для Docker
├── .env.example               # Пример переменных окружения
└── KursFinalProject/          # Django проект
    └── crmlite/
        └── settings.py        # Обновлённые настройки
```

## Быстрый старт

### 1. Подготовка

Скопируйте файл переменных окружения:

```bash
cp .env.example .env
```

Отредактируйте `.env` файл, указав реальные значения:

```bash
SECRET_KEY=ваш-уникальный-секретный-ключ
DEBUG=False
ALLOWED_HOSTS=your-domain.com
POSTGRES_PASSWORD=сложный-пароль-для-postgres
```

### 2. Сборка и запуск

```bash
docker-compose build
docker-compose up -d
```

### 3. Проверка статуса

```bash
docker-compose ps
docker-compose logs web
```

### 4. Создание суперпользователя

```bash
docker-compose exec web python manage.py createsuperuser
```

## Сервисы

| Сервис | Порт | Описание |
|--------|------|----------|
| nginx | 80, 443 | Reverse proxy, раздача статики |
| web | 8000 | Django приложение (Gunicorn) |
| db | 5432 | PostgreSQL 15 |

## Полезные команды

### Миграции

```bash
docker-compose exec web python manage.py migrate
```

### Сбор статики

```bash
docker-compose exec web python manage.py collectstatic
```

### Shell

```bash
docker-compose exec web python manage.py shell
```

### Просмотр логов

```bash
docker-compose logs -f web
docker-compose logs -f nginx
docker-compose logs -f db
```

### Пересборка

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Остановка

```bash
docker-compose down
```

### Остановка с удалением данных

```bash
docker-compose down -v
```

## API Endpoints

После запуска приложение будет доступно по адресу:

- **API**: http://localhost/api/
- **Swagger UI**: http://localhost/api/swagger/
- **ReDoc**: http://localhost/api/redoc/

## Переменные окружения

| Переменная | Описание | Значение по умолчанию |
|------------|----------|----------------------|
| `SECRET_KEY` | Секретный ключ Django | (обязательно) |
| `DEBUG` | Режим отладки | False |
| `ALLOWED_HOSTS` | Разрешённые хосты (через запятую) | localhost,127.0.0.1 |
| `DATABASE_ENGINE` | Движок БД | django.db.backends.postgresql |
| `DATABASE_NAME` | Имя базы данных | crmlite |
| `DATABASE_USER` | Пользователь БД | crmlite_user |
| `DATABASE_PASSWORD` | Пароль БД | (из POSTGRES_PASSWORD) |
| `DATABASE_HOST` | Хост БД | db |
| `DATABASE_PORT` | Порт БД | 5432 |
| `POSTGRES_PASSWORD` | Пароль PostgreSQL | change_me_in_production |

## Production рекомендации

1. **SSL/TLS**: Настройте HTTPS с Let's Encrypt
2. **Firewall**: Ограничьте доступ к портам
3. **Мониторинг**: Настройте логирование и мониторинг
4. **Бэкапы**: Настройте регулярное резервное копирование БД
5. **Обновления**: Следите за обновлениями образов

## Разработка

Для локальной разработки без Docker:

```bash
cd KursFinalProject
pip install -r requirements.txt
python manage.py runserver
```

## Тестирование

```bash
docker-compose exec web python manage.py test api.test_api