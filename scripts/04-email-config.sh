#!/bin/bash

#############################################
# Email Configuration Script for SendinBlue
# Configures SMTP settings for Laravel
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

# Display SendinBlue setup instructions
display_sendinblue_instructions() {
    echo ""
    echo "========================================="
    echo "         SENDINBLUE SMTP SETUP"
    echo "========================================="
    echo ""
    echo "To configure email functionality:"
    echo ""
    echo "1. Create a SendinBlue account:"
    echo "   - Go to https://sendinblue.com"
    echo "   - Sign up for a free account"
    echo ""
    echo "2. Get your SMTP credentials:"
    echo "   - Login to your SendinBlue dashboard"
    echo "   - Go to 'SMTP & API' section"
    echo "   - Navigate to 'SMTP' tab"
    echo "   - Your login is your account email"
    echo "   - Create an SMTP key (this will be your password)"
    echo ""
    echo "3. SendinBlue SMTP Settings:"
    echo "   - SMTP Server: smtp-relay.sendinblue.com"
    echo "   - Port: 587 (TLS) or 465 (SSL)"
    echo "   - Username: Your SendinBlue account email"
    echo "   - Password: Your SMTP key"
    echo ""
    echo "========================================="
    echo ""
}

# Configure email settings interactively
configure_email_interactive() {
    log "Starting interactive email configuration..."
    
    display_sendinblue_instructions
    
    echo "Would you like to configure email settings now? (y/n)"
    read -p "> " configure_now
    
    if [[ $configure_now =~ ^[Yy]$ ]]; then
        echo ""
        echo "Please enter your SendinBlue SMTP credentials:"
        echo ""
        
        read -p "SMTP Username (your SendinBlue email): " smtp_username
        read -s -p "SMTP Password (your SMTP key): " smtp_password
        echo ""
        read -p "From Email Address: " from_email
        read -p "From Name: " from_name
        
        # Update .env file
        cd $APP_DIR
        
        sudo -u www-data sed -i "s/MAIL_MAILER=.*/MAIL_MAILER=smtp/" .env
        sudo -u www-data sed -i "s/MAIL_HOST=.*/MAIL_HOST=smtp-relay.sendinblue.com/" .env
        sudo -u www-data sed -i "s/MAIL_PORT=.*/MAIL_PORT=587/" .env
        sudo -u www-data sed -i "s/MAIL_USERNAME=.*/MAIL_USERNAME=$smtp_username/" .env
        sudo -u www-data sed -i "s/MAIL_PASSWORD=.*/MAIL_PASSWORD=$smtp_password/" .env
        sudo -u www-data sed -i "s/MAIL_ENCRYPTION=.*/MAIL_ENCRYPTION=tls/" .env
        sudo -u www-data sed -i "s/MAIL_FROM_ADDRESS=.*/MAIL_FROM_ADDRESS=$from_email/" .env
        sudo -u www-data sed -i "s/MAIL_FROM_NAME=.*/MAIL_FROM_NAME=\"$from_name\"/" .env
        
        log "Email configuration updated successfully!"
        
        # Test email configuration
        echo ""
        echo "Would you like to test the email configuration? (y/n)"
        read -p "> " test_email
        
        if [[ $test_email =~ ^[Yy]$ ]]; then
            read -p "Enter test email address: " test_email_address
            test_email_functionality "$test_email_address"
        fi
    else
        log "Skipping email configuration. You can configure it later."
        info "To configure email later, run: ./scripts/04-email-config.sh"
    fi
}

# Test email functionality
test_email_functionality() {
    local test_email="$1"
    
    log "Testing email functionality..."
    
    cd $APP_DIR
    
    # Create a simple test command
    sudo -u www-data php artisan tinker --execute="
        use Illuminate\Support\Facades\Mail;
        try {
            Mail::raw('This is a test email from your Laravel application.', function(\$message) use ('$test_email') {
                \$message->to('$test_email')->subject('Laravel Email Test');
            });
            echo 'Email sent successfully!';
        } catch (Exception \$e) {
            echo 'Email failed: ' . \$e->getMessage();
        }
    "
    
    info "Test email sent to: $test_email"
    info "Please check your inbox (and spam folder)"
}

# Create email configuration template
create_email_template() {
    log "Creating email configuration template..."
    
    cat > /tmp/email-config-template.txt <<EOF
# SendinBlue SMTP Configuration for Laravel
# Copy these settings to your .env file

MAIL_MAILER=smtp
MAIL_HOST=smtp-relay.sendinblue.com
MAIL_PORT=587
MAIL_USERNAME=your-sendinblue-email@example.com
MAIL_PASSWORD=your-smtp-key
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=your-sendinblue-email@example.com
MAIL_FROM_NAME="Your App Name"

# Steps to configure:
# 1. Sign up at https://sendinblue.com
# 2. Go to SMTP & API > SMTP
# 3. Use your account email as username
# 4. Generate an SMTP key as password
# 5. Update the values above
# 6. Replace the corresponding lines in /var/www/laravel-starter/.env
EOF

    sudo mv /tmp/email-config-template.txt /home/$USER/email-config-template.txt
    sudo chown $USER:$USER /home/$USER/email-config-template.txt
    
    info "Email configuration template created at: /home/$USER/email-config-template.txt"
}

# Manual configuration option
configure_manual() {
    log "Creating manual configuration instructions..."
    
    create_email_template
    
    echo ""
    echo "========================================="
    echo "        MANUAL CONFIGURATION"
    echo "========================================="
    echo ""
    echo "To manually configure email:"
    echo ""
    echo "1. Edit the Laravel .env file:"
    echo "   sudo nano $APP_DIR/.env"
    echo ""
    echo "2. Update the email settings (use template at ~/email-config-template.txt)"
    echo ""
    echo "3. Test the configuration:"
    echo "   cd $APP_DIR"
    echo "   php artisan tinker"
    echo "   >>> Mail::raw('Test', function(\$m) { \$m->to('test@example.com')->subject('Test'); });"
    echo ""
    echo "========================================="
}

# Main function
main() {
    log "Starting email configuration..."
    
    if [ ! -d "$APP_DIR" ]; then
        error "Laravel application not found. Please run the deployment script first."
    fi
    
    echo ""
    echo "Email Configuration Options:"
    echo "1. Interactive configuration (recommended)"
    echo "2. Manual configuration"
    echo "3. Skip for now"
    echo ""
    read -p "Choose an option (1-3): " choice
    
    case $choice in
        1)
            configure_email_interactive
            ;;
        2)
            display_sendinblue_instructions
            configure_manual
            ;;
        3)
            log "Skipping email configuration"
            create_email_template
            ;;
        *)
            warning "Invalid choice. Creating manual configuration template."
            display_sendinblue_instructions
            configure_manual
            ;;
    esac
    
    log "Email configuration completed!"
}

main "$@"