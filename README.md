# Examan - Exam Management Application

A modern exam management application built with Symfony API Platform (backend) and React + Vite (frontend), orchestrated with Docker.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Variables](#environment-variables)
- [Quick Start](#quick-start)
- [Manual Setup](#manual-setup)
- [Database Setup](#database-setup)
- [Development Workflow](#development-workflow)
- [Access Points](#access-points)
- [Troubleshooting](#troubleshooting)

## 🚀 Prerequisites

Before running the application, ensure you have the following installed:

- **Docker** (version 20.10 or higher)
- **Docker Compose** (version 2.0 or higher)
- **Git** (for cloning submodules)

> **Note**: Node.js is **NOT required** on your host machine as the frontend is built using Docker containers.

## 🔧 Environment Variables

### Backend Environment Variables

The backend requires the following environment variables to be configured:

#### **Mandatory Variables**

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `DATABASE_URL` | Database connection string | `mysql://app:password@examan-db:3306/examan-db?serverVersion=mariadb-12.0.0&charset=utf8mb4` |
| `APP_SECRET` | Symfony application secret | `62de4bcea013fa873bbaeba7bdd1cc29` |
| `JWT_SECRET_KEY` | Path to JWT private key | `%kernel.project_dir%/config/jwt/private.pem` |
| `JWT_PUBLIC_KEY` | Path to JWT public key | `%kernel.project_dir%/config/jwt/public.pem` |
| `JWT_PASSPHRASE` | JWT key passphrase | `d84abf742861df7e3b0082652d23747059f849a5351a66aa4e15233e905a0512` |

#### **Optional Variables**

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `APP_ENV` | Application environment | `dev` |
| `CORS_ALLOW_ORIGIN` | CORS allowed origins | `'^https?://(localhost\|127\.0\.0\.1)(:[0-9]+)?$'` |
| `WEB_PORT` | Web server port | `8000` |

#### **Frontend Development Variables (Docker Compose)**

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `FRONTEND_DEV_PORT` | Frontend development server port | `4173` |

#### **Database Variables (Docker Compose)**

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `MARIADB_ROOT_PASSWORD` | MariaDB root password | `password` |
| `MARIADB_DATABASE` | Database name | `examan-db` |
| `MARIADB_USER` | Database user | `app` |
| `MARIADB_PASSWORD` | Database password | `password` |

### Environment Files Location

Environment variables are configured in:
- `examan-api/.env` - Default environment variables
- `examan-api/.env.local` - Local overrides (not committed)
- `examan-api/.env.dev.local` - Development-specific overrides
- `examan-front/.env.local` - Frontend development overrides
- `docker-compose.yaml` - Container environment variables
- `docker-compose.override.yaml` - Development-specific services

## ⚡ Quick Start

The fastest way to get the application running is using the automated setup script:

```bash
# Clone the main repository
git clone https://github.com/Ranotronarison/examan.git
cd examan

# Run the automated setup script
./start.sh
```

This script will:
1. ✅ Clone and setup all submodules (`examan-api`, `examan-front`)
2. ✅ Build the frontend application using Docker
3. ✅ Start all Docker containers
4. ✅ Install PHP dependencies
5. ✅ Create database schema
6. ✅ Optionally load fixtures (initial data)
7. ✅ Configure nginx for serving both frontend and API

### Stopping the Application

To stop and remove all containers:

```bash
# Stop and remove all containers
docker compose down
```

This will:
- Stop all running containers
- Remove containers and networks
- Preserve database data (stored in volumes)

To completely remove everything including volumes:

```bash
# Stop and remove everything including database data
docker compose down -v
```

### Development Mode

For frontend development with hot reload, you can use the development profile:

```bash
# Start with development frontend server (includes hot reload)
docker compose --profile dev up -d

# Access points:
# - Development: http://localhost:4173 (hot reload)
# - Production: http://localhost:8000 (nginx)
```

The `docker-compose.override.yaml` file automatically provides a development service for the frontend when using the `dev` profile. This uses the simplified Dockerfile optimized for development, which gives you:
- ✅ **Hot reload** for instant code changes
- ✅ **Source maps** for better debugging
- ✅ **Development optimizations** from Vite
- ✅ **Simple setup** without production complexity

## 🔨 Manual Setup

If you prefer to set up the application manually:

### 1. Clone Repositories

```bash
# Clone main repository
git clone https://github.com/Ranotronarison/examan.git
cd examan

# Clone submodules
git clone git@github.com:Ranotronarison/examan-api.git
git clone git@github.com:Ranotronarison/examan-front.git
```

### 2. Build Frontend

For the static frontend build, use the dedicated build Dockerfile:

```bash
cd examan-front
docker build -f Dockerfile.build --target builder -t examan-frontend-builder .
docker create --name examan-frontend-temp examan-frontend-builder
docker cp examan-frontend-temp:/app/dist ./dist
docker rm examan-frontend-temp
docker rmi examan-frontend-builder
cd ..
```

### 3. Start Services

```bash
# Start all containers
docker compose up -d --wait

# Install PHP dependencies
docker compose exec examan-api composer install
```

### 4. Setup Database

```bash
# Create database schema
docker compose exec examan-api php bin/console doctrine:database:create --if-not-exists

# Update database schema
docker compose exec examan-api php bin/console doctrine:schema:update --force

# Load fixtures (sample data)
docker compose exec examan-api php bin/console doctrine:fixtures:load --no-interaction
```

## 🗄️ Database Setup

### Database Creation and Updates

The application uses **MariaDB 12.0** as the database engine with **Doctrine ORM** for schema management.

#### **Initial Database Setup**

```bash
# Create database (if not exists)
docker compose exec examan-api php bin/console doctrine:database:create --if-not-exists

# Create/update database schema
docker compose exec examan-api php bin/console doctrine:schema:update --force
```

#### **Loading Fixtures (Initial Data)**

⚠️ **Warning**: Loading fixtures will erase all existing data in the database!

The application includes optional fixtures for initial data setup. You can load them using the dedicated script:

```bash
# Load fixtures using the dedicated script (with confirmation prompt)
./scripts/load-fixtures.sh

# Or load directly (without confirmation prompt)
docker compose exec examan-api php bin/console doctrine:fixtures:load --no-interaction
```

**Default Fixture Data:**
- **Admin User**: 
  - Email: `admin@examan.com`
  - Password: `password123`
  - Role: `ROLE_ADMIN`
- **Sample Exams**: Multiple exam entries with different statuses

#### **Database Reset (Development)**

```bash
# Drop and recreate database
docker compose exec examan-api php bin/console doctrine:database:drop --force
docker compose exec examan-api php bin/console doctrine:database:create
docker compose exec examan-api php bin/console doctrine:schema:update --force

# Optionally load fixtures
./scripts/load-fixtures.sh
```

## 🔄 Development Workflow

### Frontend Development

#### **Option 1: Development with Hot Reload (Recommended for Active Development)**

For active frontend development with hot reload and live updates, use the development service:

```bash
# Start all services including frontend development server
docker compose --profile dev up -d

# The frontend will be available at:
# - Development server: http://localhost:4173 (with hot reload)
# - Production build: http://localhost:8000 (served by nginx)
```

**Development Features:**
- ✅ **Hot reload**: Changes are instantly reflected in the browser
- ✅ **Source maps**: Better debugging experience
- ✅ **Fast builds**: Vite's fast development server
- ✅ **Live updates**: No need to rebuild manually

```bash
# View frontend development logs
docker compose logs -f examan-front

# Stop development services
docker compose --profile dev down
```

#### **Option 2: Production Build Deployment**

When you want to test the production build or deploy changes:

```bash
# Rebuild and deploy frontend
./scripts/deploy-frontend.sh
```

This script:
- Builds the React application using Docker
- Extracts built files
- Restarts nginx to serve updated files

#### **Switching Between Development Modes**

```bash
# Start with development frontend (hot reload)
docker compose --profile dev up -d

# Switch to production build testing
docker compose --profile dev down
./scripts/deploy-frontend.sh
docker compose up -d
```

### Backend Development

For backend changes:

```bash
# Restart API container
docker compose restart examan-api

# View API logs
docker compose logs -f examan-api

# Clear Symfony cache
docker compose exec examan-api php bin/console cache:clear
```

### Viewing Logs

```bash
# View all container logs
docker compose logs -f

# View specific service logs
docker compose logs -f examan-api
docker compose logs -f examan-db
docker compose logs -f web
```

## 🌐 Access Points

Once the deployment is completed, you can access the application at:

### **Frontend Application**
- **Production URL**: http://localhost:8000
- **Development URL**: http://localhost:4173 *(available when using `--profile dev`)*
- **Description**: Main React application interface
- **Login Credentials**:
  - Admin: `admin@examan.com` / `password123`

**Note**: The development server (port 4173) provides hot reload and faster development experience, while the production build (port 8000) serves the optimized application through nginx.

### **API Documentation**
- **URL**: http://localhost:8000/api
- **Description**: API Platform auto-generated documentation
- **Features**: Interactive API browser with request/response examples

### **Database Access**
- **Host**: localhost
- **Port**: 3306
- **Database**: examan-db
- **Username**: app
- **Password**: password

### **Example API Usage**

```bash
# Login and get JWT token
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@examan.com", "password": "password123"}'

# Get exams list (replace TOKEN with actual JWT)
curl -X GET http://localhost:8000/api/exams \
  -H "Authorization: Bearer TOKEN"
```

## 🔧 Useful Commands

### Container Management

```bash
# Start all services (production mode)
docker compose up -d

# Start all services with frontend development server
docker compose --profile dev up -d

# Stop all services
docker compose down

# Stop development services specifically
docker compose --profile dev down

# Restart specific service
docker compose restart examan-api
docker compose restart web

# View container status
docker compose ps

# Enter container shell
docker compose exec examan-api bash
docker compose exec examan-db mysql -u app -p
```

### Development Commands

```bash
# Frontend development with hot reload
docker compose --profile dev up -d

# Frontend production build
./scripts/deploy-frontend.sh

# View frontend development logs
docker compose logs -f examan-front

# Backend cache clear
docker compose exec examan-api php bin/console cache:clear

# Database reset
docker compose exec examan-api php bin/console doctrine:database:drop --force
docker compose exec examan-api php bin/console doctrine:database:create
docker compose exec examan-api php bin/console doctrine:schema:update --force

# Load fixtures (optional)
./scripts/load-fixtures.sh

# View API routes
docker compose exec examan-api php bin/console debug:router
```

## 🐛 Troubleshooting

### Common Issues

#### **Port Already in Use**
```bash
# Change port in docker-compose.yaml or stop conflicting services
sudo lsof -i :8000
docker compose down
```

#### **Database Connection Issues**
```bash
# Check database container status
docker compose ps examan-db

# Check database logs
docker compose logs examan-db

# Verify database credentials in .env files
```

#### **Frontend Not Loading**
```bash
# For production build issues
./scripts/deploy-frontend.sh

# Check nginx logs
docker compose logs web

# Verify dist folder exists
ls -la examan-front/dist/
```

#### **Frontend Development Server Issues**
```bash
# Check development server logs
docker compose logs -f examan-front

# Restart development service
docker compose --profile dev restart examan-front

# Check if node_modules are installed
docker compose exec examan-front ls -la node_modules

# Manually install dependencies if needed
docker compose exec examan-front npm ci
```

#### **API Returning 500 Errors**
```bash
# Check API logs
docker compose logs examan-api

# Clear Symfony cache
docker compose exec examan-api php bin/console cache:clear

# Check database connection
docker compose exec examan-api php bin/console doctrine:database:create --if-not-exists
```

#### **JWT Authentication Issues**
```bash
# Verify JWT keys exist
docker compose exec examan-api ls -la config/jwt/

# Generate new JWT keys if missing
docker compose exec examan-api php bin/console lexik:jwt:generate-keypair --overwrite
```

### Getting Help

1. **Check logs**: Always start by checking container logs
2. **Verify environment**: Ensure all required environment variables are set
3. **Database status**: Verify database is running and accessible
4. **Container health**: Check if all containers are healthy

```bash
# Quick health check
docker compose ps
curl -I http://localhost:8000
curl -I http://localhost:8000/api
```

## 📦 Project Structure

```
examan/
├── docker-compose.yaml          # Docker orchestration
├── docker-compose.override.yaml # Development services (auto-loaded)
├── start.sh                     # Automated setup script
├── scripts/                     # Deployment and utility scripts
│   ├── deploy-frontend.sh       # Frontend deployment script
│   ├── setup-database.sh        # Database schema setup
│   └── load-fixtures.sh         # Load initial data (optional)
├── examan-api/                  # Symfony API Platform backend
│   ├── src/Entity/              # Doctrine entities
│   ├── src/DataFixtures/        # Database fixtures
│   ├── config/                  # Symfony configuration
│   └── docker/                  # Docker configuration
├── examan-front/                # React + Vite frontend
│   ├── src/                     # React components
│   ├── dist/                    # Built static files
│   ├── Dockerfile               # Development server configuration
│   └── Dockerfile.build         # Static build configuration
├── web/                         # Nginx configuration
└── mariadb/                     # Database data
```

### Frontend Dockerfile Purpose

The frontend directory contains two Dockerfiles for different purposes:

- **`Dockerfile`**: Runs the Vite development server with hot reload (used by `docker-compose.override.yaml`)
- **`Dockerfile.build`**: Creates static build files for nginx serving (used by deployment scripts)

---

**🎉 Congratulations!** Your Examan application should now be running successfully. Visit http://localhost:8000 to start using the application!
