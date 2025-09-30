#!/bin/bash

#############################################
# Laravel Application Deployment Script
# Clones, configures and deploys Laravel Starter
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

# Configuration variables
APP_DIR="/var/www/laravel-starter"
REPO_URL="https://github.com/nasirkhan/laravel-starter.git"
DB_NAME="laravel_starter"
DB_USER="laravel_user"
DB_PASS="Laravel@123"

# Clone Laravel Starter repository
clone_repository() {
    log "Cloning Laravel Starter repository..."
    
    # Remove existing directory if it exists
    sudo rm -rf $APP_DIR
    
    # Clone the repository
    sudo git clone $REPO_URL $APP_DIR
    
    # Set ownership to www-data
    sudo chown -R www-data:www-data $APP_DIR
    sudo chmod -R 755 $APP_DIR
    
    log "Repository cloned successfully"
}

# Install PHP dependencies
install_dependencies() {
    log "Installing PHP dependencies with Composer..."
    
    cd $APP_DIR
    sudo -u www-data composer install --no-dev --optimize-autoloader
    
    log "Installing NPM dependencies..."
    sudo -u www-data npm install
    
    log "Building frontend assets..."
    sudo -u www-data npm run production
    
    log "Dependencies installed successfully"
}

# Configure Laravel environment
configure_laravel() {
    log "Configuring Laravel environment..."
    
    cd $APP_DIR
    
    # Copy environment file
    sudo -u www-data cp .env.example .env
    
    # Update .env file with database configuration
    sudo -u www-data sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
    sudo -u www-data sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
    sudo -u www-data sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env
    
    # Set application URL (you may need to update this with your actual IP)
    sudo -u www-data sed -i "s|APP_URL=.*|APP_URL=http://$(hostname -I | awk '{print $1}')|" .env
    
    # Generate application key
    sudo -u www-data php artisan key:generate
    
    # Set proper permissions
    sudo chown -R www-data:www-data $APP_DIR
    sudo chmod -R 755 $APP_DIR
    sudo chmod -R 777 $APP_DIR/storage
    sudo chmod -R 777 $APP_DIR/bootstrap/cache
    
    log "Laravel environment configured"
}

# Setup database
setup_database() {
    log "Setting up database..."
    
    cd $APP_DIR
    
    # Run migrations
    sudo -u www-data php artisan migrate --force
    
    # Seed database
    sudo -u www-data php artisan db:seed --force
    
    log "Database setup completed"
}

# Configure Nginx
configure_nginx() {
    log "Configuring Nginx for Laravel..."
    
    # Create Nginx site configuration
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

    # Enable the site
    sudo ln -sf /etc/nginx/sites-available/laravel-starter /etc/nginx/sites-enabled/
    
    # Remove default site
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test Nginx configuration
    sudo nginx -t
    
    # Restart Nginx
    sudo systemctl restart nginx
    
    log "Nginx configured successfully"
}

# Setup Laravel scheduler (optional)
setup_scheduler() {
    log "Setting up Laravel scheduler..."
    
    # Add cron job for Laravel scheduler
    (sudo crontab -l 2>/dev/null; echo "* * * * * cd $APP_DIR && php artisan schedule:run >> /dev/null 2>&1") | sudo crontab -
    
    log "Laravel scheduler configured"
}

# Display application information
display_info() {
    log "Laravel Starter deployment completed!"
    
    echo ""
    echo "========================================="
    echo "         APPLICATION INFORMATION"
    echo "========================================="
    echo "Application URL: http://$(hostname -I | awk '{print $1}')"
    echo "Application Path: $APP_DIR"
    echo ""
    echo "Default Admin Credentials:"
    echo "Email: super@admin.com"
    echo "Password: secret"
    echo ""
    echo "Database Information:"
    echo "Database: $DB_NAME"
    echo "Username: $DB_USER"
    echo "Password: $DB_PASS"
    echo ""
    echo "To access the application:"
    echo "1. Open your browser"
    echo "2. Navigate to http://$(hostname -I | awk '{print $1}')"
    echo "3. Login with the admin credentials above"
    echo ""
    echo "Available features to test:"
    echo "- User registration: /register"
    echo "- User login: /login"
    echo "- Posts, categories, tags & comments"
    echo "- Password reset (configure email first)"
    echo "========================================="
}

# Main function
main() {
    log "Starting Laravel application deployment..."
    
    clone_repository
    install_dependencies
    configure_laravel
    setup_database
    configure_nginx
    setup_scheduler
    display_info
    
    log "Deployment completed successfully!"
}

main "$@"