# Quick Setup Guide

## 🚀 One-Command Setup

For Ubuntu VM users who want to get Laravel Starter running quickly:

```bash
# Clone and run
git clone https://github.com/yourusername/ubuntu-vm-laravel-setup.git
cd ubuntu-vm-laravel-setup
chmod +x setup.sh
./setup.sh
```

## ⏱️ Estimated Time
- **Total Setup Time**: 15-30 minutes
- System setup: 5-10 minutes
- Server environment: 10-15 minutes  
- Laravel deployment: 5-10 minutes
- Email configuration: 2-5 minutes (optional)

## 📋 Pre-flight Checklist

Before running the setup, ensure:

- [ ] Ubuntu VM is running (20.04 or 22.04 recommended)
- [ ] User has sudo privileges
- [ ] Internet connection is stable
- [ ] At least 5GB free disk space
- [ ] VM has at least 2GB RAM

## 🎯 What You'll Get

After successful completion:

1. **Fully configured server stack**:
   - PHP 8.1 with all required extensions
   - Nginx web server with Laravel configuration
   - MariaDB database with sample data
   - Composer and NPM for dependency management

2. **Deployed Laravel application**:
   - Laravel Starter app running at `http://your-vm-ip`
   - Sample posts, categories, tags, and comments
   - Admin user ready for testing
   - All database migrations and seeders applied

3. **Email functionality** (if configured):
   - SendinBlue SMTP integration
   - Password reset functionality
   - Email notifications

## 🔑 Default Credentials

**Admin User:**
- Email: `super@admin.com`
- Password: `secret`

**Database:**
- Database: `laravel_starter`
- Username: `laravel_user`
- Password: `Laravel@123`

## 🧪 Testing Features

After setup, test these features:

1. **User Registration**: `http://your-vm-ip/register`
2. **User Login**: `http://your-vm-ip/login`
3. **Browse Posts**: View sample blog posts
4. **Add Comments**: Comment on existing posts
5. **Password Reset**: Test "Forgot Password" (if email configured)

## 📸 Screenshot Checklist

For your assignment, capture screenshots of:

- [ ] User registration page
- [ ] Successful user registration
- [ ] User login page  
- [ ] Dashboard after login
- [ ] Posts listing page
- [ ] Categories page
- [ ] Tags page
- [ ] Comments on a post
- [ ] Adding a new comment
- [ ] Password reset email (if configured)

## 🔧 Quick Commands

**Check application status:**
```bash
sudo systemctl status nginx php8.2-fpm mariadb
```

**View application logs:**
```bash
sudo tail -f /var/log/nginx/error.log
tail -f /var/www/laravel-starter/storage/logs/laravel.log
```

**Restart services:**
```bash
sudo systemctl restart nginx php8.2-fpm mariadb
```

## ❗ Troubleshooting

If something goes wrong:

1. **Check the logs** (commands above)
2. **Review the troubleshooting guide**: `docs/troubleshooting.md`
3. **Re-run specific scripts**:
   ```bash
   ./scripts/01-system-setup.sh      # System configuration
   ./scripts/02-server-environment.sh # Server installation
   ./scripts/03-laravel-deployment.sh # Laravel deployment
   ./scripts/04-email-config.sh      # Email setup
   ```

## 🌐 Access Your Application

After successful setup:

1. Find your VM's IP address: `hostname -I`
2. Open browser and go to: `http://your-vm-ip`
3. Login with admin credentials above
4. Start testing the features!

## 📚 Next Steps

1. **Configure email** (if skipped): `./scripts/04-email-config.sh`
2. **Customize the application**: Edit files in `/var/www/laravel-starter`
3. **Add your own content**: Create posts, categories, and test all features
4. **Take screenshots**: Document all the required features for your assignment

---

**Need help?** Check the main README.md and troubleshooting guide in the docs folder.