import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';

class AdminResultsScreen extends StatefulWidget {
  static const routeName = '/admin-results';
  const AdminResultsScreen({super.key});

  @override
  State<AdminResultsScreen> createState() => _AdminResultsScreenState();
}

class _AdminResultsScreenState extends State<AdminResultsScreen> {
  List<Map<String, dynamic>> results = [];
  bool isLoading = true;
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'value': 'Normal', 'label': 'Normal', 'color': Colors.green},
    {'value': 'Ringan', 'label': 'Ringan', 'color': Colors.blue},
    {'value': 'Sedang', 'label': 'Sedang', 'color': Colors.orange},
    {'value': 'Tinggi', 'label': 'Tinggi', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => isLoading = true);

    final result = await ApiService.adminGetScreeningResults(
      category: selectedCategory,
    );

    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        // Handle paginated response
        if (data is Map && data['data'] != null) {
          results = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          results = List<Map<String, dynamic>>.from(data);
        } else {
          results = [];
        }
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal memuat data')),
        );
      }
    }
  }

  Color _getCategoryColor(String category) {
    final cat = categories.firstWhere(
      (c) => c['value'] == category,
      orElse: () => {'color': Colors.grey},
    );
    return cat['color'] as Color;
  }

  Future<void> _deleteResult(Map<String, dynamic> result) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Hasil Screening'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus hasil screening ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await ApiService.adminDeleteScreeningResult(
        result['id'],
      );

      if (response['success'] == true) {
        _loadResults();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hasil screening berhasil dihapus')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Gagal menghapus')),
          );
        }
      }
    }
  }

  void _showDetailDialog(Map<String, dynamic> result) {
    final user = result['user'] as Map<String, dynamic>?;
    final answers = result['answers'];
    Map<String, dynamic> answersMap = {};

    if (answers is Map) {
      answersMap = Map<String, dynamic>.from(answers);
    } else if (answers is String) {
      try {
        answersMap = {};
      } catch (e) {
        answersMap = {};
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Hasil Screening'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Nama', user?['name'] ?? 'Unknown'),
              _buildDetailRow('Email', user?['email'] ?? '-'),
              const Divider(),
              _buildDetailRow('Total Skor', '${result['total_score']}'),
              _buildDetailRow('Kategori', result['result_category'] ?? '-'),
              const Divider(),
              const Text(
                'Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                result['result_description'] ?? '-',
                style: const TextStyle(fontSize: 13),
              ),
              const Divider(),
              const Text(
                'Jawaban:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (answersMap.isNotEmpty)
                ...answersMap.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${entry.key}:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text('${entry.value}'),
                      ],
                    ),
                  ),
                )
              else
                const Text(
                  'Tidak ada data jawaban',
                  style: TextStyle(color: Colors.grey),
                ),
              const Divider(),
              _buildDetailRow('Tanggal', _formatDate(result['created_at'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hasil Screening',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: AppColors.peach,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Filter: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Semua'),
                          selected: selectedCategory == null,
                          onSelected: (selected) {
                            setState(() => selectedCategory = null);
                            _loadResults();
                          },
                          selectedColor: AppColors.peach.withOpacity(0.3),
                        ),
                        const SizedBox(width: 8),
                        ...categories.map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat['label']),
                              selected: selectedCategory == cat['value'],
                              onSelected: (selected) {
                                setState(() => selectedCategory = cat['value']);
                                _loadResults();
                              },
                              selectedColor: (cat['color'] as Color)
                                  .withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assessment_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada hasil screening',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadResults,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        final user = result['user'] as Map<String, dynamic>?;
                        final category = result['result_category'] ?? 'Normal';
                        final score = result['total_score'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _showDetailDialog(result),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _getCategoryColor(
                                          category,
                                        ).withOpacity(0.2),
                                        child: Icon(
                                          Icons.person,
                                          color: _getCategoryColor(category),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user?['name'] ?? 'Unknown User',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              user?['email'] ?? '-',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteResult(result),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Skor',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '$score',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Kategori',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(
                                                  category,
                                                ).withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                category,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _getCategoryColor(
                                                    category,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Tanggal',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              _formatDate(result['created_at']),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
