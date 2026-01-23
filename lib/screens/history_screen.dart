import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/design_card.dart';
import '../theme.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selected = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _historyItems = [];
  List<double> _chartData = [];
  List<String> _chartLabels = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Auto refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final result = await ApiService.getScreeningHistory();
      if (result['success'] && result['data'] != null) {
        final List<dynamic> data = result['data'];

        setState(() {
          _historyItems = data
              .map((item) {
                String emoji = '😐';
                final score = item['total_score'] ?? 0;
                if (score <= 20) {
                  emoji = '😊';
                } else if (score <= 40) {
                  emoji = '😌';
                } else if (score <= 60) {
                  emoji = '😐';
                } else if (score <= 80) {
                  emoji = '😟';
                } else {
                  emoji = '😰';
                }

                return {
                  'id': item['id'],
                  'emoji': emoji,
                  'title': 'Screening ${item['screening_type'] ?? 'Mental'}',
                  'subtitle': '${item['result_category'] ?? 'Normal'}',
                  'date': _formatDate(item['created_at']),
                  'score': item['total_score'] ?? 0,
                  'category': item['result_category'] ?? 'Normal',
                };
              })
              .toList()
              .cast<Map<String, dynamic>>();

          _prepareChartData(data);
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _prepareChartData(List<dynamic> data) {
    final recentData = data.take(7).toList().reversed.toList();

    _chartData = recentData
        .map((item) => (item['total_score'] ?? 0).toDouble())
        .toList()
        .cast<double>();
    _chartLabels = recentData.map((item) {
      final date = DateTime.tryParse(item['created_at'] ?? '');
      if (date != null) {
        return '${date.day}/${date.month}';
      }
      return '';
    }).toList();
    while (_chartData.length < 7) {
      _chartData.insert(0, 0);
      _chartLabels.insert(0, '');
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Sen';
      case 2:
        return 'Sel';
      case 3:
        return 'Rab';
      case 4:
        return 'Kam';
      case 5:
        return 'Jum';
      case 6:
        return 'Sab';
      case 7:
        return 'Ming';
      default:
        return '';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;

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
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _deleteScreening(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus riwayat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await ApiService.deleteScreening(id);
        if (result['success']) {
          _loadHistory();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Riwayat berhasil dihapus'),
                backgroundColor: Colors.green.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
      }
    }
  }

  String _getCurrentStatus() {
    if (_historyItems.isEmpty) return 'Belum Ada Data';
    final lastScore = _historyItems.first['score'] ?? 0;
    if (lastScore <= 20) return 'Normal';
    if (lastScore <= 40) return 'Ringan';
    if (lastScore <= 60) return 'Sedang';
    if (lastScore <= 80) return 'Tinggi';
    return 'Perlu Perhatian';
  }

  Color _getStatusColor() {
    if (_historyItems.isEmpty) return Colors.grey;
    final lastScore = _historyItems.first['score'] ?? 0;
    if (lastScore <= 20) return Colors.green;
    if (lastScore <= 40) return Colors.lightGreen;
    if (lastScore <= 60) return Colors.orange;
    if (lastScore <= 80) return Colors.deepOrange;
    return Colors.red;
  }

  String _getTrendText() {
    if (_chartData.length < 2) return 'Data tidak cukup';

    final recent = _chartData.last;
    final previous = _chartData[_chartData.length - 2];

    if (previous == 0) return 'Data baru';

    final diff = ((recent - previous) / previous * 100).round();
    if (diff > 0) {
      return 'Naik +$diff%';
    } else if (diff < 0) {
      return 'Turun $diff%';
    }
    return 'Stabil';
  }

  @override
  Widget build(BuildContext context) {
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
                      'Riwayat Screening',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _loadHistory,
                        icon: const Icon(
                          Icons.refresh,
                          color: Color.fromARGB(255, 241, 126, 68),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadHistory,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFFFF9E87), Colors.white],
                  ),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          14.0,
                          16.0,
                          14.0,
                          20.0,
                        ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPeriodChip('Harian', 0),
                              _buildPeriodChip('Mingguan', 1),
                              _buildPeriodChip('Bulanan', 2),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.show_chart,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Status Kesehatan Mental',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  _getCurrentStatus(),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: _getStatusColor(),
                                    height: 1,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTrendText().contains('Naik')
                                      ? Colors.red.withOpacity(0.2)
                                      : AppColors.mint.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getTrendText().contains('Naik')
                                          ? Icons.trending_up
                                          : _getTrendText().contains('Turun')
                                              ? Icons.trending_down
                                              : Icons.trending_flat,
                                      size: 16,
                                      color: _getTrendText().contains('Naik')
                                          ? Colors.red
                                          : AppColors.mint,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getTrendText(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _getTrendText().contains('Naik')
                                            ? Colors.red
                                            : AppColors.mint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: _chartData.isEmpty ||
                                    _chartData.every((d) => d == 0)
                                ? Container(
                                    height: 200,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.bar_chart,
                                          size: 60,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Belum ada data grafik',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    height: 260,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 16,
                                    ),
                                    child: BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceEvenly,
                                        maxY: _chartData.isEmpty
                                            ? 100
                                            : (_chartData.reduce((a, b) =>
                                                        a > b ? a : b) *
                                                    1.2)
                                                .clamp(50, 100),
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchTooltipData: BarTouchTooltipData(
                                            getTooltipItem: (
                                              group,
                                              groupIndex,
                                              rod,
                                              rodIndex,
                                            ) {
                                              return BarTooltipItem(
                                                'Score: ${rod.toY.round()}',
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value.toInt() >= 0 &&
                                                    value.toInt() <
                                                        _chartLabels.length) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 8.0,
                                                    ),
                                                    child: Text(
                                                      _chartLabels[
                                                          value.toInt()],
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  value.round().toString(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval: 10,
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                              color: Colors.grey.shade200,
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: List.generate(
                                          _chartData.length,
                                          (index) => BarChartGroupData(
                                            x: index,
                                            barRods: [
                                              BarChartRodData(
                                                toY: _chartData[index],
                                                width: 28,
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(6),
                                                ),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.peach.withOpacity(
                                                      0.5,
                                                    ),
                                                    AppColors.peach.withOpacity(
                                                      0.9,
                                                    ),
                                                  ],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          if (_historyItems.isNotEmpty)
                            DesignCard(
                              borderRadius: 20,
                              elevation: 10,
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.mint.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getRecommendation(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          const Text(
                            'Riwayat Lengkap',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_historyItems.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 60,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Belum ada riwayat screening',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Mulai screening pertama Anda!',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._historyItems.map(
                              (item) => _buildHistoryItem(item),
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRecommendation() {
    if (_historyItems.isEmpty) {
      return 'Mulai screening untuk mendapatkan rekomendasi kesehatan mental Anda.';
    }

    final lastScore = _historyItems.first['score'] ?? 0;
    // Based on 0-100 scale
    if (lastScore <= 20) {
      return 'Kondisi Normal\nSkor Anda menunjukkan kondisi mental yang sehat. Pertahankan pola hidup sehat dan aktivitas positif Anda!';
    } else if (lastScore <= 40) {
      return 'Perhatian Ringan\nAnda menunjukkan gejala ringan. Coba luangkan waktu untuk relaksasi dan aktivitas yang menyenangkan.';
    } else if (lastScore <= 60) {
      return 'Perlu Perhatian\nSkor Anda menunjukkan perlu perhatian lebih. Pertimbangkan untuk berbicara dengan seseorang yang Anda percaya.';
    } else if (lastScore <= 80) {
      return 'Perhatian Tinggi\nSkor Anda menunjukkan kondisi yang perlu ditangani. Sangat disarankan berkonsultasi dengan profesional.';
    } else {
      return 'Butuh Bantuan\nSkor Anda menunjukkan perlu bantuan profesional. Jangan ragu untuk berkonsultasi dengan psikolog atau psikiater.';
    }
  }

  Widget _buildPeriodChip(String label, int index) {
    final isSelected = _selected == index;
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.peach : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.peach.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Dismissible(
      key: Key(item['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        _deleteScreening(item['id']);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.peach.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  item['emoji'],
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item['category'] ?? 'Normal'),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['subtitle'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['date'],
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  'Score: ${item['score']}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(item['score']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    // Based on 0-100 scale
    if (score <= 20) return Colors.green;
    if (score <= 40) return Colors.lightGreen;
    if (score <= 60) return Colors.orange;
    if (score <= 80) return Colors.deepOrange;
    return Colors.red;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Normal':
        return Colors.green;
      case 'Ringan':
        return Colors.lightGreen;
      case 'Sedang':
        return Colors.orange;
      case 'Tinggi':
        return Colors.deepOrange;
      case 'Sangat Tinggi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
