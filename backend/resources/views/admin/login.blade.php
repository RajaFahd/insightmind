<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - InsightMind</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .gradient-bg {
            background: linear-gradient(135deg, #f5af19 0%, #f12711 100%);
        }
    </style>
</head>
<body class="min-h-screen gradient-bg flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-8">
        <!-- Logo/Icon -->
        <div class="flex justify-center mb-6">
            <div class="relative">
                <div class="w-32 h-32 bg-orange-200 rounded-full opacity-70"></div>
                <div class="absolute inset-0 flex items-center justify-center">
                    <div class="w-20 h-20 bg-orange-400 rounded-full flex items-center justify-center">
                        <svg class="w-12 h-12 text-orange-100" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>
                        </svg>
                    </div>
                </div>
            </div>
        </div>

        <h1 class="text-3xl font-bold text-gray-800 text-center mb-2">Admin Login</h1>
        <p class="text-orange-600 text-center mb-8">Masuk ke Dashboard Admin</p>

        <!-- Error Messages -->
        @if ($errors->any())
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg mb-6">
                @foreach ($errors->all() as $error)
                    <p class="text-sm">{{ $error }}</p>
                @endforeach
            </div>
        @endif

        <!-- Login Form -->
        <form action="{{ route('admin.login.submit') }}" method="POST">
            @csrf
            <div class="mb-6">
                <label class="block text-gray-600 text-sm mb-2">Email</label>
                <div class="relative">
                    <span class="absolute inset-y-0 left-0 flex items-center pl-3">
                        <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"/>
                        </svg>
                    </span>
                    <input type="email" name="email" value="{{ old('email') }}" 
                           class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-orange-500 transition"
                           placeholder="Masukkan email">
                </div>
            </div>

            <div class="mb-6">
                <label class="block text-gray-600 text-sm mb-2">Password</label>
                <div class="relative">
                    <span class="absolute inset-y-0 left-0 flex items-center pl-3">
                        <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                        </svg>
                    </span>
                    <input type="password" name="password" 
                           class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-orange-500 transition"
                           placeholder="Masukkan password">
                </div>
            </div>

            <button type="submit" 
                    class="w-full bg-gradient-to-r from-orange-400 to-orange-500 text-white py-3 rounded-full font-semibold hover:from-orange-500 hover:to-orange-600 transition shadow-lg">
                Login
            </button>
        </form>

        <!-- Credentials Info -->
        <div class="mt-6 bg-gray-100 rounded-lg p-4 border border-gray-200">
            <p class="text-gray-600 text-sm font-semibold mb-2">Kredensial Admin:</p>
            <p class="text-gray-500 text-sm font-mono">Email: admin@admin.com</p>
            <p class="text-gray-500 text-sm font-mono">Password: admin123</p>
        </div>
    </div>
</body>
</html>
