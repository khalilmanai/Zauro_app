@echo off
REM Zauro Marketplace Docker Management Script for Windows

setlocal enabledelayedexpansion

REM Colors (Windows doesn't support colors in batch, but we can use echo)
set "INFO=[INFO]"
set "WARNING=[WARNING]"
set "ERROR=[ERROR]"
set "HEADER=[HEADER]"

REM Function to print status
:print_status
echo %INFO% %~1
goto :eof

:print_warning
echo %WARNING% %~1
goto :eof

:print_error
echo %ERROR% %~1
goto :eof

:print_header
echo.
echo ================================
echo %HEADER% %~1
echo ================================
goto :eof

REM Check if Docker is running
:check_docker
docker info >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker is not running. Please start Docker Desktop."
    exit /b 1
)
goto :eof

REM Check if .env file exists
:check_env
if not exist .env (
    call :print_error ".env file not found. Please copy env.example to .env and configure it."
    exit /b 1
)
goto :eof

REM Build all services
:build_all
call :print_header "Building All Services"
call :check_docker
if errorlevel 1 exit /b 1
call :check_env
if errorlevel 1 exit /b 1

call :print_status "Building backend service..."
docker-compose build backend
if errorlevel 1 (
    call :print_error "Failed to build backend service"
    exit /b 1
)

call :print_status "Building Hedera service..."
docker-compose build hedera-service
if errorlevel 1 (
    call :print_error "Failed to build Hedera service"
    exit /b 1
)

call :print_status "All services built successfully!"
goto :eof

REM Start all services
:start_all
call :print_header "Starting All Services"
call :check_docker
if errorlevel 1 exit /b 1
call :check_env
if errorlevel 1 exit /b 1

call :print_status "Starting services..."
docker-compose up -d
if errorlevel 1 (
    call :print_error "Failed to start services"
    exit /b 1
)

call :print_status "Waiting for services to be healthy..."
timeout /t 10 /nobreak >nul

call :print_status "Checking service health..."
docker-compose ps

call :print_status "All services started successfully!"
call :print_status "Backend API: http://localhost/api/v1"
call :print_status "Hedera Service: http://localhost/hedera"
call :print_status "Database: localhost:5432"
goto :eof

REM Stop all services
:stop_all
call :print_header "Stopping All Services"
call :check_docker
if errorlevel 1 exit /b 1

call :print_status "Stopping services..."
docker-compose down

call :print_status "All services stopped successfully!"
goto :eof

REM Restart all services
:restart_all
call :print_header "Restarting All Services"
call :stop_all
call :start_all
goto :eof

REM View logs
:view_logs
call :print_header "Viewing Service Logs"
call :check_docker
if errorlevel 1 exit /b 1

if "%2"=="" (
    call :print_status "Showing logs for all services"
    docker-compose logs -f
) else (
    call :print_status "Showing logs for: %2"
    docker-compose logs -f %2
)
goto :eof

REM Execute command in container
:exec_command
if "%2"=="" (
    call :print_error "Usage: %0 exec ^<service^> ^<command^>"
    call :print_error "Example: %0 exec backend sh"
    exit /b 1
)

call :print_header "Executing Command in %2"
call :check_docker
if errorlevel 1 exit /b 1

call :print_status "Executing: %3"
docker-compose exec %2 %3
goto :eof

REM Database operations
:db_migrate
call :print_header "Running Database Migrations"
call :check_docker
if errorlevel 1 exit /b 1

call :print_status "Running Prisma migrations..."
docker-compose exec backend npx prisma migrate deploy
if errorlevel 1 (
    call :print_error "Failed to run migrations"
    exit /b 1
)

call :print_status "Generating Prisma client..."
docker-compose exec backend npx prisma generate
if errorlevel 1 (
    call :print_error "Failed to generate Prisma client"
    exit /b 1
)

call :print_status "Database migrations completed!"
goto :eof

:db_seed
call :print_header "Seeding Database"
call :check_docker
if errorlevel 1 exit /b 1

call :print_status "Running database seed..."
docker-compose exec backend npm run db:seed
if errorlevel 1 (
    call :print_error "Failed to seed database"
    exit /b 1
)

call :print_status "Database seeded successfully!"
goto :eof

:db_reset
call :print_header "Resetting Database"
call :check_docker
if errorlevel 1 exit /b 1

call :print_warning "This will delete all data in the database!"
set /p confirm="Are you sure? (y/N): "
if /i not "%confirm%"=="y" (
    call :print_status "Database reset cancelled."
    goto :eof
)

call :print_status "Stopping services..."
docker-compose down

call :print_status "Removing database volume..."
docker volume rm zauro_postgres_data 2>nul

call :print_status "Starting services..."
docker-compose up -d postgres

call :print_status "Waiting for database..."
timeout /t 10 /nobreak >nul

