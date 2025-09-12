# Contributing to Cihuy Platform

Terima kasih telah mempertimbangkan untuk berkontribusi pada Cihuy Platform!

## Daftar Isi

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Documentation](#documentation)

## Code of Conduct

### Our Pledge
Kami berkomitmen untuk menciptakan lingkungan yang inklusif dan ramah untuk semua kontributor, terlepas dari:
- Usia, ukuran tubuh, disabilitas, etnis
- Karakteristik seks, identitas gender dan ekspresi
- Level pengalaman, pendidikan, status sosial-ekonomi
- Kebangsaan, penampilan, ras, agama
- Orientasi seksual

### Expected Behavior
- Gunakan bahasa yang ramah dan inklusif
- Hormati perbedaan pendapat dan pengalaman
- Terima kritik konstruktif dengan baik
- Fokus pada yang terbaik untuk komunitas
- Tunjukkan empati kepada anggota komunitas lain

### Unacceptable Behavior
- Penggunaan bahasa atau gambar yang seksual
- Trolling, komentar menghina/merendahkan, serangan pribadi atau politik
- Pelecehan publik atau pribadi
- Publikasi informasi pribadi tanpa izin
- Perilaku lain yang tidak pantas dalam lingkungan profesional

## Getting Started

### Prerequisites
- Git 2.0+
- PHP 8.0+ dengan Composer (untuk admin panel)
- Flutter SDK 3.0+ (untuk user app)
- Database (MySQL/PostgreSQL)
- IDE/Editor (VSCode, Android Studio, atau pilihan Anda)

### Setup Development Environment

#### 1. Fork Repository
```bash
# Fork repository di GitHub, lalu clone
git clone https://github.com/YOUR_USERNAME/cihuy-platform.git
cd cihuy-platform
```

#### 2. Add Upstream Remote
```bash
git remote add upstream https://github.com/cihuy/platform.git
```

#### 3. Setup Admin Panel
```bash
cd admin
composer install
cp .env.example .env
# Edit .env dengan konfigurasi development
php artisan migrate --seed
php artisan serve
```

#### 4. Setup User App
```bash
cd user
flutter pub get
flutter run
```

#### 5. Verify Setup
- Admin Panel: http://localhost:8000
- User App: Running di device/emulator
- API: http://localhost:8000/api

## Development Process

### Branch Strategy
- `main`: Branch utama untuk production
- `develop`: Branch development utama
- `feature/*`: Feature branches
- `bugfix/*`: Bug fix branches
- `hotfix/*`: Hotfix untuk production

### Workflow
1. **Sync** dengan upstream: `git fetch upstream && git merge upstream/main`
2. **Create** feature branch: `git checkout -b feature/amazing-feature`
3. **Develop** dengan mengikuti coding standards
4. **Test** perubahan secara menyeluruh
5. **Commit** dengan conventional commits
6. **Push** ke fork: `git push origin feature/amazing-feature`
7. **Create** Pull Request

### Conventional Commits
```bash
# Format: type(scope): description
feat(auth): add biometric authentication
fix(api): resolve user login timeout issue
docs(readme): update installation instructions
style(ui): improve button hover effects
refactor(db): optimize user query performance
test(auth): add unit tests for login service
chore(deps): update flutter dependencies
```

## Coding Standards

### PHP (Admin Panel)
```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    /**
     * Display a listing of users.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $users = User::with('profile')
            ->when($request->search, function ($query, $search) {
                return $query->where('name', 'like', "%{$search}%");
            })
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }
}
```

**Standards:**
- Follow PSR-12 coding standards
- Use type hints untuk parameters dan return types
- Add PHPDoc comments untuk semua public methods
- Use meaningful variable dan function names
- Keep methods small dan focused (max 20 lines)

### Dart/Flutter (User App)
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

**Standards:**
- Follow Dart style guide
- Use `const` constructors whenever possible
- Add documentation untuk public APIs
- Use meaningful variable names
- Keep widgets small dan focused

### Git Standards
```bash
# Good commit messages
feat(auth): add OAuth2 integration
fix(api): resolve CORS issue for mobile app
docs(readme): add deployment instructions

# Bad commit messages
fix bug
update
changes
```

## Testing Guidelines

### Test Structure
```
tests/
├── Unit/           # Unit tests
├── Feature/        # Feature tests
├── Integration/    # Integration tests
└── Browser/        # Browser tests (admin panel)
```

### PHP Testing (Admin Panel)
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
        // Arrange
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123'),
        ]);
        
        $authService = new AuthService();

        // Act
        $result = $authService->login('test@example.com', 'password123');

        // Assert
        $this->assertTrue($result->success);
        $this->assertNotNull($result->token);
    }
}
```

### Flutter Testing (User App)
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cihuy_user_app/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should return token when login with valid credentials', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      // Act
      final result = await authService.login(email, password);

      // Assert
      expect(result.isSuccess, true);
      expect(result.token, isNotNull);
    });
  });
}
```

### Test Coverage
- **Minimum**: 80% code coverage
- **Critical paths**: 100% coverage
- **New features**: Must include tests
- **Bug fixes**: Must include regression tests

## Pull Request Process

### Before Submitting
- [ ] Code follows coding standards
- [ ] All tests pass
- [ ] New features have tests
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Branch is up to date with main

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
```

### Review Process
1. **Automated checks** must pass
2. **Code review** by at least 2 maintainers
3. **Testing** by QA team (if applicable)
4. **Documentation** review
5. **Approval** and merge

## Issue Reporting

### Bug Reports
```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- OS: [e.g. Windows 10, macOS 12]
- Browser: [e.g. Chrome 90, Safari 14]
- Version: [e.g. 1.0.0]

**Additional context**
Any other context about the problem.
```

### Feature Requests
```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
A clear description of any alternative solutions.

**Additional context**
Add any other context or screenshots.
```

## Documentation

### Code Documentation
- **PHPDoc** untuk PHP functions/methods
- **DartDoc** untuk Dart classes/methods
- **README** files untuk setiap module
- **API documentation** untuk endpoints

### Documentation Standards
- Use clear, concise language
- Include code examples
- Add screenshots for UI changes
- Keep documentation up to date
- Use proper Markdown formatting

### Updating Documentation
1. Update relevant README files
2. Add/update API documentation
3. Update CHANGELOG.md
4. Add migration guides for breaking changes

## Release Process

### Version Numbering
- **Major** (1.0.0): Breaking changes
- **Minor** (0.1.0): New features, backward compatible
- **Patch** (0.0.1): Bug fixes, backward compatible

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version numbers updated
- [ ] Release notes prepared
- [ ] Tag created
- [ ] Release published

## Questions?

### Getting Help
- **GitHub Discussions**: For general questions
- **Discord**: For real-time chat
- **Email**: dev@cihuy.com for specific issues
- **Documentation**: Check existing docs first

### Mentorship
- New contributors can request mentorship
- Experienced contributors can volunteer as mentors
- Pair programming sessions available

## Recognition

### Contributors
- All contributors will be listed in CONTRIBUTORS.md
- Significant contributions will be highlighted
- Regular contributors may be invited to maintainer team

### Hall of Fame
- **Top Contributors**: Most commits/PRs
- **Bug Hunters**: Most bug reports fixed
- **Documentation Heroes**: Most documentation improvements
- **Community Champions**: Most helpful in discussions

---

**Thank you for contributing to Cihuy Platform!**

*This contributing guide is inspired by best practices from the open source community.*

