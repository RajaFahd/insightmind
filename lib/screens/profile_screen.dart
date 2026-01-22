import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/curved_background.dart';
import '../theme.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  final VoidCallback? onProfileUpdated;
  const ProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String? _profilePictureUrl;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getProfile();
      if (result['success'] && result['user'] != null) {
        setState(() {
          _name = result['user']['name'] ?? 'User';
          _email = result['user']['email'] ?? 'user@email.com';
          _profilePictureUrl = result['user']['profile_picture_url'];
        });
      } else {
        // Load from local storage if API fails
        final userData = await ApiService.getUserData();
        setState(() {
          _name = userData?['name'] ?? 'User';
          _email = userData?['email'] ?? 'user@email.com';
          _profilePictureUrl = userData?['profile_picture_url'];
        });
      }
    } catch (e) {
      final userData = await ApiService.getUserData();
      setState(() {
        _name = userData?['name'] ?? 'User';
        _email = userData?['email'] ?? 'user@email.com';
        _profilePictureUrl = userData?['profile_picture_url'];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingPhoto = true);

      final result =
          await ApiService.uploadProfilePicture(File(pickedFile.path));

      if (result['success']) {
        setState(() {
          _profilePictureUrl = result['data']['profile_picture_url'];
        });
        widget.onProfileUpdated?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Foto profil berhasil diupload'),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal upload foto'),
              backgroundColor: Colors.red.shade400,
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih Foto Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.peach.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.camera_alt, color: AppColors.peach),
              ),
              title: const Text('Ambil Foto'),
              subtitle: const Text('Gunakan kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.photo_library, color: AppColors.mint),
              ),
              title: const Text('Pilih dari Galeri'),
              subtitle: const Text('Pilih foto yang sudah ada'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            if (_profilePictureUrl != null) ...[
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete, color: Colors.red.shade400),
                ),
                title: const Text('Hapus Foto'),
                subtitle: const Text('Kembali ke avatar default'),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _isUploadingPhoto = true);
                  final result = await ApiService.deleteProfilePicture();
                  if (result['success']) {
                    setState(() => _profilePictureUrl = null);
                    widget.onProfileUpdated?.call();
                  }
                  setState(() => _isUploadingPhoto = false);
                },
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      unawaited(ApiService.logout());
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profil',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                labelStyle:
                    TextStyle(color: AppColors.deepNavy.withValues(alpha: 0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.peach.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.peach, width: 2),
                ),
                filled: true,
                fillColor: AppColors.cream.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.peach.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: AppColors.deepNavy.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _email,
                          style: TextStyle(
                            color: AppColors.deepNavy.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Email tidak dapat diubah',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.deepNavy.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.deepNavy.withValues(alpha: 0.7),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Nama tidak boleh kosong'),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                return;
              }

              if (!mounted) return;
              Navigator.pop(context);

              setState(() => _isLoading = true);

              try {
                final result = await ApiService.updateProfile(name: newName);
                if (result['success']) {
                  setState(() {
                    _name = newName;
                  });
                  // Notify parent to refresh home screen
                  widget.onProfileUpdated?.call();

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profil berhasil diperbarui'),
                      backgroundColor: Colors.green.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ?? 'Gagal memperbarui profil',
                      ),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Terjadi kesalahan: $e'),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.peach,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CurvedBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadProfile,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          children: [
                            const SizedBox(height: 20),
                            // User Info Card
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.subtleShadow,
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Avatar with profile picture support
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: _showImagePickerOptions,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: _profilePictureUrl == null
                                                ? LinearGradient(
                                                    colors: [
                                                      AppColors.peach
                                                          .withValues(
                                                              alpha: 0.8),
                                                      AppColors.mint.withValues(
                                                          alpha: 0.6),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : null,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.peach
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: _isUploadingPhoto
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : _profilePictureUrl != null
                                                  ? ClipOval(
                                                      child: Image.network(
                                                        _profilePictureUrl!,
                                                        width: 120,
                                                        height: 120,
                                                        fit: BoxFit.cover,
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : null,
                                                              color: AppColors
                                                                  .peach,
                                                            ),
                                                          );
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 60,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 60,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: _showImagePickerOptions,
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.peach,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.peach
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Name
                                  Text(
                                    _name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.deepNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Email
                                  Text(
                                    _email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.deepNavy
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Menu Section Title
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Pengaturan Akun',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildMenuItem(
                              icon: Icons.person_outline,
                              label: 'Edit Profil',
                              onTap: _showEditProfileDialog,
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.history,
                              label: 'Riwayat Screening',
                              onTap: () {
                                Navigator.pushNamed(context, '/history');
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.info_outline,
                              label: 'Tentang Aplikasi',
                              onTap: () {
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'InsightMind',
                                  applicationVersion: '1.0.0',
                                  applicationLegalese: '© 2024 InsightMind',
                                  children: [
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Aplikasi screening kesehatan mental untuk membantu Anda memahami kondisi kesehatan mental Anda.',
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.notifications_outlined,
                              label: 'Pengaturan Notifikasi',
                              onTap: () => _showNotificationSettings(),
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.privacy_tip_outlined,
                              label: 'Kebijakan Privasi',
                              onTap: () => _showPrivacyPolicy(),
                            ),
                            const SizedBox(height: 32),
                            // Logout Section
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Akun',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout, size: 20),
                                label: const Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.red.shade200,
                                ),
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.subtleShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.peach.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.peach.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.peach,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.deepNavy.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    bool dailyReminder = prefs.getBool('daily_reminder') ?? true;
    bool screeningReminder = prefs.getBool('screening_reminder') ?? true;
    bool meditationReminder = prefs.getBool('meditation_reminder') ?? false;
    bool journalReminder = prefs.getBool('journal_reminder') ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pengaturan Notifikasi',
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
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildNotificationTile(
                      'Pengingat Harian',
                      'Notifikasi setiap hari untuk menjaga kesehatan mental',
                      Icons.today,
                      dailyReminder,
                      (value) async {
                        setModalState(() => dailyReminder = value);
                        await prefs.setBool('daily_reminder', value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationTile(
                      'Pengingat Screening',
                      'Ingatkan untuk melakukan screening mingguan',
                      Icons.assignment,
                      screeningReminder,
                      (value) async {
                        setModalState(() => screeningReminder = value);
                        await prefs.setBool('screening_reminder', value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationTile(
                      'Pengingat Meditasi',
                      'Ingatkan untuk bermeditasi setiap hari',
                      Icons.self_improvement,
                      meditationReminder,
                      (value) async {
                        setModalState(() => meditationReminder = value);
                        await prefs.setBool('meditation_reminder', value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationTile(
                      'Pengingat Jurnal',
                      'Ingatkan untuk menulis jurnal harian',
                      Icons.book,
                      journalReminder,
                      (value) async {
                        setModalState(() => journalReminder = value);
                        await prefs.setBool('journal_reminder', value);
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pastikan notifikasi diizinkan di pengaturan perangkat Anda.',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.peach.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.peach, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.mint,
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.peach,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Kebijakan Privasi',
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
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildPrivacySection(
                    'Pengumpulan Data',
                    'InsightMind mengumpulkan data yang Anda berikan secara langsung, termasuk:\n\n• Informasi akun (nama, email)\n• Hasil screening kesehatan mental\n• Catatan jurnal dan mood harian\n• Foto profil (opsional)',
                    Icons.data_usage,
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    'Penggunaan Data',
                    'Data Anda digunakan untuk:\n\n• Menyediakan layanan screening kesehatan mental\n• Melacak progress kesehatan mental Anda\n• Memberikan rekomendasi yang dipersonalisasi\n• Meningkatkan kualitas layanan kami',
                    Icons.analytics,
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    'Keamanan Data',
                    'Kami berkomitmen melindungi data Anda dengan:\n\n• Enkripsi data end-to-end\n• Server yang aman dan terproteksi\n• Akses terbatas hanya untuk Anda\n• Tidak menjual data ke pihak ketiga',
                    Icons.security,
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    'Hak Pengguna',
                    'Anda memiliki hak untuk:\n\n• Mengakses data pribadi Anda\n• Memperbarui atau mengoreksi data\n• Menghapus akun dan seluruh data\n• Menarik persetujuan kapan saja',
                    Icons.person_pin,
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacySection(
                    'Kontak',
                    'Jika Anda memiliki pertanyaan tentang kebijakan privasi kami, silakan hubungi:\n\n📧 privacy@insightmind.com\n📞 +62 21 1234 5678',
                    Icons.contact_mail,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Terakhir diperbarui: 1 Januari 2026',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dengan menggunakan InsightMind, Anda menyetujui kebijakan privasi ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.peach.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.peach, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
