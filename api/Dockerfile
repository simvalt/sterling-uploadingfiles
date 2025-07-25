# Etapa 1: construcción
FROM python:3.11-slim AS builder

# Variables de entorno para no generar bytecode y usar logs legibles
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar dependencias del sistema necesarias para build
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libffi-dev \
    libpq-dev \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Copiar solo el archivo de dependencias para aprovechar cache
COPY requirements.txt .

# Crear virtualenv aislado para control de dependencias
RUN python -m venv /opt/venv \
 && . /opt/venv/bin/activate \
 && pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# Etapa 2: ejecución
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Instalar dependencias mínimas
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# Copiar entorno virtual desde el builder
COPY --from=builder /opt/venv /opt/venv

# Copiar el código fuente
COPY . .

# Exponer puerto por defecto para gunicorn
EXPOSE 8080

# Usar gunicorn como servidor WSGI
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]
