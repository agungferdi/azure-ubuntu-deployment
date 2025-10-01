#!/bin/bash

#############################################
# Common Issues Fix Script
# Fixes common deployment issues encountered
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

APP_DIR="/var/www/laravel-starter"

# Fix database configuration issues
fix_database_config() {
    log "Fixing database configuration..."
    
    if [ -d "$APP_DIR" ]; then
        cd $APP_DIR
        
        # Ensure proper database configuration
        sudo -u www-data sed -i 's/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/' .env
        sudo -u www-data sed -i 's/DB_HOST=127.0.0.1/DB_HOST=localhost/' .env
        sudo -u www-data sed -i 's/DB_USERNAME=root/DB_USERNAME=laravel_user/' .env
        sudo -u www-data sed -i 's/DB_PASSWORD=/DB_PASSWORD=Laravel@123/' .env
        
        # Add missing database config if not present
        if ! grep -q "DB_CONNECTION=" .env; then
            echo "DB_CONNECTION=mysql" | sudo -u www-data tee -a .env
        fi
        if ! grep -q "DB_DATABASE=" .env; then
            echo "DB_DATABASE=laravel_starter" | sudo -u www-data tee -a .env
        fi
        
        log "Database configuration fixed"
    else
        error "Laravel application directory not found"
    fi
}

# Install missing Faker dependency
install_faker() {
    log "Installing Faker dependency..."
    
    if [ -d "$APP_DIR" ]; then
        cd $APP_DIR
        sudo -u www-data composer require fakerphp/faker --dev
        log "Faker dependency installed"
    else
        error "Laravel application directory not found"
    fi
}

# Fix Nginx configuration
fix_nginx_config() {
    log "Fixing Nginx configuration..."
    
    # Create Laravel site configuration if missing
    if [ ! -f "/etc/nginx/sites-available/laravel-starter" ]; then
        sudo tee /etc/nginx/sites-available/laravel-starter > /dev/null <<EOF
server {
    listen 80;
    server_name _;
    root $APP_DIR/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
        log "Laravel Nginx configuration created"
    fi
    
    # Remove default site and enable Laravel
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo ln -sf /etc/nginx/sites-available/laravel-starter /etc/nginx/sites-enabled/
    
    # Test and restart Nginx
    sudo nginx -t && sudo systemctl restart nginx
    
    log "Nginx configuration fixed"
}

# Fix firewall settings
fix_firewall() {
    log "Fixing firewall settings..."
    
    # Enable firewall and allow necessary ports
    sudo ufw --force enable
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    sudo ufw allow 'Nginx Full'
    
    log "Firewall configured"
    sudo ufw status verbose
}

# Fix Laravel permissions
fix_permissions() {
    log "Fixing Laravel permissions..."
    
    if [ -d "$APP_DIR" ]; then
        sudo chown -R www-data:www-data $APP_DIR
        sudo chmod -R 755 $APP_DIR
        sudo chmod -R 777 $APP_DIR/storage
        sudo chmod -R 777 $APP_DIR/bootstrap/cache
        
        log "Laravel permissions fixed"
    else
        error "Laravel application directory not found"
    fi
}

# Run database migrations and seeding
fix_database() {
    log "Running database migrations and seeding..."
    
    if [ -d "$APP_DIR" ]; then
        cd $APP_DIR
        
        # Test database connection
        if mysql -u laravel_user -pLaravel@123 laravel_starter -e "SELECT 1;" > /dev/null 2>&1; then
            # Run migrations and seeding
            sudo -u www-data php artisan migrate --force
            sudo -u www-data php artisan db:seed --force
            
            log "Database setup completed"
        else
            error "Database connection failed. Please check database configuration."
        fi
    else
        error "Laravel application directory not found"
    fi
}

# Check services status
check_services() {
    log "Checking services status..."
    
    echo "=== Service Status ==="
    sudo systemctl status nginx --no-pager -l || true
    sudo systemctl status php8.2-fpm --no-pager -l || true
    sudo systemctl status mariadb --no-pager -l || true
    
    echo ""
    echo "=== Port Status ==="
    sudo netstat -tlnp | grep :80 || true
    
    echo ""
    echo "=== Laravel Test ==="
    curl -I http://localhost/ || true
}

# Main function
main() {
    log "Starting common issues fix..."
    
    echo ""
    echo "Available fixes:"
    echo "1. Fix database configuration"
    echo "2. Install Faker dependency"
    echo "3. Fix Nginx configuration"
    echo "4. Fix firewall settings"
    echo "5. Fix Laravel permissions"
    echo "6. Fix database (migrate & seed)"
    echo "7. Check services status"
    echo "8. Fix all issues"
    echo ""
    
    read -p "Choose an option (1-8): " choice
    
    case $choice in
        1)
            fix_database_config
            ;;
        2)
            install_faker
            ;;
        3)
            fix_nginx_config
            ;;
        4)
            fix_firewall
            ;;
        5)
            fix_permissions
            ;;
        6)
            fix_database
            ;;
        7)
            check_services
            ;;
        8)
            fix_database_config
            install_faker
            fix_nginx_config
            fix_firewall
            fix_permissions
            fix_database
            check_services
            ;;
        *)
            error "Invalid option"
            ;;
    esac
    
    log "Fix completed! Your Laravel application should now be working."
    info "Access your application at: http://$(curl -s -4 icanhazip.com)"
    info "Admin credentials: super@admin.com / secret"
}

main "$@"