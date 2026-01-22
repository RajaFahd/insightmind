<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - InsightMind</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <meta name="csrf-token" content="{{ csrf_token() }}">
</head>
<body class="bg-gray-100 min-h-screen">
    <!-- Sidebar -->
    <div class="flex">
        <aside class="w-64 bg-gradient-to-b from-orange-500 to-orange-600 min-h-screen fixed">
            <div class="p-6">
                <h1 class="text-white text-2xl font-bold">InsightMind</h1>
                <p class="text-orange-200 text-sm">Admin Panel</p>
            </div>
            <nav class="mt-6">
                <a href="{{ route('admin.dashboard') }}" class="flex items-center px-6 py-3 text-white bg-orange-600 border-l-4 border-white">
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
                <a href="{{ route('admin.questions') }}" class="flex items-center px-6 py-3 text-orange-100 hover:bg-orange-600 transition">
                    <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    Kelola Soal
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
            <!-- Header -->
            <div class="flex justify-between items-center mb-8">
                <div>
                    <h2 class="text-3xl font-bold text-gray-800">Dashboard</h2>
                    <p class="text-gray-600">Selamat datang, {{ session('admin_name', 'Admin') }}!</p>
                </div>
                <div class="flex items-center space-x-4">
                    <!-- Notification Bell -->
                    <div class="relative" id="notificationDropdown">
                        <button onclick="toggleNotifications()" class="relative p-2 bg-white rounded-full shadow-md hover:bg-gray-50 transition">
                            <svg class="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                            </svg>
                            @if($unreadCount > 0)
                            <span id="notificationBadge" class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                                {{ $unreadCount > 9 ? '9+' : $unreadCount }}
                            </span>
                            @endif
                        </button>
                        
                        <!-- Notification Panel -->
                        <div id="notificationPanel" class="hidden absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-lg z-50 overflow-hidden">
                            <div class="p-4 bg-orange-500 text-white flex justify-between items-center">
                                <h3 class="font-bold">Notifikasi</h3>
                                @if($unreadCount > 0)
                                <form action="{{ route('admin.notifications.read-all') }}" method="POST" class="inline">
                                    @csrf
                                    <button type="submit" class="text-sm hover:underline">Tandai semua dibaca</button>
                                </form>
                                @endif
                            </div>
                            <div class="max-h-96 overflow-y-auto">
                                @forelse($notifications as $notif)
                                <div class="p-4 border-b hover:bg-gray-50 {{ $notif->is_read ? 'opacity-60' : '' }}">
                                    <div class="flex justify-between items-start">
                                        <div class="flex-1">
                                            <p class="font-semibold text-gray-800 text-sm">{{ $notif->title }}</p>
                                            <p class="text-gray-600 text-xs mt-1">{{ $notif->message }}</p>
                                            <p class="text-gray-400 text-xs mt-2">{{ $notif->created_at->diffForHumans() }}</p>
                                        </div>
                                        @if(!$notif->is_read)
                                        <form action="{{ route('admin.notification.read', $notif->id) }}" method="POST">
                                            @csrf
                                            <button type="submit" class="text-orange-500 hover:text-orange-600">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                                                </svg>
                                            </button>
                                        </form>
                                        @endif
                                    </div>
                                </div>
                                @empty
                                <div class="p-4 text-center text-gray-500">
                                    <svg class="w-12 h-12 mx-auto text-gray-300 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/>
                                    </svg>
                                    <p class="text-sm">Tidak ada notifikasi baru</p>
                                </div>
                                @endforelse
                            </div>
                        </div>
                    </div>
                    <div class="text-right">
                        <p class="text-gray-500 text-sm">{{ now()->format('l, d F Y') }}</p>
                        <p class="text-gray-400 text-xs" id="currentTime">{{ now()->format('H:i:s') }}</p>
                    </div>
                </div>
            </div>

            <!-- Stats Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <div class="bg-white rounded-xl shadow-md p-6">
                    <div class="flex items-center">
                        <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                            <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                            </svg>
                        </div>
                        <div>
                            <p class="text-gray-500 text-sm">Total User</p>
                            <p class="text-2xl font-bold text-gray-800" id="totalUsers">{{ $totalUsers }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-md p-6">
                    <div class="flex items-center">
                        <div class="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mr-4">
                            <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                            </svg>
                        </div>
                        <div>
                            <p class="text-gray-500 text-sm">Total Screening</p>
                            <p class="text-2xl font-bold text-gray-800" id="totalScreenings">{{ $totalScreenings }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-md p-6">
                    <div class="flex items-center">
                        <div class="w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center mr-4">
                            <svg class="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                        <div>
                            <p class="text-gray-500 text-sm">User Baru (Hari Ini)</p>
                            <p class="text-2xl font-bold text-gray-800">{{ \App\Models\User::whereDate('created_at', today())->count() }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-xl shadow-md p-6">
                    <div class="flex items-center">
                        <div class="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center mr-4">
                            <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"/>
                            </svg>
                        </div>
                        <div>
                            <p class="text-gray-500 text-sm">Screening (Hari Ini)</p>
                            <p class="text-2xl font-bold text-gray-800">{{ \App\Models\ScreeningResult::whereDate('created_at', today())->count() }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Daily Screening Chart -->
            <div class="bg-white rounded-xl shadow-md p-6 mb-8">
                <h3 class="text-lg font-bold text-gray-800 mb-4">Statistik Screening (7 Hari Terakhir)</h3>
                <div class="h-64">
                    <canvas id="dailyChart"></canvas>
                </div>
            </div>

            <!-- Recent Data -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Recent Users -->
                <div class="bg-white rounded-xl shadow-md p-6">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-bold text-gray-800">User Terbaru</h3>
                        <a href="{{ route('admin.users') }}" class="text-orange-500 hover:text-orange-600 text-sm">Lihat Semua →</a>
                    </div>
                    <div class="space-y-4">
                        @forelse($recentUsers as $user)
                        <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                            <div class="flex items-center">
                                <div class="w-10 h-10 bg-orange-200 rounded-full flex items-center justify-center mr-3">
                                    <span class="text-orange-600 font-bold">{{ strtoupper(substr($user->name, 0, 1)) }}</span>
                                </div>
                                <div>
                                    <p class="font-semibold text-gray-800">{{ $user->name }}</p>
                                    <p class="text-gray-500 text-sm">{{ $user->email }}</p>
                                </div>
                            </div>
                            <span class="text-gray-400 text-xs">{{ $user->created_at->diffForHumans() }}</span>
                        </div>
                        @empty
                        <p class="text-gray-500 text-center py-4">Belum ada user</p>
                        @endforelse
                    </div>
                </div>

                <!-- Recent Screenings -->
                <div class="bg-white rounded-xl shadow-md p-6">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-bold text-gray-800">Screening Terbaru</h3>
                        <a href="{{ route('admin.screenings') }}" class="text-orange-500 hover:text-orange-600 text-sm">Lihat Semua →</a>
                    </div>
                    <div class="space-y-4">
                        @forelse($recentScreenings as $screening)
                        <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                            <div>
                                <p class="font-semibold text-gray-800">{{ $screening->user->name ?? 'Unknown' }}</p>
                                <p class="text-gray-500 text-sm">{{ $screening->result_category }}</p>
                            </div>
                            <div class="text-right">
                                <span class="px-3 py-1 bg-orange-100 text-orange-600 rounded-full text-sm font-semibold">
                                    Score: {{ $screening->total_score }}
                                </span>
                                <p class="text-gray-400 text-xs mt-1">{{ $screening->created_at->diffForHumans() }}</p>
                            </div>
                        </div>
                        @empty
                        <p class="text-gray-500 text-center py-4">Belum ada screening</p>
                        @endforelse
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Toggle notification panel
        function toggleNotifications() {
            const panel = document.getElementById('notificationPanel');
            panel.classList.toggle('hidden');
        }

        // Close notification panel when clicking outside
        document.addEventListener('click', function(event) {
            const dropdown = document.getElementById('notificationDropdown');
            const panel = document.getElementById('notificationPanel');
            if (!dropdown.contains(event.target)) {
                panel.classList.add('hidden');
            }
        });

        // Update current time
        function updateTime() {
            const now = new Date();
            const timeString = now.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
            document.getElementById('currentTime').textContent = timeString;
        }
        setInterval(updateTime, 1000);

        // Daily Screening Chart
        const dailyData = @json($dailyData);
        const ctx = document.getElementById('dailyChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: dailyData.map(d => d.date + '\n(' + d.day + ')'),
                datasets: [{
                    label: 'Jumlah Screening',
                    data: dailyData.map(d => d.count),
                    backgroundColor: 'rgba(249, 115, 22, 0.8)',
                    borderColor: 'rgba(249, 115, 22, 1)',
                    borderWidth: 1,
                    borderRadius: 8,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1
                        }
                    }
                }
            }
        });

        // Auto refresh data every 30 seconds
        setInterval(function() {
            fetch('{{ route('admin.notifications') }}')
                .then(response => response.json())
                .then(data => {
                    const badge = document.getElementById('notificationBadge');
                    if (data.unread_count > 0) {
                        if (!badge) {
                            location.reload();
                        } else {
                            badge.textContent = data.unread_count > 9 ? '9+' : data.unread_count;
                        }
                    }
                })
                .catch(err => console.log('Auto-refresh error:', err));
        }, 30000);
    </script>
</body>
</html>
