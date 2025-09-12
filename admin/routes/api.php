<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DebtController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::put('/user', [AuthController::class, 'updateProfile']);
    Route::put('/user/password', [AuthController::class, 'changePassword']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Transactions
    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store']);
    Route::put('/transactions/{id}', [TransactionController::class, 'update'])->whereNumber('id');
    // Place '/transactions/all' before '/transactions/{id}' to avoid route collision
    Route::delete('/transactions/all', [TransactionController::class, 'deleteAll']);
    Route::delete('/transactions/{id}', [TransactionController::class, 'destroy'])->whereNumber('id');
    Route::get('/transactions/balance', [TransactionController::class, 'getBalance']);
    Route::get('/transactions/credits', [TransactionController::class, 'getCredits']);
    
    // Category routes
    Route::get('/categories', [CategoryController::class, 'index']);

    // Debt routes
    Route::get('/debts', [DebtController::class, 'index']);
    Route::post('/debts', [DebtController::class, 'store']);
    // Place '/debts/all' before '/debts/{debt}' to avoid route collision
    Route::delete('/debts/all', [DebtController::class, 'deleteAll']);
    Route::patch('/debts/{id}', [DebtController::class, 'update'])->whereNumber('id');
    Route::delete('/debts/{id}', [DebtController::class, 'destroy'])->whereNumber('id');
    Route::get('/debts/total', [DebtController::class, 'getTotal']);
    

});
