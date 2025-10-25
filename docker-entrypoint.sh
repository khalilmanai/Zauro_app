#!/bin/sh
set -e

# Generate Prisma client and run migrations
npx prisma generate

if [ "$NODE_ENV" = "development" ]; then
  echo "[entrypoint] NODE_ENV=development → applying schema with prisma db push"
  npx prisma db push
  if [ -n "$RUN_SEED" ]; then
    echo "[entrypoint] Running seed"
    npm run db:seed || true
  fi
else
  if [ -n "$RUN_SEED" ]; then
    echo "[entrypoint] Running prisma migrate deploy and seed"
    npx prisma migrate deploy
    npm run db:seed || true
  else
    echo "[entrypoint] Running prisma migrate deploy"
    npx prisma migrate deploy
  fi
fi

# Ensure build exists (fallback for cases where dist is missing)
MAIN_JS="dist/main.js"
ALT_MAIN_JS="dist/src/main.js"

if [ ! -f "$MAIN_JS" ] && [ ! -f "$ALT_MAIN_JS" ] && [ -f "package.json" ]; then
  echo "[entrypoint] dist/main.js not found; building now"
  # Ensure dev dependencies and CLI are present for build
  npm ci
  npx prisma generate || true
  npm run build
fi

# If command is node with default path but dist/main.js doesn't exist, try dist/src/main.js
if [ "$1" = "node" ]; then
  if [ -f "$MAIN_JS" ]; then
    exec node "$MAIN_JS"
  elif [ -f "$ALT_MAIN_JS" ]; then
    echo "[entrypoint] Using alternate entrypoint $ALT_MAIN_JS"
    exec node "$ALT_MAIN_JS"
  fi
fi

exec "$@"
