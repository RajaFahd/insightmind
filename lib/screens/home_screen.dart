import 'package:flutter/material.dart';
import '../widgets/design_card.dart';
import '../theme.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  final ValueChanged<int>? onTabSelected;
  const HomeScreen({super.key, this.onTabSelected});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String userName = '';
  String? profilePictureUrl;
  List<Map<String, dynamic>> weeklyScreenings = [];
  bool isLoading = true;
  double averageScore = 0;
  String moodStatus = 'Baik';
  int screeningCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadAllData();
    }
  }

  Future<void> loadAllData() async {
    await Future.wait([_loadUserData(), _loadWeeklyScreenings()]);
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.getUserData();
    if (userData != null && mounted) {
      setState(() {
        userName = userData['name'] ?? 'User';
        profilePictureUrl = userData['profile_picture_url'];
      });
    }
    final result = await ApiService.getProfile();
    if (result['success'] == true && result['user'] != null && mounted) {
      setState(() {
        userName = result['user']['name'] ?? userName;
        profilePictureUrl = result['user']['profile_picture_url'];
      });
    }
  }

  Future<void> _loadWeeklyScreenings() async {
    final result = await ApiService.getScreeningHistory();
    if (result['success'] == true && mounted) {
      final List<dynamic> allScreenings = result['data'] ?? [];

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final List<Map<String, dynamic>> thisWeek = [];
      double totalScore = 0;

      for (var screening in allScreenings) {
        final createdAt = DateTime.tryParse(screening['created_at'] ?? '');
        if (createdAt != null && createdAt.isAfter(weekAgo)) {
          thisWeek.add(Map<String, dynamic>.from(screening));
          totalScore += (screening['total_score'] as num?)?.toDouble() ?? 0;
        }
      }

      setState(() {
        weeklyScreenings = thisWeek;
        screeningCount = thisWeek.length;
        if (thisWeek.isNotEmpty) {
          averageScore = totalScore / thisWeek.length;
          moodStatus = _getMoodStatus(averageScore);
        }
      });
    }
  }

  String _getMoodStatus(double score) {
    if (score <= 20) return 'Sangat Baik';
    if (score <= 40) return 'Baik';
    if (score <= 60) return 'Cukup';
    if (score <= 80) return 'Kurang';
    return 'Perlu Perhatian';
  }

  Color _getMoodColor(double score) {
    if (score <= 20) return Colors.green;
    if (score <= 40) return AppColors.mint;
    if (score <= 60) return Colors.orange;
    if (score <= 80) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = 28 + MediaQuery.of(context).viewPadding.bottom;
    const double topBgHeight = 160;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xFFFF9E87), Colors.white],
              ),
            ),
          ),
          Container(
            height: topBgHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9EE6A7), Color(0xFFFFC0AF)],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 18),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18, 12, 18, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.mint.withOpacity(0.18),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: profilePictureUrl != null
                              ? Colors.white
                              : AppColors.peach.withOpacity(0.3),
                          child: ClipOval(
                            child: profilePictureUrl != null
                                ? Image.network(
                                    profilePictureUrl!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Colors.white,
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Colors.white,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Selamat Datang Kembali,",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Hai, ${userName.isNotEmpty ? userName : 'User'}",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9079), Color(0xFFFFC0AF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Bagaimana perasaanmu hari ini?",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Temukan keseimbangan mentalmu dengan skrining cepat dan rekomendasi lembut",
                                style: TextStyle(
                                  color: Colors.white70,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (widget.onTabSelected != null) {
                                    widget.onTabSelected!(1);
                                  } else {
                                    Navigator.pushNamed(context, '/screening');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 6,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 28,
                                  ),
                                ),
                                child: Text(
                                  "Mulai Screening",
                                  style: TextStyle(
                                    color: AppColors.deepNavy,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 30,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.10),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 22,
                        left: 30,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Progres Mingguan",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (screeningCount > 0)
                        Text(
                          "$screeningCount screening",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DesignCard(
                          height: 150,
                          borderRadius: 22,
                          elevation: 20,
                          // reduce vertical padding so content is closer to edges
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // top group: icon + subtitle + main text (kept together near top)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: _getMoodColor(averageScore),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // slight top offset to align with icon
                                      const Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Text(
                                          "Mood",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    screeningCount > 0 ? moodStatus : "-",
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              // bottom caption stays close to bottom
                              Text(
                                screeningCount > 0
                                    ? "Rata-rata minggu ini"
                                    : "Belum ada screening",
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DesignCard(
                          height: 150,
                          borderRadius: 22,
                          elevation: 20, // stronger shadow
                          // reduce top/bottom padding so icon and subtitle sit closer to top,
                          // and caption sits close to bottom
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // subtitle/icon pushed to top
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: _getMoodColor(averageScore),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sentiment_satisfied,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Text(
                                          "Skor Rata-rata",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // thinner progress border and smaller percent text
                              SizedBox(
                                width: 54,
                                height: 54,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: screeningCount > 0
                                          ? (100 - averageScore) / 100
                                          : 0,
                                      strokeWidth: 3, // thinner border
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getMoodColor(averageScore),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        screeningCount > 0
                                            ? "${(100 - averageScore).toInt()}%"
                                            : "-",
                                        style: const TextStyle(
                                          fontSize: 13, // smaller percent text
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // bottom caption close to bottom
                              Text(
                                screeningCount > 0
                                    ? "Kesehatan mental"
                                    : "Belum ada data",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  const Text(
                    "Refleksi Singkat",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal scroll for the reflection cards (allows side-scrolling on smaller screens)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ), // beri ruang di kiri/kanan agar shadow tidak terpotong
                    child: Row(
                      children: [
                        // first reflection box: bungkus dengan Padding (ruang kanan & bawah)
                        Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 12),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.80,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFDFF8E8),
                                  Color.fromARGB(255, 191, 233, 197),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius:
                                      10, // dikurangi supaya tidak melebar
                                  spreadRadius: 0, // hilangkan spread
                                  offset: const Offset(
                                    6,
                                    8,
                                  ), // sedikit lebih kecil
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      243,
                                      145,
                                      81,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.directions_walk_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "\"Fokus pada langkah kecil\"",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "\"Setiap langkah kecil yang kamu ambil hari ini adalah kemajuan. "
                                        "Jangan bandingkan dirimu dengan orang lain. Fokus pada dirimu "
                                        "yang lebih baik dari kemarin.\"",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          height: 1.4,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(right: 12, bottom: 12),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.80,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFDFF8E8),
                                  Color.fromARGB(255, 191, 233, 197),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(6, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      243,
                                      145,
                                      81,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.track_changes,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "fokus pada tujuan kamu",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "\"Tetapkan tujuan yang jelas dan terukur. Bagi menjadi langkah kecil yang bisa dilakukan konsisten setiap hari, "
                                        "lalu rayakan kemajuan kecil tersebut untuk menjaga motivasi.\"",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          height: 1.4,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
