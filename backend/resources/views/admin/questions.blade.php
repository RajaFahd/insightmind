<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Soal - InsightMind Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <meta name="csrf-token" content="{{ csrf_token() }}">
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
                <a href="{{ route('admin.questions') }}" class="flex items-center px-6 py-3 text-white bg-orange-600 border-l-4 border-white">
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
            <div class="flex justify-between items-center mb-8">
                <div>
                    <h2 class="text-3xl font-bold text-gray-800">Kelola Soal Screening</h2>
                    <p class="text-gray-600">Tambah, edit, dan hapus pertanyaan screening</p>
                </div>
                <button onclick="openAddModal()" class="bg-orange-500 hover:bg-orange-600 text-white px-6 py-3 rounded-xl font-semibold transition flex items-center">
                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                    </svg>
                    Tambah Pertanyaan
                </button>
            </div>

            @if(session('success'))
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-lg mb-6">
                {{ session('success') }}
            </div>
            @endif

            <!-- Statistics -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                <div class="bg-white rounded-xl p-6 shadow-sm">
                    <div class="flex items-center">
                        <div class="bg-blue-100 p-3 rounded-lg">
                            <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-gray-500 text-sm">Total Soal</p>
                            <p class="text-2xl font-bold text-gray-800">{{ $questions->count() }}</p>
                        </div>
                    </div>
                </div>
                <div class="bg-white rounded-xl p-6 shadow-sm">
                    <div class="flex items-center">
                        <div class="bg-green-100 p-3 rounded-lg">
                            <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-gray-500 text-sm">Soal Aktif</p>
                            <p class="text-2xl font-bold text-gray-800">{{ $questions->where('is_active', true)->count() }}</p>
                        </div>
                    </div>
                </div>
                <div class="bg-white rounded-xl p-6 shadow-sm">
                    <div class="flex items-center">
                        <div class="bg-purple-100 p-3 rounded-lg">
                            <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"/>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-gray-500 text-sm">Kategori</p>
                            <p class="text-2xl font-bold text-gray-800">4</p>
                        </div>
                    </div>
                </div>
                <div class="bg-white rounded-xl p-6 shadow-sm">
                    <div class="flex items-center">
                        <div class="bg-orange-100 p-3 rounded-lg">
                            <svg class="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-gray-500 text-sm">Max Skor</p>
                            <p class="text-2xl font-bold text-gray-800">{{ $questions->where('is_active', true)->count() * 10 }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Questions Table -->
            <div class="bg-white rounded-xl shadow-sm overflow-hidden">
                <div class="p-6 border-b">
                    <h3 class="text-xl font-bold text-gray-800">Daftar Pertanyaan</h3>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">No</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Pertanyaan</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Kategori</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            @forelse($questions as $index => $question)
                            <tr class="hover:bg-gray-50">
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ $question->order }}</td>
                                <td class="px-6 py-4 text-sm text-gray-800 max-w-md">
                                    <div class="truncate" title="{{ $question->question_text }}">
                                        {{ Str::limit($question->question_text, 80) }}
                                    </div>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    @php
                                        $categoryColors = [
                                            'mental_health' => 'bg-blue-100 text-blue-800',
                                            'anxiety' => 'bg-orange-100 text-orange-800',
                                            'depression' => 'bg-purple-100 text-purple-800',
                                            'stress' => 'bg-red-100 text-red-800',
                                        ];
                                        $categoryLabels = [
                                            'mental_health' => 'Kesehatan Mental',
                                            'anxiety' => 'Kecemasan',
                                            'depression' => 'Depresi',
                                            'stress' => 'Stres',
                                        ];
                                    @endphp
                                    <span class="px-3 py-1 rounded-full text-xs font-semibold {{ $categoryColors[$question->category] ?? 'bg-gray-100 text-gray-800' }}">
                                        {{ $categoryLabels[$question->category] ?? $question->category }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    <form action="{{ route('admin.question.toggle', $question->id) }}" method="POST" class="inline">
                                        @csrf
                                        @method('PUT')
                                        <button type="submit" class="px-3 py-1 rounded-full text-xs font-semibold {{ $question->is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800' }}">
                                            {{ $question->is_active ? 'Aktif' : 'Nonaktif' }}
                                        </button>
                                    </form>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm">
                                    <button onclick="openEditModal({{ $question->id }}, '{{ addslashes($question->question_text) }}', '{{ $question->category }}', {{ json_encode($question->options) }})" class="text-blue-600 hover:text-blue-800 mr-3">
                                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                        </svg>
                                    </button>
                                    <form action="{{ route('admin.question.delete', $question->id) }}" method="POST" class="inline" onsubmit="return confirm('Apakah Anda yakin ingin menghapus pertanyaan ini?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="text-red-600 hover:text-red-800">
                                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                            </svg>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="5" class="px-6 py-8 text-center text-gray-500">
                                    Belum ada pertanyaan. Klik tombol "Tambah Pertanyaan" untuk menambahkan.
                                </td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <!-- Add Question Modal -->
    <div id="addModal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
        <div class="bg-white rounded-xl p-8 w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto">
            <h3 class="text-2xl font-bold text-gray-800 mb-6">Tambah Pertanyaan Baru</h3>
            <form action="{{ route('admin.question.store') }}" method="POST">
                @csrf
                <div class="mb-4">
                    <label class="block text-gray-700 font-semibold mb-2">Teks Pertanyaan</label>
                    <textarea name="question_text" rows="3" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500" placeholder="Masukkan pertanyaan..." required></textarea>
                </div>
                <div class="mb-6">
                    <label class="block text-gray-700 font-semibold mb-2">Kategori</label>
                    <select name="category" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500" required>
                        <option value="mental_health">Kesehatan Mental</option>
                        <option value="anxiety">Kecemasan</option>
                        <option value="depression">Depresi</option>
                        <option value="stress">Stres</option>
                    </select>
                </div>
                <div class="mb-6">
                    <label class="block text-gray-700 font-semibold mb-2">Opsi Jawaban (Default)</label>
                    <div class="bg-gray-50 rounded-lg p-4 text-sm text-gray-600">
                        <p>• Tidak pernah (Skor: 0)</p>
                        <p>• Jarang / 1-2 kali (Skor: 3)</p>
                        <p>• Kadang-kadang / 3-4 kali (Skor: 5)</p>
                        <p>• Sering / 5-6 kali (Skor: 8)</p>
                        <p>• Sangat sering / Setiap hari (Skor: 10)</p>
                    </div>
                </div>
                <div class="flex justify-end space-x-4">
                    <button type="button" onclick="closeAddModal()" class="px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition">
                        Batal
                    </button>
                    <button type="submit" class="px-6 py-3 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition">
                        Simpan
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Question Modal -->
    <div id="editModal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
        <div class="bg-white rounded-xl p-8 w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto">
            <h3 class="text-2xl font-bold text-gray-800 mb-6">Edit Pertanyaan</h3>
            <form id="editForm" method="POST">
                @csrf
                @method('PUT')
                <div class="mb-4">
                    <label class="block text-gray-700 font-semibold mb-2">Teks Pertanyaan</label>
                    <textarea id="editQuestionText" name="question_text" rows="3" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500" placeholder="Masukkan pertanyaan..." required></textarea>
                </div>
                <div class="mb-6">
                    <label class="block text-gray-700 font-semibold mb-2">Kategori</label>
                    <select id="editCategory" name="category" class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500" required>
                        <option value="mental_health">Kesehatan Mental</option>
                        <option value="anxiety">Kecemasan</option>
                        <option value="depression">Depresi</option>
                        <option value="stress">Stres</option>
                    </select>
                </div>
                <div class="mb-6">
                    <label class="block text-gray-700 font-semibold mb-2">Opsi Jawaban & Skor</label>
                    <div id="editOptions" class="space-y-3">
                        <!-- Options will be dynamically added here -->
                    </div>
                </div>
                <div class="flex justify-end space-x-4">
                    <button type="button" onclick="closeEditModal()" class="px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition">
                        Batal
                    </button>
                    <button type="submit" class="px-6 py-3 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition">
                        Simpan Perubahan
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openAddModal() {
            document.getElementById('addModal').classList.remove('hidden');
            document.getElementById('addModal').classList.add('flex');
        }

        function closeAddModal() {
            document.getElementById('addModal').classList.add('hidden');
            document.getElementById('addModal').classList.remove('flex');
        }

        function openEditModal(id, questionText, category, options) {
            document.getElementById('editForm').action = '/admin/questions/' + id;
            document.getElementById('editQuestionText').value = questionText;
            document.getElementById('editCategory').value = category;
            
            // Build options HTML
            let optionsHtml = '';
            options.forEach((opt, index) => {
                optionsHtml += `
                    <div class="flex items-center space-x-3">
                        <input type="text" name="options[${index}][text]" value="${opt.text}" class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500" placeholder="Teks opsi">
                        <input type="number" name="options[${index}][score]" value="${opt.score}" class="w-20 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500" placeholder="Skor">
                    </div>
                `;
            });
            document.getElementById('editOptions').innerHTML = optionsHtml;

            document.getElementById('editModal').classList.remove('hidden');
            document.getElementById('editModal').classList.add('flex');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.add('hidden');
            document.getElementById('editModal').classList.remove('flex');
        }

        // Close modal when clicking outside
        document.getElementById('addModal').addEventListener('click', function(e) {
            if (e.target === this) closeAddModal();
        });
        document.getElementById('editModal').addEventListener('click', function(e) {
            if (e.target === this) closeEditModal();
        });
    </script>
</body>
</html>
