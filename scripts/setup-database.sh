#!/bin/bash

# Database# Update schema
echo "🔄 Updating database schema..."
docker compose exec examan-api php bin/console doctrine:schema:update --force

echo "✅ Database setup completed!"
echo ""
echo "💡 To load initial data (fixtures), run:"
echo "   ./scripts/load-fixtures.sh"t Script for Examan
# Sets up database for production deployment

set -e

echo "🗄️  Setting up database..."

# Check if containers are running
if ! docker compose ps examan-api | grep -q "Up"; then
    echo "❌ Error: examan-api container is not running."
    exit 1
fi

# Wait for database to be ready
echo "⏳ Waiting for database..."
sleep 5

# Create database
echo "📋 Creating database..."
docker compose exec examan-api php bin/console doctrine:database:create --if-not-exists

# Update schema
echo "🔄 Updating database schema..."
docker compose exec examan-api php bin/console doctrine:schema:update --force

# Load fixtures
echo "📋 Loading initial data..."
docker compose exec examan-api php bin/console doctrine:fixtures:load --no-interaction

echo "✅ Database setup completed!"
echo "� Default users: admin@examan.com / password123"
