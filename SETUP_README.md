# InsightMind - Mental Health Screening App

A Flutter application with Laravel backend for mental health screening and management.

## Project Structure

```
PAM UAS/
├── backend/          # Laravel backend API
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── ...
├── lib/             # Flutter application
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── main.dart
└── ...
```

## Backend Setup (Laravel)

### Prerequisites
- PHP >= 8.2
- Composer
- SQLite extension enabled

### Installation

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
composer install
```

3. The `.env` file should already be created. Verify database connection is set to SQLite.

4. Run migrations:
```bash
php artisan migrate
```

5. Seed the database with admin user:
```bash
php artisan db:seed --class=AdminSeeder
```

This will create an admin account with:
- **Email:** admin@admin.com
- **Password:** admin123

6. Start the Laravel development server:
```bash
php artisan serve
```

The API will be available at `http://localhost:8000`

### API Endpoints

#### Public Endpoints
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/admin/login` - Admin login

#### Protected User Endpoints (requires authentication token)
- `POST /api/logout` - User logout
- `GET /api/me` - Get authenticated user
- `POST /api/screening` - Save screening result
- `GET /api/screening/history` - Get user's screening history
- `GET /api/screening/{id}` - Get specific screening result
- `DELETE /api/screening/{id}` - Delete screening result

#### Protected Admin Endpoints (requires admin authentication token)
- `POST /api/admin/logout` - Admin logout
- `GET /api/admin/me` - Get authenticated admin
- `GET /api/admin/users` - Get all users
- `POST /api/admin/users` - Create new user
- `GET /api/admin/users/{id}` - Get specific user
- `PUT /api/admin/users/{id}` - Update user
- `DELETE /api/admin/users/{id}` - Delete user

## Frontend Setup (Flutter)

### Prerequisites
- Flutter SDK >= 3.10.0
- Dart SDK

### Installation

1. From the root directory (PAM UAS), install Flutter dependencies:
```bash
flutter pub get
```

2. Update the API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8000/api';
```

For local development:
- Android Emulator: Use `http://10.0.2.2:8000/api`
- iOS Simulator: Use `http://localhost:8000/api`
- Physical Device: Use your computer's IP address (e.g., `http://192.168.1.100:8000/api`)

3. Run the Flutter app:
```bash
flutter run
```

### Features

#### User Features
- User registration and login
- Mental health screening questionnaire
- View screening history
- User profile management

#### Admin Features
- Admin login (credentials displayed on login page)
- User management (view, edit, delete users)
- View all screening results
- Dashboard with statistics

### Admin Access

To access the admin panel:
1. From the login screen, tap "Login sebagai Admin" at the bottom
2. Use the credentials displayed below the login button:
   - **Email:** admin@admin.com
   - **Password:** admin123

## Database Schema

### Users Table
- id (primary key)
- name
- email (unique)
- password (hashed)
- created_at
- updated_at

### Admins Table
- id (primary key)
- name
- email (unique)
- password (hashed)
- created_at
- updated_at

### Screening Results Table
- id (primary key)
- user_id (foreign key to users)
- answers (JSON)
- result_category
- result_description
- total_score
- created_at
- updated_at

## Development Notes

### Authentication
The app uses Laravel Sanctum for API token authentication. Tokens are stored in SharedPreferences on the Flutter side.

### CORS
CORS is configured to allow all origins for development. For production, update `backend/config/cors.php` to restrict allowed origins.

### Error Handling
All API responses follow this format:
```json
{
  "success": true/false,
  "message": "Response message",
  "data": {...}
}
```

## Troubleshooting

### Backend Issues
- If migrations fail, delete `backend/database/database.sqlite` and run migrations again
- Make sure SQLite extension is enabled in your php.ini
- Check Laravel logs in `backend/storage/logs/laravel.log`

### Frontend Issues
- If API calls fail, verify the base URL in `api_service.dart`
- Check that the Laravel server is running
- For CORS errors, ensure CORS is properly configured in Laravel

### Connection Issues
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical devices, ensure both devices are on the same network
- Check firewall settings that might block the connection

## Production Deployment

### Backend
1. Update `.env` with production database credentials
2. Set `APP_ENV=production` and `APP_DEBUG=false`
3. Run `php artisan config:cache`
4. Run `php artisan route:cache`
5. Set up proper CORS configuration

### Frontend
1. Update API base URL to production server
2. Build the app: `flutter build apk` (Android) or `flutter build ios` (iOS)
3. Remove debug credentials from admin login screen (for security)

## License

This project is for educational purposes.
