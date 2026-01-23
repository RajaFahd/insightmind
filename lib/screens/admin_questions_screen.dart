import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';

class AdminQuestionsScreen extends StatefulWidget {
  static const routeName = '/admin-questions';
  const AdminQuestionsScreen({super.key});

  @override
  State<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends State<AdminQuestionsScreen> {
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;
  String? selectedCategory;

  final List<Map<String, String>> categories = [
    {'value': 'mental_health', 'label': 'Kesehatan Mental'},
    {'value': 'anxiety', 'label': 'Kecemasan'},
    {'value': 'depression', 'label': 'Depresi'},
    {'value': 'stress', 'label': 'Stres'},
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => isLoading = true);

    final result = await ApiService.adminGetQuestions(
      category: selectedCategory,
    );

    if (result['success'] == true) {
      setState(() {
        questions = List<Map<String, dynamic>>.from(result['data'] ?? []);
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

  String _getCategoryLabel(String category) {
    final cat = categories.firstWhere(
      (c) => c['value'] == category,
      orElse: () => {'label': category},
    );
    return cat['label'] ?? category;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'mental_health':
        return Colors.blue;
      case 'anxiety':
        return Colors.orange;
      case 'depression':
        return Colors.purple;
      case 'stress':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _toggleQuestionActive(Map<String, dynamic> question) async {
    final result = await ApiService.adminToggleQuestionActive(question['id']);

    if (result['success'] == true) {
      _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Status berhasil diubah'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal mengubah status')),
        );
      }
    }
  }

  Future<void> _deleteQuestion(Map<String, dynamic> question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pertanyaan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pertanyaan ini?',
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
      final result = await ApiService.adminDeleteQuestion(question['id']);

      if (result['success'] == true) {
        _loadQuestions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pertanyaan berhasil dihapus')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal menghapus')),
          );
        }
      }
    }
  }

  void _showQuestionDialog({Map<String, dynamic>? question}) {
    final isEdit = question != null;
    final textController = TextEditingController(
      text: question?['question_text'] ?? '',
    );
    String category = question?['category'] ?? 'mental_health';
    List<Map<String, dynamic>> options = question?['options'] != null
        ? List<Map<String, dynamic>>.from(question!['options'])
        : [
            {'text': 'Tidak pernah', 'score': 0},
            {'text': 'Kadang-kadang', 'score': 1},
            {'text': 'Sering', 'score': 2},
            {'text': 'Sangat sering', 'score': 3},
          ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Pertanyaan' : 'Tambah Pertanyaan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Teks Pertanyaan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat['value'],
                          child: Text(cat['label']!),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => category = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Opsi Jawaban & Skor:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(options.length, (index) {
                  final optionTextCtrl = TextEditingController(
                    text: options[index]['text'],
                  );
                  final scoreCtrl = TextEditingController(
                    text: options[index]['score'].toString(),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: optionTextCtrl,
                            decoration: InputDecoration(
                              labelText: 'Opsi ${index + 1}',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              options[index]['text'] = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: scoreCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Skor',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              options[index]['score'] =
                                  int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: options.length > 2
                              ? () {
                                  setDialogState(() {
                                    options.removeAt(index);
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      options.add({'text': '', 'score': options.length});
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Opsi'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (textController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teks pertanyaan tidak boleh kosong'),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                final result = isEdit
                    ? await ApiService.adminUpdateQuestion(
                        id: question['id'],
                        questionText: textController.text,
                        category: category,
                        options: options,
                      )
                    : await ApiService.adminCreateQuestion(
                        questionText: textController.text,
                        category: category,
                        options: options,
                      );

                if (result['success'] == true) {
                  _loadQuestions();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Pertanyaan berhasil diperbarui'
                              : 'Pertanyaan berhasil ditambahkan',
                        ),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Gagal menyimpan'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.peach),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Soal Screening',
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
                            _loadQuestions();
                          },
                          selectedColor: AppColors.peach.withOpacity(0.3),
                        ),
                        const SizedBox(width: 8),
                        ...categories.map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat['label']!),
                              selected: selectedCategory == cat['value'],
                              onSelected: (selected) {
                                setState(() => selectedCategory = cat['value']);
                                _loadQuestions();
                              },
                              selectedColor: _getCategoryColor(
                                cat['value']!,
                              ).withOpacity(0.3),
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
                : questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pertanyaan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadQuestions,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final isActive =
                            question['is_active'] == true ||
                            question['is_active'] == 1;
                        final category =
                            question['category'] ?? 'mental_health';
                        final options = List<Map<String, dynamic>>.from(
                          question['options'] ?? [],
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isActive
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(
                                category,
                              ).withOpacity(0.2),
                              child: Text(
                                '${question['order'] ?? index + 1}',
                                style: TextStyle(
                                  color: _getCategoryColor(category),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              question['question_text'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isActive ? Colors.black87 : Colors.grey,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(
                                      category,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getCategoryLabel(category),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getCategoryColor(category),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActive ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isActive
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              const Divider(),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Opsi Jawaban:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...options.map(
                                (opt) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.mint.withOpacity(
                                            0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${opt['score']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: AppColors.mint,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          opt['text'] ?? '',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () =>
                                        _toggleQuestionActive(question),
                                    icon: Icon(
                                      isActive
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 18,
                                    ),
                                    label: Text(
                                      isActive ? 'Nonaktifkan' : 'Aktifkan',
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: isActive
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () =>
                                        _showQuestionDialog(question: question),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deleteQuestion(question),
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('Hapus'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuestionDialog(),
        backgroundColor: AppColors.peach,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
