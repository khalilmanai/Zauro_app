#!/bin/sh
# Don't exit on errors - let the app start even if db setup fails
# set -e

echo "[entrypoint] Starting Zauro backend entrypoint..."
echo "[entrypoint] NODE_ENV=${NODE_ENV}"
echo "[entrypoint] Working directory: $(pwd)"

# List what's in the dist directory
if [ -d "dist" ]; then
  echo "[entrypoint] Contents of dist directory:"
  ls -la dist/ || true
  echo "[entrypoint] Looking for main.js:"
  find dist -name "main.js" -type f || echo "[entrypoint] main.js not found"
else
  echo "[entrypoint] WARNING: dist directory does not exist!"
fi

# Prisma client should already be generated during build
echo "[entrypoint] Checking Prisma client..."
if [ -d "node_modules/.prisma/client" ]; then
  echo "[entrypoint] ✓ Prisma client is available"
else
  echo "[entrypoint] WARNING: Prisma client not found, attempting to generate..."
  npx prisma generate || echo "[entrypoint] Prisma generate failed, continuing anyway..."
fi

if [ "$NODE_ENV" = "development" ]; then
  echo "[entrypoint] NODE_ENV=development → applying schema with prisma db push"
  npx prisma db push --force-reset || {
    echo "[entrypoint] Schema push failed, trying with force reset..."
    npx prisma db push --force-reset
  }
  if [ -n "$RUN_SEED" ]; then
    echo "[entrypoint] Running seed"
    npm run db:seed || true
  fi
else
  # In production, use db push (applies schema directly from schema.prisma)
  echo "[entrypoint] ============================================="
  echo "[entrypoint] PRODUCTION: Setting up database schema"
  echo "[entrypoint] ============================================="
  echo "[entrypoint] DATABASE_URL is set: $(if [ -n "$DATABASE_URL" ]; then echo 'YES'; else echo 'NO - THIS IS A PROBLEM'; fi)"
  
  # Check if DATABASE_URL is set
  if [ -z "$DATABASE_URL" ]; then
    echo "[entrypoint] ERROR: DATABASE_URL is not set!"
    echo "[entrypoint] Add PostgreSQL service in Railway to get DATABASE_URL"
  fi
  
  # Run prisma db push to apply schema
  echo "[entrypoint] Running: prisma db push"
  if npx prisma db push --skip-generate; then
    echo "[entrypoint] ✓✓✓ DATABASE SCHEMA APPLIED SUCCESSFULLY ✓✓✓"
  else
    echo "[entrypoint] ⚠️ First db push failed, trying with --force-reset..."
    if npx prisma db push --skip-generate --force-reset; then
      echo "[entrypoint] ✓✓✓ DATABASE SCHEMA APPLIED WITH FORCE RESET ✓✓✓"
    else
      echo "[entrypoint] ⚠️ Force reset also failed, trying migrations..."
      if npx prisma migrate deploy; then
        echo "[entrypoint] ✓ Migrations applied successfully"
      else
        echo "[entrypoint] ⚠️ All database setup failed"
        echo "[entrypoint] App will start but collections table will be missing"
      fi
    fi
  fi
  
  echo "[entrypoint] Database setup completed"
  
  if [ -n "$RUN_SEED" ]; then
    echo "[entrypoint] Running seed script"
    npm run db:seed || echo "[entrypoint] Seed failed - continuing..."
  fi
fi

# Verify main.js exists before proceeding
MAIN_JS="dist/main.js"
ALT_MAIN_JS="dist/src/main.js"

if [ ! -f "$MAIN_JS" ] && [ ! -f "$ALT_MAIN_JS" ]; then
  echo "[entrypoint] ERROR: Neither $MAIN_JS nor $ALT_MAIN_JS exists!"
  echo "[entrypoint] This indicates a build failure. Building now..."
  
  if [ "$NODE_ENV" != "development" ]; then
    echo "[entrypoint] ERROR: Can't build in production without dev dependencies"
    echo "[entrypoint] Main.js should be built during Docker build stage"
    echo "[entrypoint] Check your Dockerfile.production"
    exit 1
  fi
  
  # Only build if in development mode
  echo "[entrypoint] Building in development mode..."
  npm ci
  npx prisma generate
  npm run build
  echo "[entrypoint] Build completed"
fi

# Execute the command
echo "[entrypoint] Executing: $@"
echo "[entrypoint] Arguments: $1 $2 $3"

# Determine the correct entry point
if [ "$1" = "node" ]; then
  # Detect which main.js file exists
  if [ -f "dist/src/main.js" ]; then
    echo "[entrypoint] Found dist/src/main.js - using it"
    if [ "$2" = "--max-old-space-size=384" ]; then
      exec node --max-old-space-size=384 dist/src/main.js
    else
      exec node dist/src/main.js
    fi
  elif [ -f "dist/main.js" ]; then
    echo "[entrypoint] Found dist/main.js - using it"
    if [ "$2" = "--max-old-space-size=384" ]; then
      exec node --max-old-space-size=384 dist/main.js
    else
      exec node dist/main.js
    fi
  else
    echo "[entrypoint] ERROR: Cannot find main.js in dist/src/ or dist/"
    echo "[entrypoint] Listing dist directory:"
    ls -la dist/ || echo "dist directory doesn't exist"
    exit 1
  fi
else
  exec "$@"
fi
