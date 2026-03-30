# CRMLite Deployment Guide

Документация по развёртыванию CRMLite на Docker (Railway) и Docker Compose (локально).

## Содержание

1. [Деплой на Railway](#деплой-на-railway)
2. [Деплой с Docker Compose](#деплой-с-docker-compose)
3. [Переменные окружения](#переменные-окружения)
4. [API Endpoints](#api-endpoints)
5. [Production рекомендации](#production-рекомендации)

---

## Деплой на Railway

### Шаг 1: Подключение PostgreSQL

1. Создайте новый проект в [Railway](https://railway.app)
2. Добавьте **PostgreSQL** плагин к проекту
3. После создания Railway автоматически создаст переменную `DATABASE_URL`

### Шаг 2: Настройка переменных окружения

В Railway Dashboard добавьте переменные:

| Переменная | Значение |
|------------|----------|
| `SECRET_KEY` | Сгенерируйте новый случайный ключ |
| `DEBUG` | `False` |
| `ALLOWED_HOSTS` | `your-app.railway.app` (домен Railway) |

### Шаг 3: Деплой

1. Подключите GitHub репозиторий к Railway
2. Выберите `FinalProjectGitHubDocker/KursFinalProject` как корень сервиса
3. Railway автоматически найдёт Dockerfile и выполнит сборку

### Шаг 4: Настройка start command (если нужно)

Если Railway не определил команду автоматически, укажите в настройках:

```
sh /app/entrypoint.sh
```

---

## Деплой с Docker Compose

Документация по развёртыванию CRMLite с использованием Docker и Docker Compose.

## Быстрый старт

### 1. Подготовка

Отредактируйте `.env` файл, указав реальные значения или создайте на сервере необходимые переменные окружения:

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

После запуска приложение будет доступно по адресу (вместо localhost будет your-domain.com если есть установлена переменная ALLOWED_HOSTS=your-domain.com):

- **API**: http://localhost/api/
- **Swagger UI**: http://localhost/api/swagger/
- **ReDoc**: http://localhost/api/redoc/

## Переменные окружения

### Переменные для Railway

При деплое на Railway с PostgreSQL, настройте следующие переменные в Railway Dashboard:

| Переменная | Описание | Пример значения |
|------------|----------|-----------------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/dbname` |
| `SECRET_KEY` | Секретный ключ Django | (сгенерируйте новый) |
| `DEBUG` | Режим отладки | `False` |
| `ALLOWED_HOSTS` | Разрешённые хосты | `your-app.railway.app` |

**Важно:** В Railway переменная `DATABASE_URL` заполняется автоматически после подключения PostgreSQL через переменные:

```
DATABASE_URL="postgresql://${{PGUSER}}:${{POSTGRES_PASSWORD}}@${{RAILWAY_PRIVATE_DOMAIN}}:5432/${{PGDATABASE}}"
```

Или публичный URL:
```
DATABASE_PUBLIC_URL="postgresql://${{PGUSER}}:${{POSTGRES_PASSWORD}}@${{RAILWAY_TCP_PROXY_DOMAIN}}:${{RAILWAY_TCP_PROXY_PORT}}/${{PGDATABASE}}"
```

Для приватного подключения (рекомендуется) используйте `DATABASE_URL`.

### Переменные для Docker Compose (локально)

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