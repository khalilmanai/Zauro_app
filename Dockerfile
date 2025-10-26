# Multi-stage build for NestJS (Node 22) with Prisma

FROM node:22-alpine AS base
WORKDIR /app

# Install OS deps needed by Prisma engines and node-gyp (bcrypt)
RUN apk add --no-cache libc6-compat python3 make g++ openssl

# ---------- Builder: install dev deps and build ----------
FROM base AS builder
COPY package*.json ./
RUN npm ci
COPY . ./
# Generate Prisma client before build to satisfy TS types
RUN npx prisma generate
RUN npm run build

# ---------- Runner: production image with only prod deps ----------
FROM base AS runner
ENV NODE_ENV=production
WORKDIR /app

# Copy only needed files
COPY package*.json ./
RUN npm ci --omit=dev

# Copy Prisma schema for migrations and client runtime
COPY prisma ./prisma

# Copy built app and necessary runtime files
COPY --from=builder /app/dist ./dist

# Copy entrypoint for Prisma migrations
COPY docker-entrypoint.sh ./docker-entrypoint.sh
RUN chmod +x ./docker-entrypoint.sh && \
    sed -i 's/\r$//' ./docker-entrypoint.sh

# Expose Nest default port
ENV PORT=3000
EXPOSE 3000

# Healthcheck (optional)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s CMD node -e "require('http').get(`http://localhost:${PORT}/api/v1`,()=>process.exit(0)).on('error',()=>process.exit(1))"

# Default command expects env vars (e.g., DATABASE_URL, JWT_SECRET, etc.)
ENTRYPOINT ["/bin/sh", "/app/docker-entrypoint.sh"]
CMD ["node", "dist/main.js"]


