<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminController;

Route::get('/', function () {
    if (session('admin_id')) {
        return redirect()->route('admin.dashboard');
    }
    return redirect()->route('admin.login');
});

// Admin Routes
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminController::class, 'showLogin'])->name('admin.login');
    Route::post('/login', [AdminController::class, 'login'])->name('admin.login.submit');
    
    Route::middleware('admin')->group(function () {
        Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('admin.dashboard');
        Route::get('/users', [AdminController::class, 'users'])->name('admin.users');
        Route::get('/users/{id}', [AdminController::class, 'userDetail'])->name('admin.user.detail');
        Route::delete('/users/{id}', [AdminController::class, 'deleteUser'])->name('admin.user.delete');
        Route::get('/screenings', [AdminController::class, 'screenings'])->name('admin.screenings');
        Route::get('/logout', [AdminController::class, 'logout'])->name('admin.logout');
        
        // Questions management routes
        Route::get('/questions', [AdminController::class, 'questions'])->name('admin.questions');
        Route::post('/questions', [AdminController::class, 'storeQuestion'])->name('admin.question.store');
        Route::put('/questions/{id}', [AdminController::class, 'updateQuestion'])->name('admin.question.update');
        Route::delete('/questions/{id}', [AdminController::class, 'deleteQuestion'])->name('admin.question.delete');
        Route::put('/questions/{id}/toggle', [AdminController::class, 'toggleQuestion'])->name('admin.question.toggle');
        
        // Notification routes
        Route::get('/notifications', [AdminController::class, 'getNotifications'])->name('admin.notifications');
        Route::post('/notifications/{id}/read', [AdminController::class, 'markNotificationRead'])->name('admin.notification.read');
        Route::post('/notifications/read-all', [AdminController::class, 'markAllNotificationsRead'])->name('admin.notifications.read-all');
    });
});
