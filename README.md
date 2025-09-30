# Ubuntu VM Laravel Deployment Automation

This repository contains automation scripts to set up a complete Laravel development environment on Ubuntu VM and deploy the [Laravel Starter](https://github.com/nasirkhan/laravel-starter) application.

## 📋 Requirements Met

✅ **Server Environment:**
- PHP 8.2
- Nginx 1.18/1.21
- MariaDB 10
- Composer 2.2
- NPM 16.x

✅ **System Configuration:**
- Timezone: Asia/Jakarta
- System updates and upgrades
- Git, Curl, ZIP, Python3 & Python3-pip
- Docker installation

✅ **Laravel Application:**
- Automated deployment of Laravel Starter
- Database setup and migration
- Nginx configuration
- Email configuration for password reset

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
- **PHP 8.2** with extensions: mysql, xml, curl, gd, mbstring, zip, intl, bcmath, soap, redis
- **Nginx**: Latest stable with Laravel configuration
- **MariaDB 10**: With secure installation and Laravel database setup
- **Composer 2.2**: Global installation
- **Node.js 16.x & NPM**: For frontend asset compilation

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