call :print_status "Running migrations..."
call :db_migrate

call :print_status "Database reset completed!"
goto :eof

REM Clean up Docker resources
:cleanup
call :print_header "Cleaning Up Docker Resources"
call :check_docker
if errorlevel 1 exit /b 1

call :print_status "Stopping all services..."
docker-compose down

call :print_status "Removing unused images..."
docker image prune -f

call :print_status "Removing unused volumes..."
docker volume prune -f

call :print_status "Removing unused networks..."
docker network prune -f

call :print_status "Cleanup completed!"
goto :eof

REM Show service status
:status
call :print_header "Service Status"
call :check_docker
if errorlevel 1 exit /b 1

call :print_status "Docker Compose Services:"
docker-compose ps

echo.
call :print_status "Docker System Info:"
docker system df

echo.
call :print_status "Service Health Checks:"

REM Check backend health
curl -f http://localhost/api/v1/health >nul 2>&1
if errorlevel 1 (
    call :print_error "✗ Backend API is not responding"
) else (
    call :print_status "✓ Backend API is healthy"
)

REM Check Hedera health
curl -f http://localhost/hedera/collection-status >nul 2>&1
if errorlevel 1 (
    call :print_error "✗ Hedera service is not responding"
) else (
    call :print_status "✓ Hedera service is healthy"
)
goto :eof

REM Production deployment
:deploy_prod
call :print_header "Production Deployment"
call :check_docker
if errorlevel 1 exit /b 1
call :check_env
if errorlevel 1 exit /b 1

call :print_warning "This will deploy to production. Make sure you have:"
call :print_warning "1. Configured production environment variables"
call :print_warning "2. SSL certificates in ./ssl/ directory"
call :print_warning "3. Updated domain name in nginx-prod.conf"

set /p confirm="Continue with production deployment? (y/N): "
if /i not "%confirm%"=="y" (
    call :print_status "Production deployment cancelled."
    goto :eof
)

call :print_status "Building production images..."
docker-compose -f docker-compose.prod.yml build
if errorlevel 1 (
    call :print_error "Failed to build production images"
    exit /b 1
)

call :print_status "Starting production services..."
docker-compose -f docker-compose.prod.yml up -d
if errorlevel 1 (
    call :print_error "Failed to start production services"
    exit /b 1
)

call :print_status "Running database migrations..."
docker-compose -f docker-compose.prod.yml exec backend npx prisma migrate deploy
if errorlevel 1 (
    call :print_error "Failed to run migrations"
    exit /b 1
)

call :print_status "Production deployment completed!"
goto :eof

REM Show help
:show_help
echo Zauro Marketplace Docker Management Script
echo.
echo Usage: %0 ^<command^> [options]
echo.
echo Commands:
echo   build              Build all services
echo   start              Start all services
echo   stop               Stop all services
echo   restart            Restart all services
echo   logs [service]      View logs (optionally for specific service)
echo   exec ^<service^> ^<cmd^> Execute command in service container
echo   db-migrate         Run database migrations
echo   db-seed            Seed the database
echo   db-reset           Reset the database (DESTRUCTIVE)
echo   cleanup            Clean up Docker resources
echo   status             Show service status
echo   deploy-prod        Deploy to production
echo   help               Show this help message
echo.
echo Examples:
echo   %0 start
echo   %0 logs backend
echo   %0 exec backend sh
echo   %0 db-migrate
goto :eof

REM Main script logic
if "%1"=="build" call :build_all
if "%1"=="start" call :start_all
if "%1"=="stop" call :stop_all
if "%1"=="restart" call :restart_all
if "%1"=="logs" call :view_logs %2
if "%1"=="exec" call :exec_command %2 %3
if "%1"=="db-migrate" call :db_migrate
if "%1"=="db-seed" call :db_seed
if "%1"=="db-reset" call :db_reset
if "%1"=="cleanup" call :cleanup
if "%1"=="status" call :status
if "%1"=="deploy-prod" call :deploy_prod
if "%1"=="help" call :show_help
if "%1"=="--help" call :show_help
if "%1"=="-h" call :show_help

if "%1"=="" (
    call :print_error "No command specified"
    echo.
    call :show_help
    exit /b 1
)

REM Check if command was not found
if "%1" neq "build" if "%1" neq "start" if "%1" neq "stop" if "%1" neq "restart" if "%1" neq "logs" if "%1" neq "exec" if "%1" neq "db-migrate" if "%1" neq "db-seed" if "%1" neq "db-reset" if "%1" neq "cleanup" if "%1" neq "status" if "%1" neq "deploy-prod" if "%1" neq "help" if "%1" neq "--help" if "%1" neq "-h" (
    call :print_error "Unknown command: %1"
    echo.
    call :show_help
    exit /b 1
)
