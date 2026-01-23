import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../widgets/curved_background.dart';

class JournalScreen extends StatefulWidget {
  static const routeName = '/journal';
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> _journals = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = '😊';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😄', 'label': 'Sangat Bahagia', 'color': Color(0xFF4CAF50)},
    {'emoji': '😊', 'label': 'Bahagia', 'color': Color(0xFF8BC34A)},
    {'emoji': '😐', 'label': 'Biasa', 'color': Color(0xFFFFEB3B)},
    {'emoji': '😔', 'label': 'Sedih', 'color': Color(0xFFFF9800)},
    {'emoji': '😢', 'label': 'Sangat Sedih', 'color': Color(0xFFF44336)},
    {'emoji': '😡', 'label': 'Marah', 'color': Color(0xFFE91E63)},
    {'emoji': '😰', 'label': 'Cemas', 'color': Color(0xFF9C27B0)},
    {'emoji': '😴', 'label': 'Lelah', 'color': Color(0xFF607D8B)},
  ];

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    final prefs = await SharedPreferences.getInstance();
    final journalData = prefs.getString('journals');
    if (journalData != null) {
      setState(() {
        _journals = List<Map<String, dynamic>>.from(jsonDecode(journalData));
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveJournals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('journals', jsonEncode(_journals));
  }

  void _addJournal() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Judul dan isi jurnal tidak boleh kosong'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final newJournal = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _titleController.text,
      'content': _contentController.text,
      'mood': _selectedMood,
      'date': DateTime.now().toIso8601String(),
    };

    setState(() {
      _journals.insert(0, newJournal);
    });
    _saveJournals();

    _titleController.clear();
    _contentController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Jurnal berhasil disimpan! 📝'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteJournal(String id) {
    setState(() {
      _journals.removeWhere((j) => j['id'] == id);
    });
    _saveJournals();
  }

  void _showAddJournalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const Text(
                      'Jurnal Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _addJournal,
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                          color: AppColors.peach,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mood selector
                      const Text(
                        'Bagaimana perasaanmu hari ini?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _moods.length,
                          itemBuilder: (context, index) {
                            final mood = _moods[index];
                            final isSelected = _selectedMood == mood['emoji'];
                            return GestureDetector(
                              onTap: () {
                                setModalState(
                                    () => _selectedMood = mood['emoji']);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 12),
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (mood['color'] as Color)
                                          .withOpacity(0.2)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? mood['color']
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  mood['emoji'],
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Judul jurnal...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Content
                      TextField(
                        controller: _contentController,
                        maxLines: 12,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                        decoration: InputDecoration(
                          hintText:
                              'Ceritakan hari ini...\n\nApa yang membuatmu senang?\nApa yang membuatmu khawatir?\nApa yang ingin kamu syukuri?',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJournalDetail(Map<String, dynamic> journal) {
    final date = DateTime.parse(journal['date']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    journal['mood'],
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journal['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteJournal(journal['id']);
                    },
                    icon:
                        Icon(Icons.delete_outline, color: Colors.red.shade400),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  journal['content'],
                  style: const TextStyle(fontSize: 16, height: 1.8),
                ),
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
      body: CurvedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            Icon(Icons.arrow_back, color: AppColors.deepNavy),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Jurnal Harian',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _journals.isEmpty
                        ? _buildEmptyState()
                        : _buildJournalList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddJournalSheet,
        backgroundColor: AppColors.peach,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Tulis Jurnal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.peach.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Text('📔', style: TextStyle(fontSize: 60)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada jurnal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai tulis jurnal harianmu\nuntuk mengekspresikan perasaan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _journals.length,
      itemBuilder: (context, index) {
        final journal = _journals[index];
        final date = DateTime.parse(journal['date']);
        return GestureDetector(
          onTap: () => _showJournalDetail(journal),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mint.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    journal['mood'],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journal['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        journal['content'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${date.day}/${date.month}',
                      style: TextStyle(
                        color: AppColors.peach,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
