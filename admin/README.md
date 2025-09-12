# Admin Panel - Cihuy Management System

[![PHP Version](https://img.shields.io/badge/PHP-8.0%2B-blue.svg)](https://php.net)
[![Framework](https://img.shields.io/badge/Framework-PHP%20Native%2FLaravel%2FCI-green.svg)](https://laravel.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Sistem manajemen admin untuk platform Cihuy yang menyediakan antarmuka web untuk mengelola data, pengguna, dan operasional bisnis.

## Daftar Isi

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Development](#development)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

Admin Panel Cihuy adalah sistem manajemen berbasis web yang memungkinkan administrator untuk:

- Mengelola data master dan konten
- Memantau aktivitas pengguna
- Mengatur hak akses dan peran pengguna
- Melakukan operasional harian
- Menganalisis laporan dan statistik

### Arsitektur
- **Backend**: PHP (Framework: Laravel/CodeIgniter/Native)
- **Database**: MySQL/PostgreSQL
- **Frontend**: HTML5, CSS3, JavaScript
- **Authentication**: JWT/Session-based

## Features

### Authentication & Authorization
- Login/logout dengan validasi keamanan
- Role-based access control (RBAC)
- Session management
- Password reset functionality

### Dashboard & Analytics
- Overview metrik bisnis
- Grafik dan chart interaktif
- Real-time notifications
- Activity logs

### User Management
- CRUD operations untuk pengguna
- Role assignment
- Permission management
- User activity tracking

### Content Management
- Data master management
- File upload/download
- Content publishing
- Media library

### System Administration
- System configuration
- Database management
- Log monitoring
- Backup/restore

## Requirements

### Server Requirements
- **PHP**: 8.0 atau lebih tinggi
- **Web Server**: Apache 2.4+ atau Nginx 1.18+
- **Database**: MySQL 8.0+ atau PostgreSQL 13+
- **Memory**: Minimum 512MB RAM
- **Storage**: 1GB free space

### PHP Extensions
```bash
php-mbstring
php-xml
php-curl
php-zip
php-gd
php-mysql (atau php-pgsql)
php-json
php-tokenizer
php-fileinfo
```

### Development Tools
- Composer 2.0+
- Git
- Node.js 16+ (untuk asset compilation)

## Installation

### 1. Clone Repository
```bash
git clone <repository-url>
cd cihuy/admin
```

### 2. Install Dependencies
```bash
composer install
```

### 3. Environment Setup
```bash
cp .env.example .env
# Edit .env sesuai konfigurasi server
```

### 4. Database Setup
```bash
# Jika menggunakan Laravel
php artisan migrate
php artisan db:seed

# Jika menggunakan CodeIgniter
# Import database schema dari file SQL
```

### 5. Generate Application Key
```bash
# Laravel
php artisan key:generate

# CodeIgniter
# Generate encryption key di config/encryption.php
```

### 6. Set Permissions
```bash
# Linux/Mac
chmod -R 755 storage/
chmod -R 755 bootstrap/cache/

# Windows
# Pastikan folder storage dan cache dapat ditulis
```

### 7. Start Development Server
```bash
# Laravel
php artisan serve

# CodeIgniter
php -S localhost:8000

# Apache/Nginx
# Konfigurasi virtual host
```

## Configuration

### Environment Variables (.env)
```env
# Application
APP_NAME="Cihuy Admin"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=cihuy_admin
DB_USERNAME=root
DB_PASSWORD=

# Cache
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Mail
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_ENCRYPTION=tls

# Security
APP_KEY=base64:your-app-key-here
JWT_SECRET=your-jwt-secret-here
```

### Database Configuration
```php
// config/database.php
'mysql' => [
    'driver' => 'mysql',
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_DATABASE', 'cihuy_admin'),
    'username' => env('DB_USERNAME', 'root'),
    'password' => env('DB_PASSWORD', ''),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
],
```

## Usage

### Login
1. Buka URL admin panel: `https://yourdomain.com/admin`
2. Masukkan username dan password
3. Klik "Login"

### Dashboard
- **Overview**: Statistik umum sistem
- **Recent Activity**: Aktivitas terbaru
- **Quick Actions**: Aksi cepat yang sering digunakan
- **Notifications**: Pemberitahuan sistem

### User Management
1. Navigasi ke **Users** → **Manage Users**
2. Klik **Add New User** untuk menambah pengguna
3. Isi form data pengguna
4. Assign role dan permissions
5. Save changes

### Content Management
1. Pilih menu **Content** → **Manage Content**
2. Filter berdasarkan kategori atau status
3. Edit/Delete content sesuai kebutuhan
4. Publish/Unpublish content

### System Settings
1. Navigasi ke **Settings** → **System Configuration**
2. Update konfigurasi sesuai kebutuhan
3. Test koneksi database dan email
4. Save configuration

## API Reference

### Authentication Endpoints
```http
POST /api/auth/login
Content-Type: application/json

{
    "email": "admin@cihuy.com",
    "password": "password123"
}
```

### User Management
```http
GET /api/users
Authorization: Bearer {token}

GET /api/users/{id}
POST /api/users
PUT /api/users/{id}
DELETE /api/users/{id}
```

### Content Management
```http
GET /api/content
POST /api/content
PUT /api/content/{id}
DELETE /api/content/{id}
```

### Response Format
```json
{
    "success": true,
    "message": "Operation successful",
    "data": {},
    "meta": {
        "pagination": {
            "current_page": 1,
            "total": 100,
            "per_page": 15
        }
    }
}
```

## Development

### Project Structure
```
admin/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   ├── Middleware/
│   │   └── Requests/
│   ├── Models/
│   ├── Services/
│   └── Helpers/
├── config/
├── database/
│   ├── migrations/
│   └── seeders/
├── public/
│   ├── assets/
│   └── index.php
├── resources/
│   ├── views/
│   ├── css/
│   └── js/
├── routes/
│   ├── web.php
│   └── api.php
├── storage/
│   ├── logs/
│   └── app/
└── tests/
```

### Coding Standards
- Follow PSR-12 coding standards
- Use meaningful variable and function names
- Add PHPDoc comments for all functions
- Write unit tests for critical functions

### Running Tests
```bash
# PHPUnit tests
composer test

# Code coverage
composer test-coverage

# Static analysis
composer analyse
```

### Database Migrations
```bash
# Create migration
php artisan make:migration create_users_table

# Run migrations
php artisan migrate

# Rollback migrations
php artisan migrate:rollback
```

## Deployment

### Production Checklist
- [ ] Set `APP_ENV=production`
- [ ] Set `APP_DEBUG=false`
- [ ] Generate secure `APP_KEY`
- [ ] Configure production database
- [ ] Set up SSL certificate
- [ ] Configure web server (Apache/Nginx)
- [ ] Set up monitoring and logging
- [ ] Configure backup strategy

### Environment Setup
```bash
# Production environment
cp .env.production .env

# Install production dependencies
composer install --no-dev --optimize-autoloader

# Clear and cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Web Server Configuration

#### Apache (.htaccess)
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
```

#### Nginx
```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}

location ~ \.php$ {
    fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    include fastcgi_params;
}
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Error
```bash
# Check database credentials
php artisan tinker
>>> DB::connection()->getPdo();

# Test database connection
php artisan migrate:status
```

#### 2. Permission Denied
```bash
# Set proper permissions
chmod -R 755 storage/
chmod -R 755 bootstrap/cache/
chown -R www-data:www-data storage/
```

#### 3. 500 Internal Server Error
- Check error logs: `storage/logs/laravel.log`
- Verify `.env` configuration
- Check PHP error logs
- Ensure all dependencies are installed

#### 4. Session Issues
```bash
# Clear session cache
php artisan session:clear

# Regenerate session key
php artisan key:generate
```

### Debug Mode
```bash
# Enable debug mode
APP_DEBUG=true

# Check logs
tail -f storage/logs/laravel.log
```

### Performance Issues
- Enable OPcache
- Use Redis for caching
- Optimize database queries
- Use CDN for static assets

## Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Code Review Process
- All code must be reviewed before merging
- Ensure tests pass
- Follow coding standards
- Update documentation

### Reporting Issues
- Use GitHub Issues
- Provide detailed reproduction steps
- Include system information
- Attach relevant logs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [docs.cihuy.com](https://docs.cihuy.com)
- **Issues**: [GitHub Issues](https://github.com/cihuy/admin/issues)
- **Email**: support@cihuy.com
- **Discord**: [Cihuy Community](https://discord.gg/cihuy)

---

**Made with love by Cihuy Team**
