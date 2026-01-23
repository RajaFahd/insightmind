@echo off
echo ========================================
echo InsightMind Backend Setup
echo ========================================
echo.

cd backend

echo [1/4] Installing Composer dependencies...
call composer install
echo.

echo [2/4] Running database migrations...
call php artisan migrate
echo.

echo [3/4] Seeding admin user...
call php artisan db:seed --class=AdminSeeder
echo.

echo [4/4] Setup complete!
echo.
echo Admin credentials:
echo Email: admin@admin.com
echo Password: admin123
echo.
echo To start the server, run:
echo   php artisan serve
echo.
pause
