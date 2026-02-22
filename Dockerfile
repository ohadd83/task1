# --- Stage 1: Build Stage ---
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files
COPY package.json ./

# Install ALL dependencies (including typescript and @types)
RUN npm install

# Copy source code and config
COPY tsconfig.json ./
COPY src ./src

# Compile TypeScript to JavaScript 
# (This uses the "outDir": "./dist" from your tsconfig.json)
RUN npm run build

# --- Stage 2: Production Stage ---
FROM node:20-alpine

WORKDIR /app

# Only copy package.json and install production-only dependencies
COPY package.json ./
RUN npm install --only=production

# Copy only the compiled code from the builder stage
COPY --from=builder /app/dist ./dist

# Expose the port (Standard for Express is 3000)
EXPOSE 3000

# Run the compiled JavaScript using the 'serve' script we added
CMD ["npm", "run", "serve"]
