# Build Onlook web client
FROM oven/bun:1

WORKDIR /app

# Set build and production environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV STANDALONE_BUILD=true
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

# Copy everything (monorepo structure)
COPY . .

# Install dependencies and build
RUN bun install --frozen-lockfile

# Build-time env vars required by apps/web/client/src/env.ts (provided by Railway service variables)
ARG CSB_API_KEY
ARG SUPABASE_DATABASE_URL
ARG SUPABASE_SERVICE_ROLE_KEY
ARG OPENROUTER_API_KEY
ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_ANON_KEY
ARG NEXT_PUBLIC_SITE_URL

RUN cd apps/web/client && bun run build:standalone

# Expose the application port
EXPOSE 3000

# Health check to ensure the application is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD bun -e "fetch('http://localhost:3000').then(r => r.ok ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))"

# Start the Next.js server
CMD ["bun", "apps/web/client/server.js"]