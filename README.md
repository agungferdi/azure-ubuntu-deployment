# Ubuntu VM Laravel Deployment Automation

This repository contains automation scripts to set up a complete Laravel development environment on Ubuntu VM and deploy the [Laravel Starter](https://github.com/nasirkhan/laravel-starter) application.

## 📋 Requirements Met

✅ **Server Environment:**
- PHP 8.2 (upgraded from 8.1 for Laravel Starter compatibility)
- Nginx 1.18/1.21 with Laravel-optimized configuration
- MariaDB 10 with automated user management
- Composer 2.2+ for dependency management
- Node.js 18.x & NPM (upgraded from 16.x for modern builds)

✅ **System Configuration:**
- Timezone: Asia/Jakarta
- System updates and security patches
- Git, Curl, ZIP, Python3 & Python3-pip
- Docker installation with proper user permissions
- UFW firewall with HTTP/HTTPS access configured

✅ **Laravel Application:**
- Automated deployment of Laravel Starter from GitHub
- Database setup with migrations and seeding (including Faker)
- Nginx virtual host configuration for Laravel
- Email configuration for password reset (SendinBlue SMTP)
- Proper file permissions for storage and cache directories
- Asset compilation with NPM build scripts

✅ **Security & Access:**
- UFW firewall configuration for external access
- Database user with limited privileges
- Nginx security headers
- Laravel security configurations

## 🚀 Quick Start

### Prerequisites
- Ubuntu VM (tested on Ubuntu 20.04/22.04)
- User with sudo privileges
- Git installed
- Internet connection

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/ubuntu-vm-laravel-setup.git
   cd ubuntu-vm-laravel-setup
   ```

2. **Make the main script executable:**
   ```bash
   chmod +x setup.sh
   ```

3. **Run the automated setup:**
   ```bash
   ./setup.sh
   ```

That's it! The script will automatically:
- Configure system timezone and update packages
- Install all required server components
- Deploy the Laravel application
- Configure email settings (interactive)

## 📁 Project Structure

```
ubuntu-vm-laravel-setup/
├── setup.sh                 # Main automation script
├── scripts/
│   ├── 01-system-setup.sh      # System configuration
│   ├── 02-server-environment.sh # Server software installation
│   ├── 03-laravel-deployment.sh # Laravel app deployment
│   └── 04-email-config.sh      # Email configuration
├── README.md
└── docs/
    └── troubleshooting.md
```

## 🔧 What Gets Installed

### System Components
- **Timezone**: Set to Asia/Jakarta
- **Basic tools**: curl, zip, unzip, python3, python3-pip, build-essential
- **Docker**: Latest stable version with user permissions

### Server Stack
- **PHP 8.2** with extensions: mysql, xml, curl, gd, mbstring, zip, intl, bcmath, soap, redis, sqlite3
- **Nginx**: Latest stable with Laravel configuration
- **MariaDB 10**: With secure installation and Laravel database setup
- **Composer 2.2**: Global installation with Faker dependency
- **Node.js 18.x & NPM**: For frontend asset compilation
- **Firewall**: UFW configured with HTTP/HTTPS access

### Laravel Application
- **Repository**: [Laravel Starter](https://github.com/nasirkhan/laravel-starter)
- **Location**: `/var/www/laravel-starter`
- **Database**: Pre-configured with migrations and seeders
- **Web server**: Nginx configured for Laravel
- **Scheduler**: Laravel cron job configured

## 🌐 Application Access

After successful installation:

- **URL**: `http://your-vm-ip`
- **Admin Login**:
  - Email: `super@admin.com`
  - Password: `secret`

### Features Available for Testing

1. **User Registration**: `/register`
2. **User Login**: `/login`  
3. **Posts Management**: View and manage posts
4. **Categories & Tags**: Organize content
5. **Comments System**: Add comments to posts
6. **Password Reset**: "Forgot Password" functionality (requires email setup)

## ⚠️ Common Issues & Solutions

### Quick Fix Command
If you encounter any issues, run the automated fix script:
```bash
curl -sSL https://raw.githubusercontent.com/agungferdi/azure-ubuntu-deployment/main/scripts/fix-common-issues.sh | bash
```

### Most Common Issues

1. **"Class 'Faker\Factory' not found" Error**
   - **Cause**: Missing Faker dependency for database seeding
   - **Fix**: Automatically handled by scripts, or manually run:
     ```bash
     cd /var/www/laravel-starter
     sudo -u www-data composer require fakerphp/faker --dev
     ```

2. **Database Connection Issues**
   - **Cause**: Incorrect database credentials or configuration
   - **Fix**: Check `/var/www/laravel-starter/.env` file for proper database settings

3. **External Access Blocked**
   - **Cause**: UFW firewall blocking HTTP traffic
   - **Fix**: Automatically configured, or manually run:
     ```bash
     sudo ufw allow 80/tcp
     sudo ufw allow 'Nginx Full'
     ```

4. **NPM Build Failures**
   - **Cause**: Node.js version compatibility issues
   - **Fix**: Scripts install Node.js 18.x specifically for compatibility

5. **Permission Errors**
   - **Cause**: Incorrect file ownership for Laravel directories
   - **Fix**: Automatically handled, or manually run:
     ```bash
     sudo chown -R www-data:www-data /var/www/laravel-starter
     sudo chmod -R 777 /var/www/laravel-starter/storage
     ```

For detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## 🎯 Deployment Best Practices

### Tested Configuration
- **Ubuntu**: 20.04 LTS / 22.04 LTS / 24.04 LTS
- **PHP**: 8.2 (required for Laravel Starter compatibility)
- **Node.js**: 18.x (required for modern NPM packages)
- **Database**: MariaDB 10.11+ (MySQL 8.0+ also compatible)

### Pre-Deployment Checklist
- [ ] VM has at least 2GB RAM and 20GB storage
- [ ] User has sudo privileges
- [ ] Internet connection is stable
- [ ] Ports 80 and 443 are available for Nginx
- [ ] No conflicting web servers (Apache, etc.) are running

### Post-Deployment Verification
- [ ] Laravel application loads at VM IP address
- [ ] User registration/login works
- [ ] Database seeding completed successfully
- [ ] All Laravel features are functional
- [ ] Email configuration works (if SMTP is configured)

## 🔍 Lessons Learned from Real Deployment

### Version Compatibility
- **PHP 8.1 → 8.2**: Laravel Starter requires PHP 8.2+ for all dependencies
- **Node.js 16 → 18**: Modern NPM packages need Node.js 18+ for builds
- **Faker Dependency**: Must be explicitly installed for database seeding

### Network Configuration
- **Firewall Setup**: UFW must allow HTTP traffic for external access
- **Nginx Configuration**: Laravel-specific settings required for proper routing
- **Database Access**: Localhost vs 127.0.0.1 can cause connection issues

### Build Process
- **NPM Scripts**: Laravel Starter uses `npm run build` (not `npm run production`)
- **Asset Compilation**: Requires Node.js 18+ for modern build tools
- **Permission Management**: Laravel storage directories need 777 permissions

## 📧 Email Configuration

The script supports email configuration for password reset functionality using SendinBlue:

### Automatic Configuration
During setup, you'll be prompted to configure email. Have ready:
- SendinBlue account email
- SMTP key from SendinBlue dashboard

### Manual Configuration
If skipped during setup, configure later:
```bash
./scripts/04-email-config.sh
```

### SendinBlue Setup Steps
1. Create account at [sendinblue.com](https://sendinblue.com)
2. Go to SMTP & API → SMTP
3. Use account email as username
4. Generate SMTP key as password

## 🗄️ Database Information

- **Database Name**: `laravel_starter`
- **Username**: `laravel_user`
- **Password**: `Laravel@123`
- **Host**: `localhost`

## 🔍 Testing Checklist

After deployment, verify these features work:

- [ ] User registration
- [ ] User login with new account
- [ ] View posts, categories, and tags
- [ ] Add comments to posts
- [ ] Password reset email functionality
- [ ] Admin panel access

## 🛠️ Manual Operations

### Restart Services
```bash
# Restart web server
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm

# Restart database
sudo systemctl restart mariadb

# Check service status
sudo systemctl status nginx php8.2-fpm mariadb
```

### Laravel Commands
```bash
cd /var/www/laravel-starter

# Clear caches
sudo -u www-data php artisan cache:clear
sudo -u www-data php artisan config:clear
sudo -u www-data php artisan route:clear

# Run migrations
sudo -u www-data php artisan migrate

# Check logs
tail -f storage/logs/laravel.log
```

### Check Logs
```bash
# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# PHP logs
sudo tail -f /var/log/php8.2-fpm.log

# System logs
sudo journalctl -f -u nginx
sudo journalctl -f -u php8.2-fpm
```

## 🔧 Troubleshooting

### Common Issues

**Issue**: Permission denied errors
```bash
# Fix Laravel permissions
sudo chown -R www-data:www-data /var/www/laravel-starter
sudo chmod -R 755 /var/www/laravel-starter
sudo chmod -R 777 /var/www/laravel-starter/storage
sudo chmod -R 777 /var/www/laravel-starter/bootstrap/cache
```

**Issue**: Database connection failed
```bash
# Check MariaDB status
sudo systemctl status mariadb

# Test database connection
mysql -u laravel_user -p laravel_starter
```

**Issue**: Nginx 502 Bad Gateway
```bash
# Check PHP-FPM status
sudo systemctl status php8.2-fpm

# Check socket permissions
ls -la /var/run/php/php8.2-fpm.sock
```

**Issue**: Email not working
```bash
# Test email configuration
cd /var/www/laravel-starter
sudo -u www-data php artisan tinker
>>> Mail::raw('Test', function($m) { $m->to('test@email.com')->subject('Test'); });
```

### Getting Help

1. Check service logs (commands above)
2. Verify all services are running
3. Test database connectivity
4. Check file permissions
5. Review Laravel logs

## 📚 Additional Resources

- [Laravel Documentation](https://laravel.com/docs)
- [Laravel Starter Documentation](https://github.com/nasirkhan/laravel-starter)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [SendinBlue SMTP Setup](https://help.sendinblue.com/hc/en-us/articles/209462765)

## 🤝 Contributing

Feel free to submit issues and pull requests to improve this automation script.

## 📄 License

This project is open source and available under the MIT License.