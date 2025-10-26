# Docker Setup for Animal Detection Service

This document describes how to build and run the Animal Detection ML service using Docker.

## Overview

The Animal Detection service provides:
- **Cattle Analysis**: Age, sex, breed, and health detection using ML models
- **Price Prediction**: Market value estimation using T5 transformer model
- **NFT Valuation**: Comprehensive NFT valuation with rarity analysis

## Architecture

```
┌─────────────────────────────────────────┐
│   Animal Detection Service (Flask)      │
├─────────────────────────────────────────┤
│  Port: 5000                             │
│  Dependencies:                          │
│  - T5 Model (Hugging Face)             │
│  - Roboflow APIs (external)            │
│  - NFT Value Estimator                 │
└─────────────────────────────────────────┘
```

## Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- Internet connection for model downloads

## Quick Start

### Option 1: Run with Docker Compose (Recommended)

From the project root:

```bash
docker-compose up -d animal-detection
```

This will:
1. Build the Docker image
2. Download models on first run (may take 5-10 minutes)
3. Start the service on port 5000

### Option 2: Build and Run Manually

```bash
cd "animal detection"
docker build -t zauro-animal-detection .
docker run -p 5000:5000 zauro-animal-detection
```

## Service Endpoints

Once running, access the service at: `http://localhost:5000`

### Health Check
```bash
curl http://localhost:5000/health
```

### API Information
```bash
curl http://localhost:5000/
```

### Analyze Cattle Image
```bash
curl -X POST http://localhost:5000/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "image_path": "download (1).jpg",
    "animal_id": "ZAURO-001"
  }'
```

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Service information |
| `/health` | GET | Health check |
| `/predict` | POST | Market price prediction |
| `/estimate-nft-value` | POST | NFT valuation |
| `/analyze` | POST | Complete analysis |

## Configuration

### Environment Variables

Default configuration is defined in the Dockerfile. To customize:

1. Create `.env` file:
```bash
cp .env.example .env
```

2. Edit `.env` with your settings:
```env
FLASK_PORT=5000
MODEL_NAME=amirboudidah/t5-cattle-price
ROBOFLOW_API_KEY=your_key
```

3. Update docker-compose.yml to use `.env`:
```yaml
animal-detection:
  env_file:
    - .env
```

## Model Storage

Models are downloaded to a Docker volume `ml_models` that persists between container restarts:

```yaml
volumes:
  - ml_models:/root/.cache/huggingface
```

This means:
- First build: Downloads take 5-10 minutes
- Subsequent starts: Instant (models cached)

## Troubleshooting

### Container fails to start

Check logs:
```bash
docker logs zauro_animal_detection
```

### Out of memory errors

Increase Docker memory limit:
- Docker Desktop → Settings → Resources → Memory
- Set to at least 4GB

### Model download slow

Use Docker build kit with caching:
```bash
DOCKER_BUILDKIT=1 docker-compose build animal-detection
```

### Health check fails

Check if models are loaded:
```bash
docker exec zauro_animal_detection python -c "from transformers import T5Tokenizer; print('Model loaded')"
```

## Development

### Enable Hot Reload

Uncomment volumes in docker-compose.yml:
```yaml
animal-detection:
  volumes:
    - "./animal detection:/app"
  command: flask run --host=0.0.0.0 --reload
```

### Running Locally (without Docker)

```bash
pip install -r requirements.txt
python api.py
```

## Production Considerations

1. **Resource Limits**: Set appropriate memory limits
2. **Security**: Add authentication/API keys
3. **Scaling**: Use container orchestration (K8s, ECS)
4. **Monitoring**: Add logging and metrics
5. **Caching**: Cache API responses for performance

## Integration with Main Stack

The service is integrated with the main Zauro stack:

```yaml
# In docker-compose.yml
services:
  db:              # PostgreSQL
  backend:         # NestJS Backend
  animal-detection: # Python ML Service
```

Backend can call animal-detection service:
```typescript
const response = await fetch('http://animal-detection:5000/analyze', {
  method: 'POST',
  body: JSON.stringify({ image_path, animal_id })
});
```

## Resource Usage

- **CPU**: Medium (during model inference)
- **Memory**: ~2GB (with models loaded)
- **Disk**: ~3GB (models + cache)
- **Network**: External calls to Roboflow APIs

## Monitoring

View logs in real-time:
```bash
docker logs -f zauro_animal_detection
```

Check resource usage:
```bash
docker stats zauro_animal_detection
```

## Cleanup

Remove container and volume:
```bash
docker-compose down -v
docker volume rm zauro_app_ml_models
```

## Support

For issues or questions, contact the Zauro development team.

