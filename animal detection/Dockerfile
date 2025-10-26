# Multi-stage build for Animal Detection ML Service
FROM python:3.11-slim AS base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean

WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
# Install CPU-only PyTorch to avoid CUDA dependencies (much smaller and faster)
RUN pip install --no-cache-dir torch==2.9.0+cpu --index-url https://download.pytorch.org/whl/cpu
# Install other dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY *.py ./
COPY *.json ./

# Create directory for uploaded images
RUN mkdir -p /app/uploads

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=api.py
ENV FLASK_ENV=production

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD python -c "import requests; requests.get('http://localhost:5000/health', timeout=5)" || exit 1

# Run the application
CMD ["python", "api.py"]

