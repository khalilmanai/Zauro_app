#!/bin/bash

# Zauro Marketplace Docker Management Scripts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
}

# Check if .env file exists
check_env() {
    if [ ! -f .env ]; then
        print_error ".env file not found. Please copy env.example to .env and configure it."
        exit 1
    fi
}

# Build all services
build_all() {
    print_header "Building All Services"
    check_docker
    check_env
    
    print_status "Building backend service..."
    docker-compose build backend
    
    print_status "Building Hedera service..."
    docker-compose build hedera-service
    
    print_status "All services built successfully!"
}

# Start all services
start_all() {
    print_header "Starting All Services"
    check_docker
    check_env
    
    print_status "Starting services..."
    docker-compose up -d
    
    print_status "Waiting for services to be healthy..."
    sleep 10
    
    print_status "Checking service health..."
    docker-compose ps
    
    print_status "All services started successfully!"
    print_status "Backend API: http://localhost/api/v1"
    print_status "Hedera Service: http://localhost/hedera"
    print_status "Database: localhost:5432"
}

# Stop all services
stop_all() {
    print_header "Stopping All Services"
    check_docker
    
    print_status "Stopping services..."
    docker-compose down
    
    print_status "All services stopped successfully!"
}

# Restart all services
restart_all() {
    print_header "Restarting All Services"
    stop_all
    start_all
}

# View logs
view_logs() {
    print_header "Viewing Service Logs"
    check_docker
    
    if [ -n "$1" ]; then
        print_status "Showing logs for: $1"
        docker-compose logs -f "$1"
    else
        print_status "Showing logs for all services"
        docker-compose logs -f
    fi
}

# Execute command in container
exec_command() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        print_error "Usage: $0 exec <service> <command>"
        print_error "Example: $0 exec backend sh"
        exit 1
    fi
    
    print_header "Executing Command in $1"
    check_docker
    
    print_status "Executing: $2"
    docker-compose exec "$1" $2
}

# Database operations
db_migrate() {
    print_header "Running Database Migrations"
    check_docker
    
    print_status "Running Prisma migrations..."
    docker-compose exec backend npx prisma migrate deploy
    
    print_status "Generating Prisma client..."
    docker-compose exec backend npx prisma generate
    
    print_status "Database migrations completed!"
}

db_seed() {
    print_header "Seeding Database"
    check_docker
    
    print_status "Running database seed..."
    docker-compose exec backend npm run db:seed
    
    print_status "Database seeded successfully!"
}

db_reset() {
    print_header "Resetting Database"
    check_docker
    
    print_warning "This will delete all data in the database!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping services..."
        docker-compose down
        
        print_status "Removing database volume..."
        docker volume rm zauro_postgres_data 2>/dev/null || true
        
        print_status "Starting services..."
        docker-compose up -d postgres
        
        print_status "Waiting for database..."
        sleep 10
        
        print_status "Running migrations..."
        db_migrate
        
        print_status "Database reset completed!"
    else
        print_status "Database reset cancelled."
    fi
}

# Clean up Docker resources
cleanup() {
    print_header "Cleaning Up Docker Resources"
    check_docker
    
    print_status "Stopping all services..."
    docker-compose down
    
    print_status "Removing unused images..."
    docker image prune -f
    
    print_status "Removing unused volumes..."
    docker volume prune -f
    
    print_status "Removing unused networks..."
    docker network prune -f
    
    print_status "Cleanup completed!"
}

# Show service status
status() {
    print_header "Service Status"
    check_docker
    
    print_status "Docker Compose Services:"
    docker-compose ps
    
    echo
    print_status "Docker System Info:"
    docker system df
    
    echo
    print_status "Service Health Checks:"
    
    # Check backend health
    if curl -f http://localhost/api/v1/health > /dev/null 2>&1; then
        print_status "✓ Backend API is healthy"
    else
        print_error "✗ Backend API is not responding"
    fi
    
    # Check Hedera health
    if curl -f http://localhost/hedera/collection-status > /dev/null 2>&1; then
        print_status "✓ Hedera service is healthy"
    else
        print_error "✗ Hedera service is not responding"
    fi
}

# Production deployment
deploy_prod() {
    print_header "Production Deployment"
    check_docker
    check_env
    
    print_warning "This will deploy to production. Make sure you have:"
    print_warning "1. Configured production environment variables"
    print_warning "2. SSL certificates in ./ssl/ directory"
    print_warning "3. Updated domain name in nginx-prod.conf"
    
    read -p "Continue with production deployment? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Building production images..."
        docker-compose -f docker-compose.prod.yml build
        
        print_status "Starting production services..."
        docker-compose -f docker-compose.prod.yml up -d
        
        print_status "Running database migrations..."
        docker-compose -f docker-compose.prod.yml exec backend npx prisma migrate deploy
        
        print_status "Production deployment completed!"
    else
        print_status "Production deployment cancelled."
    fi
}

# Show help
show_help() {
    echo "Zauro Marketplace Docker Management Script"
    echo
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  build              Build all services"
    echo "  start              Start all services"
    echo "  stop               Stop all services"
    echo "  restart            Restart all services"
    echo "  logs [service]      View logs (optionally for specific service)"
    echo "  exec <service> <cmd> Execute command in service container"
    echo "  db-migrate         Run database migrations"
    echo "  db-seed            Seed the database"
    echo "  db-reset           Reset the database (DESTRUCTIVE)"
    echo "  cleanup            Clean up Docker resources"
    echo "  status             Show service status"
    echo "  deploy-prod        Deploy to production"
    echo "  help               Show this help message"
    echo
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs backend"
    echo "  $0 exec backend sh"
    echo "  $0 db-migrate"
}

# Main script logic
case "$1" in
    build)
        build_all
        ;;
    start)
        start_all
        ;;
    stop)
        stop_all
        ;;
    restart)
        restart_all
        ;;
    logs)
        view_logs "$2"
        ;;
    exec)
        exec_command "$2" "$3"
        ;;
    db-migrate)
        db_migrate
        ;;
    db-seed)
        db_seed
        ;;
    db-reset)
        db_reset
        ;;
    cleanup)
        cleanup
        ;;
    status)
        status
        ;;
    deploy-prod)
        deploy_prod
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo
        show_help
        exit 1
        ;;
esac
