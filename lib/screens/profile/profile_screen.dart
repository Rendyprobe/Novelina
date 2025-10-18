import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_colors.dart';
import '../../core/cover_image_utils.dart';
import '../../core/storage_helper.dart';
import '../../services/image_upload_service.dart';
import '../../services/user_service.dart';
import '../auth/sign_in_screen.dart';
import 'device_info_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProfileView(showBackButton: true),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String userName = '';
  String userEmail = '';
  String userAvatar = '';
  bool isLoading = true;
  bool _isUpdatingAvatar = false;

  final ImageUploadService _imageUploadService = const ImageUploadService();
  final UserService _userService = const UserService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await StorageHelper.getUserName();
    final email = await StorageHelper.getUserEmail();
    final avatar = await StorageHelper.getUserAvatar();

    if (!mounted) return;

    setState(() {
      userName = name;
      userEmail = email;
      userAvatar = avatar;
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Keluar',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await StorageHelper.clearUserData();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  void _openDeviceInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeviceInfoScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 16),
                Text(
                  userName.isEmpty ? 'Pengguna Novelina' : userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userEmail.isEmpty ? 'Belum ada email' : userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Pengaturan Akun',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            icon: Icons.smartphone,
            title: 'Informasi Perangkat',
            subtitle: 'Detail perangkat yang Anda gunakan saat ini',
            onTap: _openDeviceInfo,
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Pelajari lebih lanjut tentang Novelina',
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/Logo_Novelina.jpg',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Novelina',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      'Versi 1.0.0\n\nAplikasi untuk membaca novel favorit Anda dengan nyaman.',
                      style: TextStyle(height: 1.5),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Keluar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.accentBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final hasAvatar = userAvatar.trim().isNotEmpty;
    ImageProvider<Object>? avatarImage;
    if (hasAvatar) {
      try {
        avatarImage = resolveCoverImage(userAvatar.trim());
      } catch (_) {
        avatarImage = null;
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? const Icon(
                    Icons.person,
                    color: AppColors.primaryBlue,
                    size: 50,
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Tooltip(
            message: 'Ganti foto profil',
            child: Material(
              color: AppColors.primaryBlue,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isUpdatingAvatar ? null : _changeAvatar,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isUpdatingAvatar)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _changeAvatar() async {
    if (_isUpdatingAvatar) return;

    if (!kIsWeb) {
      _showSnackBar(
        'Ganti foto profil hanya tersedia pada versi web untuk saat ini.',
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();
    await uploadInput.onChange.first;

    final file = uploadInput.files?.first;
    if (file == null) {
      return;
    }

    if (file.size > 6 * 1024 * 1024) {
      _showSnackBar(
        'Ukuran foto terlalu besar. Gunakan gambar dengan ukuran maksimal 6 MB.',
      );
      return;
    }

    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;
    final result = reader.result;
    if (result is! String || result.isEmpty) {
      _showSnackBar('Tidak dapat membaca file gambar.');
      return;
    }

    final userId = await StorageHelper.getUserId();
    if (userId <= 0) {
      _showSnackBar('Data pengguna tidak ditemukan.');
      return;
    }

    setState(() => _isUpdatingAvatar = true);

    try {
      final uploadedUrl = await _imageUploadService.uploadFromDataUrl(result);
      final savedUrl =
          await _userService.updateAvatar(userId: userId, avatarUrl: uploadedUrl);

      await StorageHelper.setUserAvatar(savedUrl);

      if (!mounted) return;
      setState(() => userAvatar = savedUrl);

      _showSnackBar(
        'Foto profil berhasil diperbarui!',
        backgroundColor: AppColors.secondaryBlue,
      );
    } catch (error) {
      _showSnackBar(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingAvatar = false);
      }
    }
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.redAccent}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}
