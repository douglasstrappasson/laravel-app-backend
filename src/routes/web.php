<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return [
        'message' => 'Hello World', 
        'timezone' => config('app.timezone'), 
        'locale' => config('app.locale'),
        'Laravel' => app()->version()];
});

