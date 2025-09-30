# Troubleshooting Guide

This guide helps you diagnose and fix common issues that may occur during or after the automated setup.

## 🔍 System Diagnostics

### Check All Services Status
```bash
# Check all critical services
sudo systemctl status nginx php8.1-fpm mariadb

# Check if services are enabled (start on boot)
sudo systemctl is-enabled nginx php8.1-fpm mariadb
```

### Check Port Usage
```bash
# Check what's running on web ports
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Check MySQL port
sudo netstat -tlnp | grep :3306
```

### Check Disk Space
```bash
# Check available disk space
df -h

# Check specific directories
du -sh /var/www/laravel-starter
du -sh /var/log
```

## ⚠️ Common Issues and Solutions

### 1. Script Execution Issues

**Error**: `Permission denied`
```bash
# Make scripts executable
chmod +x setup.sh
chmod +x scripts/*.sh
```

**Error**: `Script not found`
```bash
# Ensure you're in the correct directory
pwd
ls -la setup.sh
```

### 2. System Setup Issues

**Error**: `Unable to locate package`
```bash
# Update package lists
sudo apt update

# If still failing, check Ubuntu version
lsb_release -a
```

**Error**: Docker permission denied
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group membership (logout/login or use)
newgrp docker

# Test docker
docker --version
```

### 3. PHP Issues

**Error**: `PHP-FPM not starting`
```bash
# Check PHP-FPM configuration
sudo php-fpm8.1 -t

# Check logs
sudo journalctl -u php8.1-fpm -f

# Restart service
sudo systemctl restart php8.1-fpm
```

**Error**: `PHP extensions missing`
```bash
# Check installed extensions
php -m | grep -E "(mysql|curl|gd|mbstring)"

# Reinstall extensions if needed
sudo apt install php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring
```

### 4. Nginx Issues

**Error**: `Nginx 502 Bad Gateway`
```bash
# Check PHP-FPM socket
ls -la /var/run/php/php8.1-fpm.sock

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Test Nginx configuration
sudo nginx -t

# Restart both services
sudo systemctl restart php8.1-fpm nginx
```

**Error**: `Nginx won't start`
```bash
# Check configuration syntax
sudo nginx -t

# Check what's using port 80
sudo lsof -i :80

# Check detailed logs
sudo journalctl -u nginx -f
```

### 5. Database Issues

**Error**: `Database connection refused`
```bash
# Check MariaDB status
sudo systemctl status mariadb

# Start MariaDB if stopped
sudo systemctl start mariadb

# Check MariaDB logs
sudo tail -f /var/log/mysql/error.log
```

**Error**: `Access denied for user`
```bash
# Reset database permissions
sudo mysql -e "DROP USER IF EXISTS 'laravel_user'@'localhost';"
sudo mysql -e "CREATE USER 'laravel_user'@'localhost' IDENTIFIED BY 'Laravel@123';"
sudo mysql -e "GRANT ALL PRIVILEGES ON laravel_starter.* TO 'laravel_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

**Error**: `Database doesn't exist`
```bash
# Recreate database
sudo mysql -e "CREATE DATABASE IF NOT EXISTS laravel_starter;"
```

### 6. Laravel Issues

**Error**: `Composer install fails`
```bash
# Check Composer version
composer --version

# Update Composer
sudo composer self-update

# Clear Composer cache
composer clear-cache

# Install with verbose output
cd /var/www/laravel-starter
sudo -u www-data composer install -vvv
```

**Error**: `NPM install fails`
```bash
# Check Node.js version
node --version
npm --version

# Clear NPM cache
npm cache clean --force

# Install with verbose output
cd /var/www/laravel-starter
sudo -u www-data npm install --verbose
```

**Error**: `Laravel key not generated`
```bash
cd /var/www/laravel-starter
sudo -u www-data php artisan key:generate --force
```

**Error**: `Storage permissions`
```bash
# Fix Laravel permissions
sudo chown -R www-data:www-data /var/www/laravel-starter
sudo chmod -R 755 /var/www/laravel-starter
sudo chmod -R 777 /var/www/laravel-starter/storage
sudo chmod -R 777 /var/www/laravel-starter/bootstrap/cache
```

### 7. Email Configuration Issues

