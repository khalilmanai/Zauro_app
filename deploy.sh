#!/bin/bash

# Zauro Platform Deployment Script
# This script helps deploy your Zauro platform to various free hosting providers

set -e

echo "🚀 Zauro Platform Deployment Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if required tools are installed
check_requirements() {
    print_info "Checking requirements..."
    
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_warning "Docker is not installed. Some deployment options may not work."
    fi
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 18+ first."
        exit 1
    fi
    
    print_status "Requirements check completed"
}

# Prepare for deployment
prepare_deployment() {
    print_info "Preparing for deployment..."
    
    # Check if .env file exists
    if [ ! -f .env ]; then
        print_warning ".env file not found. Creating from env.example..."
        if [ -f env.example ]; then
            cp env.example .env
            print_warning "Please update .env file with your actual values before deploying!"
        else
            print_error "env.example file not found. Please create a .env file manually."
            exit 1
        fi
    fi
    
    # Check if git repository is initialized
    if [ ! -d .git ]; then
        print_info "Initializing Git repository..."
        git init
        git add .
        git commit -m "Initial commit - ready for deployment"
    fi
    
    print_status "Deployment preparation completed"
}

# Deploy to Railway
deploy_railway() {
    print_info "Deploying to Railway..."
    
    # Check if Railway CLI is installed
    if ! command -v railway &> /dev/null; then
        print_info "Installing Railway CLI..."
        npm install -g @railway/cli
    fi
    
    # Login to Railway
    print_info "Please login to Railway..."
    railway login
    
    # Create new project
    print_info "Creating Railway project..."
    railway init
    
    # Add environment variables
    print_info "Adding environment variables..."
    railway variables set NODE_ENV=production
    railway variables set PORT=3000
    
    # Deploy
    print_info "Deploying to Railway..."
    railway up
    
    print_status "Railway deployment completed!"
    print_info "Your app will be available at: https://your-app-name.railway.app"
}

# Deploy to Render
deploy_render() {
    print_info "Deploying to Render..."
    
    print_info "Please follow these steps:"
    echo "1. Go to https://render.com"
    echo "2. Sign up with GitHub"
    echo "3. Create a new Web Service"
    echo "4. Connect your GitHub repository"
    echo "5. Configure:"
    echo "   - Build Command: npm install && npx prisma generate && npm run build"
    echo "   - Start Command: node dist/main.js"
    echo "   - Environment: Node"
    echo "6. Add PostgreSQL database service"
    echo "7. Set environment variables"
    echo "8. Deploy!"
    
    print_status "Render deployment instructions provided!"
}

# Deploy to Docker Hub
deploy_dockerhub() {
    print_info "Building and pushing to Docker Hub..."
    
    # Check if user is logged in to Docker Hub
    if ! docker info &> /dev/null; then
        print_error "Docker is not running or you're not logged in to Docker Hub"
        print_info "Please run: docker login"
        exit 1
    fi
    
    # Get Docker Hub username
    read -p "Enter your Docker Hub username: " DOCKER_USERNAME
    
    # Build and push backend image
    print_info "Building backend image..."
    docker build -f Dockerfile.production -t $DOCKER_USERNAME/zauro-backend:latest .
    
    print_info "Pushing backend image to Docker Hub..."
    docker push $DOCKER_USERNAME/zauro-backend:latest
    
    print_status "Docker Hub deployment completed!"
    print_info "Your image is available at: docker.io/$DOCKER_USERNAME/zauro-backend:latest"
}

# Deploy to VPS
deploy_vps() {
    print_info "VPS Deployment Instructions..."
    
    print_info "Please follow these steps:"
    echo "1. Get a free VPS from:"
    echo "   - Oracle Cloud (Always Free)"
    echo "   - Google Cloud Platform (Free Tier)"
    echo "   - AWS Free Tier"
    echo ""
    echo "2. SSH into your VPS:"
    echo "   ssh user@your-vps-ip"
    echo ""
    echo "3. Install Docker:"
    echo "   sudo apt update"
    echo "   sudo apt install docker.io docker-compose -y"
    echo ""
    echo "4. Clone your repository:"
    echo "   git clone https://github.com/yourusername/zauro-app.git"
    echo "   cd zauro-app"
    echo ""
    echo "5. Set environment variables:"
    echo "   cp env.example .env"
    echo "   nano .env  # Edit with your values"
    echo ""
    echo "6. Deploy:"
    echo "   docker-compose -f docker-compose.production.yml up -d"
    echo ""
    echo "7. Set up reverse proxy (nginx) for HTTPS"
    
    print_status "VPS deployment instructions provided!"
}

# Main menu
show_menu() {
    echo ""
    echo "Select deployment option:"
    echo "1) Railway (Recommended - Easiest)"
    echo "2) Render (Free tier with sleep mode)"
    echo "3) Docker Hub (For VPS deployment)"
    echo "4) VPS Instructions (Oracle Cloud, GCP, AWS)"
    echo "5) Exit"
    echo ""
    read -p "Enter your choice (1-5): " choice
}

# Main execution
main() {
    check_requirements
    prepare_deployment
    
    while true; do
        show_menu
        case $choice in
            1)
                deploy_railway
                break
                ;;
            2)
                deploy_render
                break
                ;;
            3)
                deploy_dockerhub
                break
                ;;
            4)
                deploy_vps
                break
                ;;
            5)
                print_info "Exiting deployment script..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
    done
    
    echo ""
    print_status "Deployment process completed!"
    print_info "Don't forget to:"
    echo "  - Set up your environment variables"
    echo "  - Configure your Hedera account"
    echo "  - Set up monitoring and backups"
    echo "  - Test your deployed application"
    echo ""
    print_info "Happy deploying! 🚀"
}

# Run main function
main "$@"
