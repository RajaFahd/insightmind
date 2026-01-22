<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ScreeningController;
use App\Http\Controllers\Api\Admin\AuthController as AdminAuthController;
use App\Http\Controllers\Api\Admin\UserController as AdminUserController;
use App\Http\Controllers\Api\Admin\ScreeningQuestionController;
use App\Http\Controllers\Api\Admin\ScreeningResultController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected user routes (token-based)
Route::post('/logout', [AuthController::class, 'logout']);
Route::get('/me', [AuthController::class, 'me']);
Route::put('/profile', [AuthController::class, 'updateProfile']);
Route::post('/profile/picture', [AuthController::class, 'uploadProfilePicture']);
Route::delete('/profile/picture', [AuthController::class, 'deleteProfilePicture']);

// Screening routes
Route::prefix('screening')->group(function () {
    Route::post('/', [ScreeningController::class, 'store']);
    Route::get('/history', [ScreeningController::class, 'history']);
    Route::get('/{id}', [ScreeningController::class, 'show']);
    Route::delete('/{id}', [ScreeningController::class, 'destroy']);
});

// Get screening questions for users (public)
Route::get('/questions', [ScreeningQuestionController::class, 'index']);

// Admin routes
Route::prefix('admin')->group(function () {
    // Admin auth
    Route::post('/login', [AdminAuthController::class, 'login']);
    
    // Protected admin routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AdminAuthController::class, 'logout']);
        Route::get('/me', [AdminAuthController::class, 'me']);
        
        // User management
        Route::apiResource('users', AdminUserController::class);
        
        // Screening questions management
        Route::apiResource('screening-questions', ScreeningQuestionController::class);
        Route::post('/screening-questions/reorder', [ScreeningQuestionController::class, 'reorder']);
        Route::put('/screening-questions/{screeningQuestion}/toggle-active', [ScreeningQuestionController::class, 'toggleActive']);
        
        // Screening results management
        Route::get('/screening-results', [ScreeningResultController::class, 'index']);
        Route::get('/screening-results/{id}', [ScreeningResultController::class, 'show']);
        Route::delete('/screening-results/{id}', [ScreeningResultController::class, 'destroy']);
        Route::get('/statistics', [ScreeningResultController::class, 'statistics']);
    });
});
