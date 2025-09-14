#!/bin/bash

# Frontend Deployment Script for Examan
# Builds and deploys frontend using Docker

set -e

echo "🚀 Deploying frontend..."

cd examan-front

# Build frontend using Docker
echo "📦 Building frontend..."
docker build -f Dockerfile.build --target builder -t examan-frontend-builder .

# Extract built files
echo "📤 Extracting build files..."
TEMP_CONTAINER=$(docker create examan-frontend-builder)
docker cp "$TEMP_CONTAINER:/app/dist" ./
docker rm "$TEMP_CONTAINER"
docker rmi examan-frontend-builder

# Restart nginx
echo "🔄 Restarting web server..."
cd ..
docker compose restart web

echo "✅ Frontend deployed!"
echo "📱 Access: http://localhost:8000"# Build and Deploy Script for Examan Frontend

echo "Building frontend..."
cd examan-front
npm run build

echo "Restarting web container..."
cd ..
docker compose restart web

echo "Frontend deployed successfully!"
echo "Access your application at: http://localhost:8000"
