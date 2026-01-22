<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hasil Screening - InsightMind Admin</title>
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
                <a href="{{ route('admin.users') }}" class="flex items-center px-6 py-3 text-orange-100 hover:bg-orange-600 transition">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                    </svg>
                    Kelola User
                </a>
                <a href="{{ route('admin.screenings') }}" class="flex items-center px-6 py-3 text-white bg-orange-600 border-l-4 border-white">
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
            <div class="flex justify-between items-center mb-8">
                <div>
                    <h2 class="text-3xl font-bold text-gray-800">Hasil Screening</h2>
                    <p class="text-gray-600">Semua hasil screening pengguna</p>
                </div>
            </div>

            <!-- Screenings Table -->
            <div class="bg-white rounded-xl shadow-md overflow-hidden">
                <table class="w-full">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">User</th>
                            <th class="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Kategori</th>
                            <th class="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Skor</th>
                            <th class="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Deskripsi</th>
                            <th class="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Tanggal</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200">
                        @forelse($screenings as $screening)
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap">
                                <div class="flex items-center">
                                    <div class="w-10 h-10 bg-orange-200 rounded-full flex items-center justify-center mr-3">
                                        <span class="text-orange-600 font-bold">{{ strtoupper(substr($screening->user->name ?? 'U', 0, 1)) }}</span>
                                    </div>
                                    <div>
                                        <span class="font-semibold text-gray-800">{{ $screening->user->name ?? 'Unknown' }}</span>
                                        <p class="text-gray-500 text-xs">{{ $screening->user->email ?? '' }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="px-3 py-1 bg-orange-100 text-orange-600 rounded-full text-sm font-semibold">
                                    {{ $screening->result_category }}
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="text-2xl font-bold text-gray-800">{{ $screening->total_score }}</span>
                            </td>
                            <td class="px-6 py-4">
                                <p class="text-gray-600 text-sm max-w-xs truncate">{{ $screening->result_description }}</p>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-gray-500">
                                {{ $screening->created_at->format('d M Y') }}<br>
                                <span class="text-xs">{{ $screening->created_at->format('H:i') }}</span>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="5" class="px-6 py-8 text-center text-gray-500">
                                Belum ada hasil screening
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>
