# Cihuy Platform - Technical Documentation

**Versi 1.0 | September 2025**

---

## Daftar Isi

1. [System Overview](#system-overview)
2. [Architecture & Technology Stack](#architecture--technology-stack)
3. [Installation & Setup](#installation--setup)
4. [Configuration](#configuration)
5. [API Reference](#api-reference)
6. [Development Guidelines](#development-guidelines)
7. [Deployment](#deployment)
8. [Monitoring & Maintenance](#monitoring--maintenance)
9. [Security](#security)
10. [Troubleshooting](#troubleshooting)

---

## System Overview

### Platform Components
- **Admin Panel**: PHP-based web management system
- **User App**: Flutter cross-platform mobile application
- **API Backend**: RESTful API service layer
- **Database**: MySQL/PostgreSQL data storage
- **File Storage**: Local/Cloud storage solution

### System Requirements
- **Server**: Linux/Windows Server 2019+
- **PHP**: 8.0+ with required extensions
- **Database**: MySQL 8.0+ or PostgreSQL 13+
- **Web Server**: Apache 2.4+ or Nginx 1.18+
- **Memory**: Minimum 4GB RAM
- **Storage**: 50GB+ available space

---

## Architecture & Technology Stack

### Backend Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Admin Panel   │    │   User App      │    │   Third-party   │
│   (PHP/Laravel) │    │   (Flutter)     │    │   Services      │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │      API Gateway          │
                    │    (Authentication,       │
                    │     Rate Limiting,        │
                    │     Load Balancing)       │
                    └─────────────┬─────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │      Business Logic       │
                    │    (Controllers,          │
                    │     Services, Models)     │
                    └─────────────┬─────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │      Data Layer           │
                    │    (Database, Cache,      │
                    │     File Storage)         │
                    └───────────────────────────┘
```

### Technology Stack

#### Backend (Admin Panel)
- **Framework**: Laravel 10.x
- **Language**: PHP 8.1+
- **Database**: MySQL 8.0 / PostgreSQL 13
- **Cache**: Redis 6.0+
- **Queue**: Redis Queue / Database Queue
- **Authentication**: Laravel Sanctum
- **File Storage**: Laravel Storage (Local/S3)

#### Frontend (User App)
- **Framework**: Flutter 3.13+
- **Language**: Dart 3.1+
- **State Management**: Provider / Riverpod
- **HTTP Client**: Dio 5.0+
- **Local Storage**: SQLite / Hive
- **Authentication**: JWT Token
- **Platforms**: Android, iOS, Web

#### Infrastructure
- **Web Server**: Nginx 1.20+
- **Process Manager**: Supervisor
- **Monitoring**: Laravel Telescope + Custom
- **Logging**: Laravel Log + ELK Stack
- **CI/CD**: GitHub Actions
- **Containerization**: Docker (Optional)

---

## Installation & Setup

### Prerequisites
```bash
# System packages
sudo apt update
sudo apt install -y nginx mysql-server redis-server supervisor

# PHP 8.1
sudo apt install -y php8.1-fpm php8.1-mysql php8.1-xml php8.1-mbstring
sudo apt install -y php8.1-curl php8.1-zip php8.1-gd php8.1-bcmath

# Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Node.js (for asset compilation)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.0-stable.tar.xz
tar xf flutter_linux_3.13.0-stable.tar.xz
sudo mv flutter /opt/flutter
export PATH="$PATH:/opt/flutter/bin"
```

### Admin Panel Setup
```bash
# Clone repository
git clone https://github.com/cihuy/platform.git
cd platform/admin

# Install dependencies
composer install
npm install

# Environment setup
cp .env.example .env
# Edit .env with your configuration

# Database setup
php artisan migrate --seed

# Generate application key
php artisan key:generate

# Storage link
php artisan storage:link

# Build assets
npm run build

# Set permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 755 storage bootstrap/cache
```

### User App Setup
```bash
cd ../user

# Install Flutter dependencies
flutter pub get

# Generate code (if using code generation)
flutter packages pub run build_runner build

# Run on specific platform
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

### Database Setup
```sql
-- Create database
CREATE DATABASE cihuy_platform CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user
CREATE USER 'cihuy_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON cihuy_platform.* TO 'cihuy_user'@'localhost';
FLUSH PRIVILEGES;
```

---

## Configuration

### Environment Variables (.env)
```env
# Application
APP_NAME="Cihuy Platform"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://admin.cihuy.com
APP_KEY=base64:your-app-key-here

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=cihuy_platform
DB_USERNAME=cihuy_user
DB_PASSWORD=secure_password

# Cache
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Mail
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=noreply@cihuy.com
MAIL_PASSWORD=app_password
MAIL_ENCRYPTION=tls

# File Storage
FILESYSTEM_DISK=local
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=

# Security
SANCTUM_STATEFUL_DOMAINS=admin.cihuy.com,app.cihuy.com
SESSION_DOMAIN=.cihuy.com
```

### Nginx Configuration
```nginx
server {
    listen 80;
    server_name admin.cihuy.com;
    root /var/www/cihuy/admin/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

### Flutter Configuration
```yaml
# pubspec.yaml
name: cihuy_user_app
description: Cihuy User Mobile Application
version: 1.0.0+1

environment:
  sdk: '>=3.1.0 <4.0.0'
  flutter: ">=3.13.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.0
  
  # HTTP Client
  dio: ^5.0.0
  
  # Local Storage
  shared_preferences: ^2.0.0
  sqflite: ^2.0.0
  
  # UI Components
  cupertino_icons: ^1.0.0
```

---

## API Reference

### Authentication Endpoints
```http
POST /api/auth/login
Content-Type: application/json

{
    "email": "user@example.com",
    "password": "password123"
}

Response:
{
    "success": true,
    "data": {
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "user@example.com"
        }
    }
}
```

### User Management
```http
GET /api/users
Authorization: Bearer {token}
Query Parameters:
- page: integer (default: 1)
- per_page: integer (default: 15)
- search: string (optional)
- role: string (optional)

Response:
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "role": "admin",
            "created_at": "2025-01-01T00:00:00Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "total": 100,
        "per_page": 15
    }
}
```

### Content Management
```http
POST /api/content
Authorization: Bearer {token}
Content-Type: application/json

{
    "title": "Content Title",
    "description": "Content Description",
    "type": "article",
    "status": "published"
}

Response:
{
    "success": true,
    "data": {
        "id": 1,
        "title": "Content Title",
        "description": "Content Description",
        "type": "article",
        "status": "published",
        "created_at": "2025-01-01T00:00:00Z"
    }
}
```

### Error Response Format
```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."],
        "password": ["The password must be at least 8 characters."]
    }
}
```

---

## Development Guidelines

### Code Standards

#### PHP (Laravel)
```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Http\Requests\StoreUserRequest;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    /**
     * Display a listing of users.
     */
    public function index(): JsonResponse
    {
        $users = User::with('profile')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    /**
     * Store a newly created user.
     */
    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = User::create($request->validated());

        return response()->json([
            'success' => true,
            'data' => $user,
        ], 201);
    }
}
```

#### Dart (Flutter)
```dart
import 'package:flutter/material.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({
    super.key,
    required this.user,
    this.onEdit,
  });

  final User user;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(user.email),
            if (onEdit != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onEdit,
                child: const Text('Edit Profile'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Testing

#### PHP Unit Tests
```php
<?php

namespace Tests\Unit;

use App\Models\User;
use App\Services\AuthService;
use Tests\TestCase;

class AuthServiceTest extends TestCase
{
    public function test_user_can_login_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123'),
        ]);
        
        $authService = new AuthService();
        $result = $authService->login('test@example.com', 'password123');

        $this->assertTrue($result->success);
        $this->assertNotNull($result->token);
    }
}
```

#### Flutter Widget Tests
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cihuy_user_app/widgets/user_profile_widget.dart';

void main() {
  group('UserProfileWidget', () {
    testWidgets('displays user name and email', (WidgetTester tester) async {
      const user = User(name: 'John Doe', email: 'john@example.com');
      
      await tester.pumpWidget(
        MaterialApp(
          home: UserProfileWidget(user: user),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });
  });
}
```

---

## Deployment

### Production Checklist
- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] SSL certificates installed
- [ ] Web server configured
- [ ] Monitoring setup
- [ ] Backup strategy implemented
- [ ] Security headers configured
- [ ] Performance optimization applied

### Deployment Script
```bash
#!/bin/bash
# deploy.sh

echo "Starting deployment..."

# Pull latest code
git pull origin main

# Install/update dependencies
cd admin
composer install --no-dev --optimize-autoloader
npm ci --production

# Build assets
npm run build

# Run migrations
php artisan migrate --force

# Clear caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 755 storage bootstrap/cache

# Restart services
sudo systemctl reload nginx
sudo systemctl restart php8.1-fpm

echo "Deployment completed!"
```

### Docker Deployment (Optional)
```dockerfile
# Dockerfile.admin
FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www/storage

EXPOSE 9000
CMD ["php-fpm"]
```

---

## Monitoring & Maintenance

### Application Monitoring
```php
// config/telescope.php
'watchers' => [
    Watchers\CacheWatcher::class => true,
    Watchers\CommandWatcher::class => true,
    Watchers\ExceptionWatcher::class => true,
    Watchers\JobWatcher::class => true,
    Watchers\LogWatcher::class => true,
    Watchers\MailWatcher::class => true,
    Watchers\ModelWatcher::class => true,
    Watchers\NotificationWatcher::class => true,
    Watchers\QueryWatcher::class => true,
    Watchers\RedisWatcher::class => true,
    Watchers\RequestWatcher::class => true,
    Watchers\GateWatcher::class => true,
    Watchers\ScheduleWatcher::class => true,
    Watchers\ViewWatcher::class => true,
],
```

### Log Monitoring
```bash
# View application logs
tail -f storage/logs/laravel.log

# View nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# View system logs
journalctl -u nginx -f
journalctl -u php8.1-fpm -f
```

### Performance Monitoring
```php
// Custom performance monitoring
class PerformanceMonitor
{
    public function logSlowQueries($query, $time)
    {
        if ($time > 1000) { // 1 second
            Log::warning('Slow query detected', [
                'query' => $query,
                'time' => $time,
            ]);
        }
    }
}
```

### Backup Strategy
```bash
#!/bin/bash
# backup.sh

# Database backup
mysqldump -u cihuy_user -p cihuy_platform > backup_$(date +%Y%m%d_%H%M%S).sql

# File backup
tar -czf files_backup_$(date +%Y%m%d_%H%M%S).tar.gz storage/app/public

# Upload to cloud storage
aws s3 cp backup_*.sql s3://cihuy-backups/database/
aws s3 cp files_backup_*.tar.gz s3://cihuy-backups/files/
```

---

## Security

### Authentication & Authorization
```php
// JWT Token configuration
'jwt' => [
    'secret' => env('JWT_SECRET'),
    'ttl' => 60 * 24, // 24 hours
    'refresh_ttl' => 60 * 24 * 7, // 7 days
    'algo' => 'HS256',
],

// Rate limiting
'rate_limiting' => [
    'login' => '5,1', // 5 attempts per minute
    'api' => '100,1', // 100 requests per minute
],
```

### Security Headers
```php
// Security middleware
class SecurityHeaders
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);
        
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'DENY');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('Strict-Transport-Security', 'max-age=31536000');
        
        return $response;
    }
}
```

### Data Encryption
```php
// Encrypt sensitive data
use Illuminate\Support\Facades\Crypt;

$encrypted = Crypt::encryptString('sensitive data');
$decrypted = Crypt::decryptString($encrypted);
```

---

## Troubleshooting

### Common Issues

#### Database Connection Issues
```bash
# Check database connection
php artisan tinker
>>> DB::connection()->getPdo();

# Test database connection
php artisan migrate:status

# Check database logs
tail -f /var/log/mysql/error.log
```

#### Performance Issues
```bash
# Check PHP-FPM status
sudo systemctl status php8.1-fpm

# Check memory usage
free -h
ps aux --sort=-%mem | head

# Check disk usage
df -h
du -sh /var/www/cihuy/*
```

#### Flutter Build Issues
```bash
# Clean Flutter build
flutter clean
flutter pub get

# Check Flutter doctor
flutter doctor -v

# Check Android SDK
flutter doctor --android-licenses
```

### Debug Commands
```bash
# Laravel debugging
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Flutter debugging
flutter run --verbose
flutter logs
flutter doctor -v
```

---

## Support & Resources

### Technical Support
- **Email**: projectsfikri@gmail.com
- **GitHub Issues**: [github.com/cihuy/platform/issues](https://github.com/cihuy/platform/issues)
- **Documentation**: [docs.cihuy.com](https://docs.cihuy.com)

### Development Resources
- **Laravel Documentation**: [laravel.com/docs](https://laravel.com/docs)
- **Flutter Documentation**: [flutter.dev/docs](https://flutter.dev/docs)
- **API Documentation**: [api.cihuy.com/docs](https://api.cihuy.com/docs)

---

**© 2025 Fikri Hidayat Platform. All rights reserved.**

*This technical documentation is intended for developers and system administrators. For user guides, please refer to the User Guide documentation.*

