<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create a test user with the credentials from the Flutter app
        User::create([
            'name' => 'Test User',
            'email' => 'laravel@cihuy.com',
            'password' => Hash::make('password'),
            'email_verified_at' => now(),
        ]);

        // Also create the default factory user
        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);
    }
}
