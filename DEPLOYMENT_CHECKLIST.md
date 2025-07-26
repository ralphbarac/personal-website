# Production Deployment Checklist

## Pre-Deployment Setup

### 1. Environment Variables Configuration
Copy `.env.production.example` to your server and configure:

```bash
# Required variables (app will crash without these)
DATABASE_URL="postgresql://user:pass@host:5432/db?ssl=true"
SECRET_KEY_BASE="<generate with: mix phx.gen.secret>"
PHX_HOST="yourdomain.com"

# Recommended variables
PHX_SERVER=true
PORT=4000
POOL_SIZE=10
```

### 2. Database Setup
```bash
# Create production database and run migrations
MIX_ENV=prod mix ecto.create
MIX_ENV=prod mix ecto.migrate

# ⚠️  DO NOT RUN SEEDS IN PRODUCTION!
# Seeds contain development/test data (demo posts, test users, sample photos)

# Create your admin user via console (no registration route by design)
# MIX_ENV=prod iex -S mix
# Website.Accounts.register_user(%{email: "your@email.com", password: "secure_password"})

# Create any needed categories/data manually via admin interface or console
```

### 3. Assets Compilation
```bash
# Compile and optimize static assets
MIX_ENV=prod mix assets.deploy
```

### 4. Application Build
```bash
# Compile application for production
MIX_ENV=prod mix compile
# OR build a release
MIX_ENV=prod mix release
```

## Deployment Verification

### Immediate Checks (Run these right after deployment)
- [ ] **Application starts**: No crash on startup
- [ ] **Database connects**: SSL connection established
- [ ] **Public pages load**: 
  - [ ] `/` (homepage)
  - [ ] `/about` 
  - [ ] `/work`
  - [ ] `/blog`
  - [ ] `/projects`
- [ ] **RSS feeds work**:
  - [ ] `/feed.xml` (RSS 2.0)
  - [ ] `/feed.atom` (Atom 1.0)
- [ ] **Admin access**:
  - [ ] `/admin` redirects to login
  - [ ] Admin login works with created user
  - [ ] No public registration route (single-admin design)
- [ ] **HTTPS redirect**: HTTP requests redirect to HTTPS
- [ ] **Health check**: `/api/health` returns JSON status

### Security Verification
- [ ] **SSL/TLS**: All traffic encrypted (check browser security indicators)
- [ ] **HSTS headers**: Site uses HTTPS Strict Transport Security
- [ ] **CSP headers**: Content Security Policy active
- [ ] **Admin protection**: Cannot access `/admin/*` without authentication

### Performance Checks
- [ ] **Page load speed**: Public pages load in < 2 seconds
- [ ] **RSS generation**: Feeds generate in < 1 second
- [ ] **Database queries**: No obvious N+1 query issues in logs

## Production Environment Commands

### Starting the Application
```bash
# If using mix
PORT=4000 MIX_ENV=prod mix phx.server

# If using releases
_build/prod/rel/website/bin/website start

# With systemd service (recommended)
sudo systemctl start website
sudo systemctl enable website  # Auto-start on boot
```

### Checking Status
```bash
# Check if app is running
curl -f http://localhost:4000/api/health

# Check logs
journalctl -u website -f  # If using systemd
tail -f log/prod.log      # If logging to file
```

### Common Production Tasks
```bash
# Run migrations
MIX_ENV=prod mix ecto.migrate

# Open production console
MIX_ENV=prod iex -S mix

# Check database connection
MIX_ENV=prod mix ecto.show_status
```

## Troubleshooting

### Application Won't Start
1. **Check environment variables**: All required vars set?
2. **Database connection**: Can you connect to DB with SSL?
3. **Port conflicts**: Is port 4000 available?
4. **Permissions**: Does app have write access to needed directories?

### Database Issues
1. **SSL connection failed**: Verify `DATABASE_URL` includes `?ssl=true`
2. **Connection refused**: Check database server is running and accessible
3. **Authentication failed**: Verify username/password in DATABASE_URL

### Performance Issues
1. **Slow page loads**: Check database query logs for N+1 queries
2. **Memory usage**: Monitor with `htop` or similar
3. **High CPU**: Check for infinite loops or inefficient queries

## Security Considerations

### Environment Variables
- ✅ No secrets in version control (`.env.production` in `.gitignore`)
- ✅ `SECRET_KEY_BASE` is unique and secure (64+ characters)
- ✅ Database password is strong

### Web Security
- ✅ CSRF protection enabled (built into Phoenix)
- ✅ HTTPS enforced with HSTS headers
- ✅ Content Security Policy configured
- ✅ Admin routes require authentication

### Database Security
- ✅ SSL connections enforced
- ✅ Database user has minimal required permissions
- ✅ Regular backups scheduled

## Success Criteria

### Immediate Success (Day 1)
- [x] Application running without crashes
- [x] All public pages accessible
- [x] RSS feeds working
- [x] Admin authentication functional
- [x] HTTPS redirect working

### Week 1 Goals
- [ ] Rate limiting implemented (optional but recommended)
- [ ] Monitoring/alerting set up
- [ ] Backup procedures tested
- [ ] Performance optimization if needed

### Long-term Goals
- [ ] Automated deployments
- [ ] Log aggregation
- [ ] Error monitoring (Sentry/AppSignal)
- [ ] Performance monitoring

---

**The application is production-ready!** These checklist items ensure a smooth deployment and ongoing operation.