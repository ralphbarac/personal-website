#!/bin/bash

# Production Readiness Verification Script
# Run this script to verify your production setup is correct

set -e  # Exit on any error

echo "🚀 Phoenix Production Readiness Verification"
echo "============================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "✅ ${GREEN}$2${NC}"
    else
        echo -e "❌ ${RED}$2${NC}"
        exit 1
    fi
}

print_warning() {
    echo -e "⚠️  ${YELLOW}$1${NC}"
}

print_info() {
    echo -e "ℹ️  $1"
}

echo ""
echo "📋 Checking Production Configuration..."

# Check if required environment variables are set
echo ""
echo "🔍 Environment Variables Check:"

if [ -z "$DATABASE_URL" ]; then
    print_warning "DATABASE_URL not set. Make sure to set it in production!"
else
    print_status 0 "DATABASE_URL is set"
    
    # Check if DATABASE_URL contains ssl=true
    if [[ "$DATABASE_URL" == *"ssl=true"* ]]; then
        print_status 0 "DATABASE_URL includes SSL configuration"
    else
        print_warning "DATABASE_URL should include '?ssl=true' for production"
    fi
fi

if [ -z "$SECRET_KEY_BASE" ]; then
    print_warning "SECRET_KEY_BASE not set. Generate with: mix phx.gen.secret"
else
    print_status 0 "SECRET_KEY_BASE is set"
    
    # Check if secret is long enough
    if [ ${#SECRET_KEY_BASE} -ge 64 ]; then
        print_status 0 "SECRET_KEY_BASE is sufficiently long (${#SECRET_KEY_BASE} chars)"
    else
        print_warning "SECRET_KEY_BASE should be at least 64 characters"
    fi
fi

if [ -z "$PHX_HOST" ]; then
    print_warning "PHX_HOST not set. Set to your production domain"
else
    print_status 0 "PHX_HOST is set to: $PHX_HOST"
fi

# Check Mix environment
echo ""
echo "🔍 Build Environment Check:"

if [ "$MIX_ENV" = "prod" ]; then
    print_status 0 "MIX_ENV is set to production"
else
    print_info "Setting MIX_ENV=prod for checks..."
    export MIX_ENV=prod
fi

# Check if production dependencies are installed
echo ""
echo "📦 Dependencies Check:"
if mix deps.check > /dev/null 2>&1; then
    print_status 0 "Production dependencies are up to date"
else
    print_info "Installing production dependencies..."
    mix deps.get --only prod
    print_status $? "Production dependencies installed"
fi

# Check if application compiles
echo ""
echo "🔧 Compilation Check:"
if mix compile > /dev/null 2>&1; then
    print_status 0 "Application compiles successfully"
else
    print_status 1 "Application compilation failed"
fi

# Check if assets can be deployed
echo ""
echo "🎨 Assets Check:"
if mix assets.deploy > /dev/null 2>&1; then
    print_status 0 "Assets compiled successfully"
else
    print_status 1 "Asset compilation failed"
fi

# Check if cache manifest exists
if [ -f "priv/static/cache_manifest.json" ]; then
    print_status 0 "Cache manifest exists"
else
    print_status 1 "Cache manifest missing (run mix assets.deploy)"
fi

# Check database configuration
echo ""
echo "🗄️  Database Configuration Check:"

# Check if SSL is enabled in config
if grep -q "ssl: true" config/runtime.exs; then
    print_status 0 "Database SSL is enabled in configuration"
else
    print_status 1 "Database SSL is not enabled in config/runtime.exs"
fi

# Security checks
echo ""
echo "🔒 Security Configuration Check:"

# Check if force_ssl is enabled
if grep -q "force_ssl: \[hsts: true\]" config/prod.exs; then
    print_status 0 "HTTPS/HSTS is enforced"
else
    print_warning "HTTPS/HSTS enforcement not found in config/prod.exs"
fi

# Check if CSP headers are configured
if grep -q "content-security-policy" config/prod.exs; then
    print_status 0 "Content Security Policy is configured"
else
    print_warning "Content Security Policy not found in config/prod.exs"
fi

# Check if admin routes are protected
if grep -q ":require_authenticated_user" lib/website_web/router.ex; then
    print_status 0 "Admin routes are protected with authentication"
else
    print_warning "Admin route protection not found"
fi

# Check that no public registration route exists (single-admin design)
if grep -q "users/register" lib/website_web/router.ex; then
    print_warning "Public registration route found (should be single-admin)"
else
    print_status 0 "No public registration route (correct single-admin design)"
fi

# Production safety checks
echo ""
echo "🔒 Production Safety Checks:"

# Check if seeds have production protection
if grep -q "if Mix.env() == :prod do" priv/repo/seeds.exs; then
    print_status 0 "Seeds are protected from running in production"
else
    print_warning "Seeds file lacks production protection"
fi

# Production recommendations
echo ""
echo "💡 Production Recommendations:"
print_info "1. Set up reverse proxy (nginx/caddy) for SSL termination"
print_info "2. Configure firewall to allow only necessary ports"
print_info "3. Set up regular database backups"
print_info "4. Monitor application logs"
print_info "5. Consider adding rate limiting (see REQUIREMENTS.md)"
print_info "6. Create all production data manually via admin interface or console"
print_info "7. No automated setup scripts for maximum security"

echo ""
echo "🎉 Production readiness verification complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy .env.production.example to your server"
echo "2. Fill in your actual values"
echo "3. Test with your production database"
echo "4. Deploy and verify with DEPLOYMENT_CHECKLIST.md"
echo ""
echo "Your Phoenix application is ready for production! 🚀"