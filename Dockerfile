# Multi-stage build example with best practices
# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /build

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Runtime
FROM node:18-alpine

# Add metadata
LABEL maintainer="your-email@example.com"
LABEL description="Docker image built and published via GitHub Actions"

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy built dependencies from builder
COPY --from=builder --chown=nodejs:nodejs /build/node_modules ./node_modules

# Copy application code
COPY --chown=nodejs:nodejs . .

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD node healthcheck.js || exit 1

# Start application
CMD ["node", "server.js"]
