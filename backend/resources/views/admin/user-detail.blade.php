<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail User - InsightMind Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen">
    <div class="flex">
        <!-- Sidebar -->
        <aside class="w-64 bg-gradient-to-b from-orange-500 to-orange-600 min-h-screen fixed">
            <div class="p-6">
                <h1 class="text-white text-2xl font-bold">InsightMind</h1>
                <p class="text-orange-200 text-sm">Admin Panel</p>
            </div>
            <nav class="mt-6">
                <a href="{{ route('admin.dashboard') }}" class="flex items-center px-6 py-3 text-orange-100 hover:bg-orange-600 transition">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>
                    </svg>
                    Dashboard
                </a>
                <a href="{{ route('admin.users') }}" class="flex items-center px-6 py-3 text-white bg-orange-600 border-l-4 border-white">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                    </svg>
                    Kelola User
                </a>
                <a href="{{ route('admin.screenings') }}" class="flex items-center px-6 py-3 text-orange-100 hover:bg-orange-600 transition">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                    </svg>
                    Hasil Screening
                </a>
            </nav>
            <div class="absolute bottom-0 w-full p-6">
                <a href="{{ route('admin.logout') }}" class="flex items-center text-orange-100 hover:text-white transition">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                    </svg>
                    Logout
                </a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 ml-64 p-8">
            <div class="mb-6">
                <a href="{{ route('admin.users') }}" class="text-orange-500 hover:text-orange-600">
                    ← Kembali ke Daftar User
                </a>
            </div>

            <!-- User Info Card -->
            <div class="bg-white rounded-xl shadow-md p-6 mb-6">
                <div class="flex items-center">
                    <div class="w-20 h-20 bg-orange-200 rounded-full flex items-center justify-center mr-6">
                        <span class="text-orange-600 font-bold text-3xl">{{ strtoupper(substr($user->name, 0, 1)) }}</span>
                    </div>
                    <div>
                        <h2 class="text-2xl font-bold text-gray-800">{{ $user->name }}</h2>
                        <p class="text-gray-600">{{ $user->email }}</p>
                        <p class="text-gray-500 text-sm mt-1">Terdaftar: {{ $user->created_at->format('d F Y, H:i') }}</p>
                    </div>
                </div>
            </div>

            <!-- Screening History -->
            <div class="bg-white rounded-xl shadow-md p-6">
                <h3 class="text-xl font-bold text-gray-800 mb-4">Riwayat Screening</h3>
                
                @if($user->screeningResults->count() > 0)
                <div class="space-y-4">
                    @foreach($user->screeningResults as $screening)
                    <div class="border border-gray-200 rounded-lg p-4">
                        <div class="flex justify-between items-start">
                            <div>
                                <span class="px-3 py-1 bg-orange-100 text-orange-600 rounded-full text-sm font-semibold">
                                    {{ $screening->result_category }}
                                </span>
                                <p class="text-gray-600 mt-2">{{ $screening->result_description }}</p>
                            </div>
                            <div class="text-right">
                                <p class="text-2xl font-bold text-gray-800">{{ $screening->total_score }}</p>
                                <p class="text-gray-500 text-sm">Skor</p>
                            </div>
                        </div>
                        <p class="text-gray-400 text-xs mt-3">{{ $screening->created_at->format('d F Y, H:i') }}</p>
                    </div>
                    @endforeach
                </div>
                @else
                <p class="text-gray-500 text-center py-8">User ini belum melakukan screening</p>
                @endif
            </div>
        </main>
    </div>
</body>
</html>
