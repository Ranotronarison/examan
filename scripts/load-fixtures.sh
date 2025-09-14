#!/bin/bash

# Database Fixtures Loading Script for Examan
# ⚠️  WARNING: This will erase all existing data in the database!

set -e

echo "⚠️  WARNING: Loading fixtures will erase ALL existing data in the database!"
echo "📋 This includes users, exams, and all other data."
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled."
    exit 0
fi

echo ""
echo "📋 Loading fixtures..."

# Check if containers are running
if ! docker compose ps examan-api | grep -q "Up"; then
    echo "❌ Error: examan-api container is not running."
    echo "💡 Run 'docker compose up -d' first."
    exit 1
fi

# Load fixtures
echo "🗄️  Loading initial data..."
docker compose exec examan-api php bin/console doctrine:fixtures:load --no-interaction

echo ""
echo "✅ Fixtures loaded successfully!"
echo ""
echo "👤 Default users created:"
echo "   Admin: admin@examan.com / password123"
