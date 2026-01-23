import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/curved_background.dart';

class MeditationScreen extends StatefulWidget {
  static const routeName = '/meditation';
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  int _selectedDuration = 5; // minutes
  int _remainingSeconds = 0;
  Timer? _timer;
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  int _breathPhase = 0; // 0: inhale, 1: hold, 2: exhale
  final List<String> _breathTexts = [
    'Tarik Napas...',
    'Tahan...',
    'Buang Napas...'
  ];

  final List<Map<String, dynamic>> _meditations = [
    {
      'title': 'Pernapasan Tenang',
      'duration': 5,
      'icon': Icons.air,
      'color': Color(0xFF81C784),
      'description': 'Teknik pernapasan untuk menenangkan pikiran',
    },
    {
      'title': 'Relaksasi Tubuh',
      'duration': 10,
      'icon': Icons.self_improvement,
      'color': Color(0xFF64B5F6),
      'description': 'Rilekskan tubuh dari kepala hingga kaki',
    },
    {
      'title': 'Fokus & Konsentrasi',
      'duration': 7,
      'icon': Icons.center_focus_strong,
      'color': Color(0xFFFFB74D),
      'description': 'Tingkatkan fokus dan kejernihan pikiran',
    },
    {
      'title': 'Tidur Nyenyak',
      'duration': 15,
      'icon': Icons.nightlight_round,
      'color': Color(0xFF9575CD),
      'description': 'Persiapan tidur yang damai',
    },
  ];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  void _startMeditation(int minutes) {
    setState(() {
      _selectedDuration = minutes;
      _remainingSeconds = minutes * 60;
      _isPlaying = true;
    });
    _startBreathCycle();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopMeditation();
        _showCompletionDialog();
      }
    });
  }

  void _startBreathCycle() {
    _runBreathPhase();
  }

  void _runBreathPhase() async {
    if (!_isPlaying) return;

    // Inhale - 4 seconds
    setState(() => _breathPhase = 0);
    _breathController.forward();
    await Future.delayed(const Duration(seconds: 4));
    if (!_isPlaying) return;

    // Hold - 4 seconds
    setState(() => _breathPhase = 1);
    await Future.delayed(const Duration(seconds: 4));
    if (!_isPlaying) return;

    // Exhale - 4 seconds
    setState(() => _breathPhase = 2);
    _breathController.reverse();
    await Future.delayed(const Duration(seconds: 4));
    if (!_isPlaying) return;

    _runBreathPhase(); // Repeat
  }

  void _stopMeditation() {
    _timer?.cancel();
    _breathController.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: AppColors.mint, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              'Meditasi Selesai! 🎉',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Kamu telah bermeditasi selama $_selectedDuration menit.\nPikiran yang tenang adalah awal dari hari yang produktif.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: TextStyle(color: AppColors.peach)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
                      onPressed: () {
                        if (_isPlaying) _stopMeditation();
                        Navigator.pop(context);
                      },
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
                        'Meditasi Terpandu',
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

              Expanded(
                child: _isPlaying
                    ? _buildMeditationPlayer()
                    : _buildMeditationList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header illustration
        Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.mint.withOpacity(0.3),
                AppColors.peach.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Text(
              '🧘‍♀️',
              style: TextStyle(fontSize: 80),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Pilih sesi meditasi yang sesuai dengan kebutuhanmu',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Meditation options
        ..._meditations.map((med) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMeditationCard(med),
            )),
      ],
    );
  }

  Widget _buildMeditationCard(Map<String, dynamic> meditation) {
    return GestureDetector(
      onTap: () => _startMeditation(meditation['duration']),
      child: Container(
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (meditation['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                meditation['icon'],
                color: meditation['color'],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meditation['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meditation['description'],
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.peach.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${meditation['duration']} min',
                style: TextStyle(
                  color: AppColors.peach,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Breathing circle
        AnimatedBuilder(
          animation: _breathAnimation,
          builder: (context, child) {
            return Container(
              width: 200 * _breathAnimation.value,
              height: 200 * _breathAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.mint.withOpacity(0.8),
                    AppColors.mint.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mint.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🧘', style: TextStyle(fontSize: 50)),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),

        // Breath instruction
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _breathTexts[_breathPhase],
            key: ValueKey(_breathPhase),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Timer
        Text(
          _formatTime(_remainingSeconds),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 40),

        // Stop button
        GestureDetector(
          onTap: _stopMeditation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stop_circle, color: AppColors.peach, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Berhenti',
                  style: TextStyle(
                    color: AppColors.peach,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
