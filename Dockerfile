# Python base image
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=crmlite.settings

# Set work directory
WORKDIR /app

# Copy requirements first for better caching
COPY ./requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt gunicorn whitenoise

# Copy project
COPY . /app

# Expose port
EXPOSE 8000

# Run entrypoint script
ENTRYPOINT ["sh", "/app/entrypoint.sh"]
