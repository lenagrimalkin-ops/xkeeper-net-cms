# builder stage
FROM node:20-alpine AS builder
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev
WORKDIR /opt/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# production stage
FROM node:20-alpine AS production
RUN apk add --no-cache vips-dev
WORKDIR /opt/app
ENV NODE_ENV=production
ENV PORT=1337
ENV HOST=0.0.0.0

COPY --from=builder /opt/app ./

EXPOSE 1337
CMD ["npm", "run", "start"]

HEALTHCHECK --start-period=60s --interval=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-1337}/admin || exit 1
