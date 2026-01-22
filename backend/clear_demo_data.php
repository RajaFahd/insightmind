<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\ScreeningResult;

$user = User::where('email', 'rasyid@demo.com')->first();

if ($user) {
    $deleted = ScreeningResult::where('user_id', $user->id)->delete();
    echo "Deleted {$deleted} screening records for user: {$user->name} (ID: {$user->id})\n";
} else {
    echo "User not found\n";
}
