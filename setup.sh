#!/bin/bash

#############################################
# Ubuntu VM Setup Script for Laravel Deployment
# This script automates server environment setup
# and Laravel application deployment
#############################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        error "Please don't run this script as root. Use a regular user with sudo privileges."
    fi
}

# Main setup function
main() {
    log "Starting Ubuntu VM Setup for Laravel Deployment"
    
    check_root
    
    # Make all scripts executable
    chmod +x scripts/*.sh
    
    # Step 1: Basic system setup
    log "Step 1: Setting up basic system configuration..."
    ./scripts/01-system-setup.sh
    
    # Step 2: Install server environment
    log "Step 2: Installing server environment (PHP, Nginx, MariaDB, etc.)..."
    ./scripts/02-server-environment.sh
    
    # Step 3: Deploy Laravel application
    log "Step 3: Deploying Laravel application..."
    ./scripts/03-laravel-deployment.sh
    
    # Step 4: Configure email settings
    log "Step 4: Configuring email settings..."
    ./scripts/04-email-config.sh
    
    log "Setup completed successfully!"
    info "Your Laravel application should now be accessible at: http://your-vm-ip"
    info "Default admin credentials will be displayed in the Laravel deployment output"
    info "Please check the README.md for additional configuration steps"
}

# Check if scripts directory exists
if [ ! -d "scripts" ]; then
    error "Scripts directory not found. Please run this from the project root directory."
fi

# Run main function
main "$@"