**Error**: `Mail sending fails`
```bash
# Test SMTP connectivity
telnet smtp-relay.sendinblue.com 587

# Check Laravel logs
tail -f /var/www/laravel-starter/storage/logs/laravel.log

# Test email in Laravel
cd /var/www/laravel-starter
sudo -u www-data php artisan tinker
>>> use Illuminate\Support\Facades\Mail;
>>> Mail::raw('Test', function($m) { $m->to('test@example.com')->subject('Test'); });
```

**Error**: `SendinBlue authentication fails`
```bash
# Verify credentials in .env file
cd /var/www/laravel-starter
grep MAIL_ .env

# Test credentials manually
curl -X POST https://api.sendinblue.com/v3/smtp/email \
  -H "accept: application/json" \
  -H "api-key: YOUR_API_KEY"
```

## 🔧 Advanced Diagnostics

### Memory and Performance Issues

```bash
# Check memory usage
free -h

# Check running processes
top

# Check PHP memory limits
php -i | grep memory_limit

# Monitor real-time resource usage
htop
```

### File Permission Issues

```bash
# Check Laravel directory permissions
ls -la /var/www/
ls -la /var/www/laravel-starter/

# Check specific Laravel directories
ls -la /var/www/laravel-starter/storage/
ls -la /var/www/laravel-starter/bootstrap/cache/

# Reset all permissions
sudo chown -R www-data:www-data /var/www/laravel-starter
sudo find /var/www/laravel-starter -type f -exec chmod 644 {} \;
sudo find /var/www/laravel-starter -type d -exec chmod 755 {} \;
sudo chmod -R 777 /var/www/laravel-starter/storage
sudo chmod -R 777 /var/www/laravel-starter/bootstrap/cache
```

### Network Connectivity

```bash
# Test internet connectivity
ping google.com

# Test specific domains
ping github.com
ping packagist.org
ping registry.npmjs.org

# Check DNS resolution
nslookup github.com
```

## 📋 Health Check Commands

Create a quick health check script:

```bash
#!/bin/bash
echo "=== System Health Check ==="
echo "Services Status:"
systemctl is-active nginx php8.1-fpm mariadb

echo -e "\nPort Check:"
ss -tlnp | grep -E ":80|:3306"

echo -e "\nDisk Space:"
df -h /

echo -e "\nMemory Usage:"
free -h

echo -e "\nLaravel Directory:"
ls -la /var/www/laravel-starter/ | head -5

echo -e "\nLast 5 Laravel Logs:"
tail -5 /var/www/laravel-starter/storage/logs/laravel.log 2>/dev/null || echo "No Laravel logs found"

echo -e "\nLast 5 Nginx Error Logs:"
sudo tail -5 /var/log/nginx/error.log 2>/dev/null || echo "No Nginx errors"
```

## 🚨 Emergency Recovery

### Complete Service Restart
```bash
# Stop all services
sudo systemctl stop nginx php8.1-fpm mariadb

# Start services in order
sudo systemctl start mariadb
sudo systemctl start php8.1-fpm
sudo systemctl start nginx

# Check status
sudo systemctl status nginx php8.1-fpm mariadb
```

### Reset Laravel Application
```bash
# Backup current .env
sudo cp /var/www/laravel-starter/.env /var/www/laravel-starter/.env.backup

# Reset Laravel
cd /var/www/laravel-starter
sudo -u www-data composer install --no-dev
sudo -u www-data php artisan migrate:fresh --seed --force
sudo -u www-data php artisan config:clear
sudo -u www-data php artisan cache:clear
```

### Reset Database
```bash
# Drop and recreate database
sudo mysql -e "DROP DATABASE IF EXISTS laravel_starter;"
sudo mysql -e "CREATE DATABASE laravel_starter;"
sudo mysql -e "GRANT ALL PRIVILEGES ON laravel_starter.* TO 'laravel_user'@'localhost';"

# Re-run migrations
cd /var/www/laravel-starter
sudo -u www-data php artisan migrate --force
sudo -u www-data php artisan db:seed --force
```

## 📞 Getting Additional Help

1. **Check system logs**: `sudo journalctl -f`
2. **Monitor real-time**: `sudo tail -f /var/log/nginx/error.log`
3. **Laravel debug mode**: Set `APP_DEBUG=true` in `.env`
4. **Increase logging**: Set `LOG_LEVEL=debug` in `.env`

## 🔗 Useful Resources

- [Laravel Debugging](https://laravel.com/docs/debugging)
- [Nginx Troubleshooting](https://nginx.org/en/docs/debugging_log.html)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [MariaDB Error Codes](https://mariadb.com/kb/en/mariadb-error-codes/)