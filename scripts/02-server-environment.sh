#!/bin/bash

#############################################
# Server Environment Setup Script
# Installs PHP 8.1, Nginx, MariaDB, Composer, NPM
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

# Install PHP 8.2
install_php() {
    log "Installing PHP 8.2 and extensions..."
    
    # Add PHP repository
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update
    
    # Install PHP 8.2 and common extensions
    sudo apt install -y \
        php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-xml \
        php8.2-curl \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-zip \
        php8.2-intl \
        php8.2-bcmath \
        php8.2-soap \
        php8.2-redis \
        php8.2-cli \
        php8.2-common \
        php8.2-opcache \
        php8.2-readline \
        php8.2-sqlite3
    
    # Configure PHP-FPM
    sudo systemctl enable php8.2-fpm
    sudo systemctl start php8.2-fpm
    
    log "PHP 8.2 installation completed"
    php -v
}

# Install Nginx
install_nginx() {
    log "Installing Nginx..."
    
    sudo apt install -y nginx
    
    # Enable and start Nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    
    # Allow Nginx through firewall
    sudo ufw allow 'Nginx Full' 2>/dev/null || true
    
    log "Nginx installation completed"
    nginx -v
}

# Install MariaDB
install_mariadb() {
    log "Installing MariaDB 10..."
    
    sudo apt install -y mariadb-server mariadb-client
    
    # Enable and start MariaDB
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
    
    log "MariaDB installation completed"
    
    # Secure MariaDB installation
    log "Securing MariaDB installation..."
    sudo mysql_secure_installation <<EOF

y
n
y
y
y
y
EOF
    
    # Create database and user for Laravel
    log "Creating database and user for Laravel..."
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS laravel_starter;"
    sudo mysql -e "CREATE USER IF NOT EXISTS 'laravel_user'@'localhost' IDENTIFIED BY 'Laravel@123';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON laravel_starter.* TO 'laravel_user'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"
    
    info "Database: laravel_starter"
    info "Username: laravel_user"
    info "Password: Laravel@123"
}

# Install Composer
install_composer() {
    log "Installing Composer 2.2..."
    
    # Download and install Composer
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
    
    log "Composer installation completed"
    composer --version
}

# Install Node.js and NPM
install_nodejs() {
    log "Installing Node.js 18.x and NPM..."
    
    # Add NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    
    # Install Node.js
    sudo apt install -y nodejs
    
    log "Node.js and NPM installation completed"
    node -v
    npm -v
}

# Configure PHP settings for Laravel
configure_php() {
    log "Configuring PHP settings for Laravel..."
    
    # Update PHP configuration
    sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' /etc/php/8.2/fpm/php.ini
    sudo sed -i 's/post_max_size = .*/post_max_size = 100M/' /etc/php/8.2/fpm/php.ini
    sudo sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php/8.2/fpm/php.ini
    sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/8.2/fpm/php.ini
    
    # Restart PHP-FPM
    sudo systemctl restart php8.2-fpm
    
    log "PHP configuration updated"
}

# Main function
main() {
    log "Starting server environment setup..."
    
    install_php
    install_nginx
    install_mariadb
    install_composer
    install_nodejs
    configure_php
    
    log "Server environment setup completed successfully!"
    
    info "Installed versions:"
    echo "PHP: $(php -v | head -n1)"
    echo "Nginx: $(nginx -v 2>&1)"
    echo "MariaDB: $(mysql --version)"
    echo "Composer: $(composer --version)"
    echo "Node.js: $(node -v)"
    echo "NPM: $(npm -v)"
}

main "$@"