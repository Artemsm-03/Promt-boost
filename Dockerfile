# Multi-stage build for optimal image size and security
FROM node:20-slim AS builder

WORKDIR /app

# Copy package management files
COPY package*.json ./

# Install dependencies (including devDependencies for build phase)
RUN npm ci

# Copy the rest of the application files
COPY . .

# Build the frontend assets and compile the Express server
RUN npm run build

# Production runtime stage
FROM node:20-slim

WORKDIR /app

# Expose the correct standard port for Cloud Run / Render / containers
ENV PORT=3000
EXPOSE 3000

# Set production flag
ENV NODE_ENV=production

# Copy built artifacts and package manifest from builder stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist

# Install only production dependencies
RUN npm ci --only=production

# In production, we run the bundled commonjs server
CMD ["npm", "start"]
