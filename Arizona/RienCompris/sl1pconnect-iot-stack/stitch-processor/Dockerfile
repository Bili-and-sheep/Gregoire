# hadolint ignore=DL3018
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:22-alpine
RUN adduser -u 1001 -D appuser
WORKDIR /app
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --chown=appuser:appuser . .
USER 1001
EXPOSE 8082
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8082/health', r => process.exit(r.statusCode===200?0:1))" || exit 1
CMD ["node", "index.js"]
