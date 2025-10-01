# Troubleshooting Guide

This guide covers common issues that might occur during Laravel Starter deployment and their solutions.

## Quick Diagnostics

Run this command to get an overview of your system status:
```bash
curl -sSL https://raw.githubusercontent.com/agungferdi/azure-ubuntu-deployment/main/scripts/fix-common-issues.sh | bash
```

## Common Issues

### 1. "Class 'Faker\Factory' not found" Error

**Cause:** Missing Faker dependency for database seeding.

**Solution:**
```bash
cd /var/www/laravel-starter
sudo -u www-data composer require fakerphp/faker --dev
sudo -u www-data php artisan db:seed --force
```

### 2. Database Connection Issues

**Symptoms:**
- "Access denied for user" errors
- "Unknown database" errors
- Laravel showing database connection errors

**Solution:**
```bash
# Check database credentials in .env file
sudo nano /var/www/laravel-starter/.env

# Ensure these values are set:
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=laravel_starter
DB_USERNAME=laravel_user
DB_PASSWORD=Laravel@123

# Test database connection
mysql -u laravel_user -pLaravel@123 laravel_starter -e "SELECT 1;"
```

### 3. Permission Issues

**Symptoms:**
- "Permission denied" errors
- Laravel showing "UnexpectedValueException" errors
- Unable to write to storage directories

**Solution:**
```bash
sudo chown -R www-data:www-data /var/www/laravel-starter
sudo chmod -R 755 /var/www/laravel-starter
sudo chmod -R 777 /var/www/laravel-starter/storage
sudo chmod -R 777 /var/www/laravel-starter/bootstrap/cache
```

### 4. Nginx 502 Bad Gateway

**Symptoms:**
- Nginx shows "502 Bad Gateway" error
- Laravel application not loading

**Solution:**
```bash
# Check PHP-FPM status
sudo systemctl status php8.2-fpm

# Restart PHP-FPM
sudo systemctl restart php8.2-fpm

# Check Nginx configuration
sudo nginx -t
sudo systemctl restart nginx
```

### 5. NPM Build Failures

**Symptoms:**
- "npm run build" command fails
- Frontend assets not compiling

**Solution:**
```bash
cd /var/www/laravel-starter

# Clear NPM cache
sudo -u www-data npm cache clean --force

# Remove node_modules and reinstall
sudo rm -rf node_modules package-lock.json
sudo -u www-data npm install
sudo -u www-data npm run build
```

### 6. Firewall Blocking Access

**Symptoms:**
- Cannot access application from external IP
- Connection timeout when accessing VM

**Solution:**
```bash
# Enable firewall and allow HTTP traffic
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 'Nginx Full'

# Check firewall status
sudo ufw status verbose

# Check if ports are listening
sudo netstat -tlnp | grep :80
```

### 7. PHP Version Issues

**Symptoms:**
- "This package requires php ^8.2" errors
- Composer dependency conflicts

**Solution:**
```bash
# Check current PHP version
php --version

# If not PHP 8.2, run the migration script
sudo bash /path/to/php-migration.sh
```

### 8. Missing PHP Extensions

**Symptoms:**
- "extension not found" errors
- Laravel showing missing extension errors

**Solution:**
```bash
# Install common PHP extensions
sudo apt-get update
sudo apt-get install -y php8.2-cli php8.2-fpm php8.2-mysql php8.2-xml php8.2-curl php8.2-mbstring php8.2-zip php8.2-sqlite3

# Restart PHP-FPM
sudo systemctl restart php8.2-fpm
```

## Service Management

### Check All Services
```bash
sudo systemctl status nginx
sudo systemctl status php8.2-fpm
sudo systemctl status mariadb
```

### Restart All Services
```bash
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
sudo systemctl restart mariadb
```

### View Service Logs
```bash
# Nginx logs
sudo tail -f /var/log/nginx/error.log

# PHP-FPM logs
sudo tail -f /var/log/php8.2-fpm.log

# Laravel logs
sudo tail -f /var/www/laravel-starter/storage/logs/laravel.log
```

## Laravel-Specific Commands

### Clear Cache
```bash
cd /var/www/laravel-starter
sudo -u www-data php artisan cache:clear
sudo -u www-data php artisan config:clear
sudo -u www-data php artisan route:clear
sudo -u www-data php artisan view:clear
```

### Regenerate App Key
```bash
cd /var/www/laravel-starter
sudo -u www-data php artisan key:generate
```

### Database Operations
```bash
cd /var/www/laravel-starter

# Fresh migration (WARNING: This will delete all data)
sudo -u www-data php artisan migrate:fresh --seed

# Just run new migrations
sudo -u www-data php artisan migrate

# Seed database
sudo -u www-data php artisan db:seed
```

## System Information

### Check System Resources
```bash
# Memory usage
free -h

# Disk usage
df -h

# CPU usage
top -n1 | head -20
```

### Network Diagnostics
```bash
# Check if ports are open
sudo netstat -tlnp | grep -E ':80|:443|:22'

# Test external connectivity
curl -I http://localhost/
curl -I https://google.com
```

## Environment Verification

### PHP Environment
```bash
# Check PHP configuration
php -i | grep -E 'memory_limit|max_execution_time|upload_max_filesize'

# Check loaded extensions
php -m | grep -E 'mysql|curl|zip|xml'
```

### Composer Environment
```bash
# Check Composer version
composer --version

# Verify Composer dependencies
cd /var/www/laravel-starter
composer diagnose
```

### Node.js Environment
```bash
# Check Node.js and NPM versions
node --version
npm --version

# Check global packages
npm list -g --depth=0
```

## Getting Help

If you're still experiencing issues:

1. **Check the main logs:**
   ```bash
   sudo tail -f /var/log/nginx/error.log &
   sudo tail -f /var/log/php8.2-fpm.log &
   sudo tail -f /var/www/laravel-starter/storage/logs/laravel.log
   ```

2. **Run the automated fix script:**
   ```bash
   bash /path/to/scripts/fix-common-issues.sh
   ```

3. **Contact support** with the following information:
   - Operating system version: `lsb_release -a`
   - PHP version: `php --version`
   - Nginx version: `nginx -v`
   - Database version: `mysql --version`
   - Error logs from the commands above

## Prevention Tips

1. **Always backup before making changes**
2. **Test changes in a staging environment first**
3. **Keep your system updated:** `sudo apt-get update && sudo apt-get upgrade`
4. **Monitor disk space:** `df -h`
5. **Regular log rotation** is configured automatically
6. **Use version control** for your Laravel application changes