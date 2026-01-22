import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/design_card.dart';
import '../theme.dart';
import '../services/api_service.dart';

class ScreeningScreen extends StatefulWidget {
  static const routeName = '/screening';
  const ScreeningScreen({super.key});

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  List<Map<String, dynamic>> questions = [];
  List<int> answers = [];
  bool isLoading = true;
  String selectedActivity = 'Olahraga';
  String sleepQuality = 'Cukup';
  int currentPage = 0;
  final int questionsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final result = await ApiService.getScreeningQuestions();
    if (result['success'] == true && mounted) {
      final data = List<Map<String, dynamic>>.from(result['data'] ?? []);
      // Filter only active questions
      final activeQuestions = data
          .where((q) => q['is_active'] == true || q['is_active'] == 1)
          .toList();
      setState(() {
        questions = activeQuestions;
        answers = List.filled(
          activeQuestions.length,
          -1,
        ); // -1 means not answered
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  double get progress {
    if (questions.isEmpty) return 0;
    final answered = answers.where((a) => a >= 0).length;
    return answered / questions.length;
  }

  int get totalPages => (questions.length / questionsPerPage).ceil();

  List<Map<String, dynamic>> get currentQuestions {
    final start = currentPage * questionsPerPage;
    final end = (start + questionsPerPage).clamp(0, questions.length);
    return questions.sublist(start, end);
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'anxiety':
        return Colors.orange;
      case 'depression':
        return Colors.blue;
      case 'stress':
        return Colors.red;
      case 'mental_health':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'anxiety':
        return 'Kecemasan';
      case 'depression':
        return 'Depresi';
      case 'stress':
        return 'Stres';
      case 'mental_health':
        return 'Kesehatan Mental';
      default:
        return category ?? 'Umum';
    }
  }

  Widget _buildSleepOption(String label, IconData icon, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => sleepQuality = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color:
              selected ? Colors.orange.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.orange : Colors.black54,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: selected ? Colors.orange : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );

    try {
      final result = await ApiService.getScreeningHistory();
      Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        final List<dynamic> history = result['data'] ?? [];

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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB0DACD),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Riwayat Screening',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined,
                                  size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada riwayat screening',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            final category =
                                item['result_category'] ?? 'Unknown';
                            final score = item['total_score'] ?? 0;
                            final createdAt = item['created_at'] ?? '';

                            // Parse date
                            String formattedDate = createdAt;
                            try {
                              final date = DateTime.parse(createdAt);
                              final months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'Mei',
                                'Jun',
                                'Jul',
                                'Agu',
                                'Sep',
                                'Okt',
                                'Nov',
                                'Des'
                              ];
                              formattedDate =
                                  '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                            } catch (_) {}

                            Color categoryColor;
                            IconData categoryIcon;
                            switch (category) {
                              case 'Normal':
                                categoryColor = Colors.green;
                                categoryIcon = Icons.sentiment_very_satisfied;
                                break;
                              case 'Ringan':
                                categoryColor = Colors.lightGreen;
                                categoryIcon = Icons.sentiment_satisfied;
                                break;
                              case 'Sedang':
                                categoryColor = Colors.orange;
                                categoryIcon = Icons.sentiment_neutral;
                                break;
                              case 'Tinggi':
                                categoryColor = Colors.deepOrange;
                                categoryIcon = Icons.sentiment_dissatisfied;
                                break;
                              case 'Sangat Tinggi':
                                categoryColor = Colors.red;
                                categoryIcon =
                                    Icons.sentiment_very_dissatisfied;
                                break;
                              default:
                                categoryColor = Colors.grey;
                                categoryIcon = Icons.help_outline;
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/result',
                                    arguments: {'score': score},
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: categoryColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          categoryIcon,
                                          color: categoryColor,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: categoryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    category,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  'Skor: $score%',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: categoryColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 14,
                                                    color:
                                                        Colors.grey.shade500),
                                                const SizedBox(width: 4),
                                                Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat riwayat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _calculateScore() {
    int totalScore = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] >= 0) {
        final options = questions[i]['options'] as List<dynamic>?;
        if (options != null && answers[i] < options.length) {
          final option = options[answers[i]] as Map<String, dynamic>;
          totalScore += (option['score'] as num?)?.toInt() ?? 0;
        }
      }
    }
    return totalScore;
  }

  int _getMaxScore() {
    int maxScore = 0;
    for (final q in questions) {
      final options = q['options'] as List<dynamic>?;
      if (options != null && options.isNotEmpty) {
        int maxOptionScore = 0;
        for (final opt in options) {
          final score = (opt['score'] as num?)?.toInt() ?? 0;
          if (score > maxOptionScore) maxOptionScore = score;
        }
        maxScore += maxOptionScore;
      }
    }
    return maxScore;
  }

  void _submit() async {
    // Check if all questions answered
    final unanswered = answers.where((a) => a < 0).length;
    if (unanswered > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masih ada $unanswered pertanyaan yang belum dijawab'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final totalScore = _calculateScore();
    final maxScore = _getMaxScore();
    final percentage = maxScore > 0 ? (totalScore * 100 ~/ maxScore) : 0;

    // Determine category based on percentage (0-100 scale)
    String category;
    if (percentage <= 20) {
      category = 'Normal';
    } else if (percentage <= 40) {
      category = 'Ringan';
    } else if (percentage <= 60) {
      category = 'Sedang';
    } else if (percentage <= 80) {
      category = 'Tinggi';
    } else {
      category = 'Sangat Tinggi';
    }

    // Save to backend
    try {
      // Convert answers to map format with question IDs
      final answersMap = <String, dynamic>{};
      for (int i = 0; i < questions.length; i++) {
        final questionId = questions[i]['id'];
        answersMap['q_$questionId'] = answers[i];
      }

      String description;
      if (category == 'Normal') {
        description =
            'Kondisi kesehatan mental Anda dalam keadaan baik. Tetap jaga pola hidup sehat!';
      } else if (category == 'Ringan') {
        description =
            'Ada sedikit gejala yang perlu diperhatikan. Cobalah untuk lebih rileks dan istirahat cukup.';
      } else if (category == 'Sedang') {
        description =
            'Disarankan untuk lebih memperhatikan kesehatan mental Anda. Pertimbangkan untuk berkonsultasi dengan profesional.';
      } else if (category == 'Tinggi') {
        description =
            'Kondisi Anda memerlukan perhatian serius. Sangat disarankan untuk berkonsultasi dengan profesional kesehatan mental.';
      } else {
        description =
            'Kondisi Anda memerlukan penanganan segera. Segera cari bantuan profesional kesehatan mental.';
      }

      await ApiService.saveScreeningResult(
        answers: answersMap,
        resultCategory: category,
        resultDescription: description,
        totalScore: percentage,
      );
    } catch (e) {
      debugPrint('Error saving screening: $e');
    }

    Navigator.pushNamed(context, '/result', arguments: {'score': percentage});
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dateString = 'Hari ini, ${today.day} ${months[today.month - 1]}';

    return Scaffold(
      body: Column(
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 48,
                  left: 14,
                  right: 14,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    176,
                    218,
                    205,
                  ).withOpacity(0.7),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color.fromARGB(255, 241, 126, 68),
                        ),
                      ),
                    ),
                    const Text(
                      'Proses Screening',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _showHistoryDialog(),
                        icon: const Icon(
                          Icons.access_time,
                          color: Color.fromARGB(255, 241, 126, 68),
                        ),
                        tooltip: 'Riwayat Screening',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFFFF9E87), Colors.white],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14.0, 16.0, 14.0, 140.0),
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progres',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()} %',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                          ),
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF9E87),
                                    Color(0xFFFFB9A8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFFFE082), Color(0xFFA8E6CF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          dateString,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Aktivitas apa yang kamu lakukan?',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kamu bisa memilih lebih dari satu',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Row(
                        children: ['Olahraga', 'Kuliah', 'Bekerja'].map((e) {
                          final isSelected = e == selectedActivity;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 8,
                                ),
                                label: Text(
                                  e,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.peach.withOpacity(0.9),
                                backgroundColor: AppColors.mint.withOpacity(
                                  0.12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.peach
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                onSelected: (selected) =>
                                    setState(() => selectedActivity = e),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Belajar', 'Sekolah', 'Lainnya...'].map((e) {
                          final isSelected = e == selectedActivity;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 8,
                                ),
                                label: Text(
                                  e,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.peach.withOpacity(0.9),
                                backgroundColor: AppColors.mint.withOpacity(
                                  0.12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.peach
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                onSelected: (selected) =>
                                    setState(() => selectedActivity = e),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DesignCard(
                    padding: const EdgeInsets.all(14.0),
                    borderRadius: 20,
                    elevation: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Bagaimana kualitas tidur mu?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pilih salah satu yang paling sesuai',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSleepOption(
                              'Buruk',
                              Icons.nightlight,
                              sleepQuality == 'Buruk',
                            ),
                            _buildSleepOption(
                              'Cukup',
                              Icons.bedtime,
                              sleepQuality == 'Cukup',
                            ),
                            _buildSleepOption(
                              'Baik',
                              Icons.wb_sunny,
                              sleepQuality == 'Baik',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Loading indicator
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (questions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Tidak ada pertanyaan tersedia',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    // Dynamic questions from API
                    ...List.generate(currentQuestions.length, (idx) {
                      final globalIdx = currentPage * questionsPerPage + idx;
                      final question = currentQuestions[idx];
                      final questionText =
                          question['question_text'] as String? ?? '';
                      final options =
                          question['options'] as List<dynamic>? ?? [];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: DesignCard(
                          padding: const EdgeInsets.all(14.0),
                          borderRadius: 20,
                          elevation: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.mint.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${globalIdx + 1}.',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          questionText,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                        if (question['category'] != null) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getCategoryColor(
                                                question['category'],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _formatCategory(
                                                question['category'],
                                              ),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...List.generate(options.length, (opt) {
                                final isSelected = opt == answers[globalIdx];
                                final option =
                                    options[opt] as Map<String, dynamic>;
                                final optionText =
                                    option['text'] as String? ?? '';

                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => answers[globalIdx] = opt),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.mint.withOpacity(0.15)
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.mint.withOpacity(0.6)
                                            : Colors.grey.shade200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.mint
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: isSelected
                                                ? AppColors.mint
                                                : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            optionText,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.black87
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                  // Pagination buttons
                  if (questions.isNotEmpty && totalPages > 1) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentPage > 0)
                          ElevatedButton.icon(
                            onPressed: () => setState(() => currentPage--),
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text('Sebelumnya'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.peach,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${currentPage + 1} / $totalPages',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (currentPage < totalPages - 1)
                          ElevatedButton.icon(
                            onPressed: () => setState(() => currentPage++),
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text('Selanjutnya'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.peach,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 12,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Submit Screening',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.peach,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
