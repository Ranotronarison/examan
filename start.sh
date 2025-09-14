#!/bin/bash

# Examan Application Setup Script
# Automated deployment for the complete application

set -e

# Check Docker availability
if ! command -v docker &> /dev/null; then
  echo "❌ Docker not found. Install Docker first."
  exit 1
fi

echo "🚀 Starting Examan deployment..."

# Clone submodules if needed
SUBMODULES=("examan-api:git@github.com:Ranotronarison/examan-api.git" "examan-front:git@github.com:Ranotronarison/examan-front.git")

for submodule in "${SUBMODULES[@]}"; do
  IFS=':' read -r folder repo <<< "$submodule"
  if [ ! -d "./$folder" ] || [ -z "$(ls -A ./$folder)" ]; then
    echo "📥 Cloning $folder..."
    git clone "$repo"
  fi
done

# Update submodules
echo "🔄 Updating submodules..."
for submodule in "${SUBMODULES[@]}"; do
  IFS=':' read -r folder repo <<< "$submodule"
  git submodule update --remote "$folder" 2>/dev/null || true
done

# Build frontend
echo "📦 Building frontend..."
if [ -d "./examan-front" ]; then
  cd examan-front
  docker build -f Dockerfile.build --target builder -t examan-frontend-builder .
  rm -rf dist
  TEMP_CONTAINER=$(docker create examan-frontend-builder)
  docker cp "$TEMP_CONTAINER:/app/dist" ./
  docker rm "$TEMP_CONTAINER"
  docker rmi examan-frontend-builder
  cd ..
fi

# Start containers
echo "🐳 Starting containers..."
docker compose up -d --wait

# Install dependencies
echo "📚 Installing dependencies..."
docker compose exec examan-api composer install --no-interaction

# Generate JWT keys if needed
echo "🔐 Setting up JWT authentication..."
docker compose exec examan-api php bin/console lexik:jwt:generate-keypair --skip-if-exists

# Setup database
echo "🗄️  Setting up database..."
sleep 5
docker compose exec examan-api php bin/console doctrine:database:create --if-not-exists
docker compose exec examan-api php bin/console doctrine:schema:update --force

# Ask for fixtures loading
echo ""
echo "📋 Do you want to load initial data (fixtures)?"
echo "⚠️  Note: This will create sample users and exams"
read -p "Load fixtures? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📋 Loading initial data..."
    docker compose exec examan-api php bin/console doctrine:fixtures:load --no-interaction
    FIXTURES_LOADED=true
else
    echo "⏭️  Skipping fixtures loading"
    FIXTURES_LOADED=false
fi

# Create deployment scripts directory
mkdir -p scripts

echo ""
echo "🎉 Examan is ready!"
echo "📱 Frontend: http://localhost:8000"
echo "🔗 API: http://localhost:8000/api"
echo ""

if [ "$FIXTURES_LOADED" = true ]; then
    echo "👤 Default users:"
    echo "   Admin: admin@examan.com / password123"
    echo ""
else
    echo "� To load initial data later, run:"
    echo "   ./scripts/load-fixtures.sh"
    echo ""
fi

echo "📋 Available scripts:"
echo "   ./scripts/deploy-frontend.sh   # Redeploy frontend"
echo "   ./scripts/setup-database.sh    # Setup database schema"
echo "   ./scripts/load-fixtures.sh     # Load initial data"
