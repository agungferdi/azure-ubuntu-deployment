#!/bin/bash

#############################################
# System Setup Script
# Sets timezone, updates system, installs basic tools
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Set timezone to Asia/Jakarta
setup_timezone() {
    log "Setting timezone to Asia/Jakarta..."
    sudo timedatectl set-timezone Asia/Jakarta
    info "Current time: $(date)"
}

# Update and upgrade system
update_system() {
    log "Updating and upgrading system packages..."
    sudo apt update
    sudo apt upgrade -y
    log "System update completed"
}

# Install basic development tools
install_basic_tools() {
    log "Installing basic development tools..."
    
    # Install essential packages
    sudo apt install -y \
        curl \
        zip \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        python3 \
        python3-pip \
        build-essential \
        wget \
        vim \
        htop
    
    log "Basic tools installation completed"
}

# Install Docker
install_docker() {
    log "Installing Docker..."
    
    # Remove old Docker installations
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up the stable repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index
    sudo apt update
    
    # Install Docker Engine
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    # Enable and start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker
    
    log "Docker installation completed"
    info "You may need to log out and back in for Docker group membership to take effect"
}

# Main function
main() {
    log "Starting system setup..."
    
    setup_timezone
    update_system
    install_basic_tools
    install_docker
    
    log "System setup completed successfully!"
    info "Please run 'newgrp docker' or log out and back in to use Docker without sudo"
}

main "$@"