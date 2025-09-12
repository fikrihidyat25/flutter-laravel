<?php

use Illuminate\Support\Facades\Route;

// Option 1: Direct redirect to admin panel
Route::get('/', function () {
    return redirect('/admin');
});

// Option 2: Landing page (uncomment if you want landing page instead)
// Route::get('/', function () {
//     return view('admin-landing');
// });
