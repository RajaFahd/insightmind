import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/curved_background.dart';
import 'chat_screen.dart';

class ConsultationScreen extends StatelessWidget {
  static const routeName = '/consultation';
  const ConsultationScreen({super.key});

  final List<Map<String, dynamic>> _professionals = const [
    {
      'name': 'Dr. Andi Wijaya, M.Psi',
      'specialty': 'Psikolog Klinis',
      'experience': '15 tahun pengalaman',
      'rating': 4.9,
      'image': '👨‍⚕️',
      'available': true,
      'phone': '+6281234567890',
    },
    {
      'name': 'Dr. Siti Rahayu, Sp.KJ',
      'specialty': 'Psikiater',
      'experience': '12 tahun pengalaman',
      'rating': 4.8,
      'image': '👩‍⚕️',
      'available': true,
      'phone': '+6281234567891',
    },
    {
      'name': 'Maya Putri, M.Psi',
      'specialty': 'Konselor Kesehatan Mental',
      'experience': '8 tahun pengalaman',
      'rating': 4.7,
      'image': '👩‍💼',
      'available': false,
      'phone': '+6281234567892',
    },
    {
      'name': 'Dr. Budi Santoso, M.Psi',
      'specialty': 'Psikolog Anak & Remaja',
      'experience': '10 tahun pengalaman',
      'rating': 4.9,
      'image': '👨‍💼',
      'available': true,
      'phone': '+6281234567893',
    },
  ];

  final List<Map<String, dynamic>> _hotlines = const [
    {
      'name': 'Into The Light Indonesia',
      'number': '119 ext 8',
      'description': 'Hotline kesehatan jiwa 24 jam',
      'icon': Icons.phone_in_talk,
      'color': Color(0xFF4CAF50),
    },
    {
      'name': 'Yayasan Pulih',
      'number': '021-788-42580',
      'description': 'Konseling trauma & kesehatan mental',
      'icon': Icons.health_and_safety,
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'LSM Jangan Bunuh Diri',
      'number': '021-9696-9293',
      'description': 'Pencegahan bunuh diri',
      'icon': Icons.favorite,
      'color': Color(0xFFE91E63),
    },
    {
      'name': 'Sejiwa (Sehat Jiwa)',
      'number': '119 ext 8',
      'description': 'Layanan Kemenkes RI',
      'icon': Icons.local_hospital,
      'color': Color(0xFF9C27B0),
    },
  ];

  void _showContactDialog(
      BuildContext context, String name, String phone, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              type == 'call' ? Icons.phone : Icons.chat,
              color: AppColors.peach,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type == 'call' ? 'Hubungi' : 'Chat WhatsApp',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone, color: AppColors.mint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      phone,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: phone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Nomor disalin ke clipboard'),
                          backgroundColor: Colors.green.shade400,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(Icons.copy, color: AppColors.peach),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              type == 'call'
                  ? 'Tekan dan tahan nomor untuk menyalin, lalu hubungi melalui aplikasi telepon Anda.'
                  : 'Salin nomor dan buka WhatsApp untuk memulai percakapan.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phone));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Nomor $phone disalin! Silakan hubungi melalui ${type == "call" ? "telepon" : "WhatsApp"}'),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.peach,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Salin Nomor',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHotlineDialog(BuildContext context, String name, String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.phone_in_talk, color: Colors.green),
            const SizedBox(width: 12),
            const Expanded(
                child: Text('Hotline', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Layanan gratis 24 jam. Salin nomor dan hubungi melalui aplikasi telepon Anda.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: number.replaceAll(' ', '')));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Nomor $number disalin!'),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Salin Nomor',
                style: TextStyle(color: Colors.white)),
          ),
        ],
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
                        'Konsultasi Ahli',
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Emergency banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade400,
                            Colors.red.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.emergency,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Butuh Bantuan Segera?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Hubungi hotline darurat 24 jam',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showHotlineDialog(
                                context, 'Hotline Darurat', '119'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'HUBUNGI',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Hotlines section
                    const Text(
                      'Hotline Kesehatan Mental',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Layanan gratis 24 jam',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    ...List.generate(_hotlines.length, (index) {
                      final hotline = _hotlines[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  (hotline['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              hotline['icon'],
                              color: hotline['color'],
                            ),
                          ),
                          title: Text(
                            hotline['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                hotline['number'],
                                style: TextStyle(
                                  color: hotline['color'],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                hotline['description'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () => _showHotlineDialog(
                                context, hotline['name'], hotline['number']),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.mint.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.call, color: AppColors.mint),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Professionals section
                    const Text(
                      'Profesional Tersedia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Konsultasi dengan ahli berpengalaman',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    ...List.generate(_professionals.length, (index) {
                      final pro = _professionals[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.peach.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      pro['image'],
                                      style: const TextStyle(fontSize: 32),
                                    ),
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
                                          Expanded(
                                            child: Text(
                                              pro['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: pro['available']
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : Colors.grey
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              pro['available']
                                                  ? 'Online'
                                                  : 'Offline',
                                              style: TextStyle(
                                                color: pro['available']
                                                    ? Colors.green
                                                    : Colors.grey,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pro['specialty'],
                                        style: TextStyle(
                                          color: AppColors.peach,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.work_outline,
                                            size: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            pro['experience'],
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.star,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${pro['rating']}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: pro['available']
                                        ? () => _showContactDialog(context,
                                            pro['name'], pro['phone'], 'call')
                                        : null,
                                    icon: const Icon(Icons.call, size: 18),
                                    label: const Text('Telepon'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.mint,
                                      side: BorderSide(color: AppColors.mint),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: pro['available']
                                        ? () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                  doctorName: pro['name'],
                                                  specialty: pro['specialty'],
                                                  emoji: pro['image'],
                                                ),
                                              ),
                                            )
                                        : null,
                                    icon: const Icon(Icons.chat, size: 18),
                                    label: const Text('Chat'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.peach,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.mint.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.mint),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Semua konsultasi bersifat rahasia dan profesional. Jangan ragu untuk meminta bantuan.',
                              style: TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
