#!/bin/bash

#############################################
# PHP Migration Script - Upgrade from 8.1 to 8.2
# Use this if you already have PHP 8.1 installed
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

# Check if PHP 8.1 is installed
check_php81() {
    if dpkg -l | grep -q php8.1; then
        log "PHP 8.1 detected. Starting migration to PHP 8.2..."
        return 0
    else
        info "PHP 8.1 not found. You can proceed with fresh installation."
        return 1
    fi
}

# Install PHP 8.2
install_php82() {
    log "Installing PHP 8.2 and extensions..."
    
    # Add PHP repository (if not already added)
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
        php8.2-readline
    
    # Configure PHP-FPM
    sudo systemctl enable php8.2-fpm
    sudo systemctl start php8.2-fpm
    
    log "PHP 8.2 installation completed"
}

# Update Nginx configuration
update_nginx_config() {
    log "Updating Nginx configuration to use PHP 8.2..."
    
    # Check if Laravel Starter site configuration exists
    if [ -f "/etc/nginx/sites-available/laravel-starter" ]; then
        # Update the PHP-FPM socket path
        sudo sed -i 's|fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;|fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;|g' /etc/nginx/sites-available/laravel-starter
        
        # Test Nginx configuration
        sudo nginx -t
        
        # Restart Nginx
        sudo systemctl restart nginx
        
        log "Nginx configuration updated successfully"
    else
        warning "Laravel Starter Nginx configuration not found. Manual configuration may be needed."
    fi
}

# Disable PHP 8.1 services (optional)
disable_php81() {
    log "Disabling PHP 8.1 services..."
    
    # Stop and disable PHP 8.1 FPM
    sudo systemctl stop php8.1-fpm 2>/dev/null || true
    sudo systemctl disable php8.1-fpm 2>/dev/null || true
    
    log "PHP 8.1 services disabled"
}

# Update alternatives to use PHP 8.2 as default
update_php_alternatives() {
    log "Setting PHP 8.2 as default..."
    
    # Update alternatives for php command
    sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.2 82
    sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.1 81 2>/dev/null || true
    
    # Set PHP 8.2 as default
    sudo update-alternatives --set php /usr/bin/php8.2
    
    log "PHP 8.2 set as default"
    php -v
}

# Test Laravel application
test_laravel() {
    log "Testing Laravel application..."
    
    if [ -d "/var/www/laravel-starter" ]; then
        cd /var/www/laravel-starter
        
        # Clear Laravel caches
        sudo -u www-data php artisan cache:clear
        sudo -u www-data php artisan config:clear
        sudo -u www-data php artisan route:clear
        
        log "Laravel application tested successfully"
        info "Application should be accessible at your VM IP address"
    else
        warning "Laravel application not found. You may need to deploy it first."
    fi
}

# Display migration summary
display_summary() {
    echo ""
    echo "========================================="
    echo "         MIGRATION COMPLETED"
    echo "========================================="
    echo "✅ PHP 8.2 installed and configured"
    echo "✅ Nginx updated to use PHP 8.2"
    echo "✅ PHP 8.1 services disabled"
    echo "✅ PHP 8.2 set as default"
    echo ""
    echo "Current PHP version:"
    php -v | head -n1
    echo ""
    echo "Service status:"
    sudo systemctl is-active php8.2-fpm nginx mariadb
    echo ""
    echo "If you encounter any issues:"
    echo "1. Check service logs: sudo journalctl -u php8.2-fpm -f"
    echo "2. Test Nginx config: sudo nginx -t"
    echo "3. Restart services: sudo systemctl restart nginx php8.2-fpm"
    echo "========================================="
}

# Main function
main() {
    log "Starting PHP 8.1 to 8.2 migration..."
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        error "Please don't run this script as root. Use a regular user with sudo privileges."
    fi
    
    if check_php81; then
        install_php82
        update_nginx_config
        disable_php81
        update_php_alternatives
        test_laravel
        display_summary
    else
        info "Fresh installation detected. Run the main setup script instead: ./setup.sh"
    fi
    
    log "Migration completed successfully!"
}

main "$@"