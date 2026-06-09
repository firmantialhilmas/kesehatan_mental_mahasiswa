// lib/src/features/insightmind/presentation/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/questionnaire_provider.dart';
import '../../data/local/profile_picture_service.dart';
import '../../data/local/user_storage.dart';
import 'history_page.dart';
import 'login_page.dart';

final dailyNoteProvider = StateProvider<String>((ref) => "");

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // Palette Warna Warm Earthy
  final Color deepDarkBrown = const Color(0xFF2D1B14);
  final Color primaryBrown = const Color(0xFF634832);
  final Color accentPink = const Color(0xFFE07A5F);
  final Color creamHighlight = const Color(0xFFF4F1DE);
  final Color surfaceBrown = const Color(0xFF3D2B24);

  final TextEditingController _noteController = TextEditingController();
  final ProfilePictureService _profilePictureService = ProfilePictureService();
  final UserStorage _userStorage = UserStorage();
  bool _isUploadingImage = false;

  Future<void> _onRefresh() async {
    ref.invalidate(userProvider); 
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profil diperbarui"),
          backgroundColor: primaryBrown,
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _logoutAndReset(BuildContext context, WidgetRef ref) {
    ref.read(userProvider.notifier).state = null;
    ref.read(questionnaireProvider.notifier).resetAnswers();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showProfilePictureOptions() {
    final user = ref.read(userProvider);
    final bool hasProfilePicture = user?.profilePicturePath != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: deepDarkBrown,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Foto Profil",
              style: TextStyle(
                color: creamHighlight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (!hasProfilePicture) ...[
              // Upload Profile option (when no profile picture exists)
              _buildOptionTile(
                icon: Icons.upload_rounded,
                title: 'Upload Profil',
                subtitle: 'Pilih foto dari galeri',
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePicture();
                },
              ),
            ] else ...[
              // Change Profile option (when profile picture exists)
              _buildOptionTile(
                icon: Icons.edit_rounded,
                title: 'Ganti Profil',
                subtitle: 'Pilih foto baru dari galeri',
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePicture();
                },
              ),
              const SizedBox(height: 12),
              // Delete Profile option (when profile picture exists)
              _buildOptionTile(
                icon: Icons.delete_rounded,
                title: 'Hapus Profil',
                subtitle: 'Hapus foto profil saat ini',
                iconColor: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfilePicture();
                },
              ),
            ],
            const SizedBox(height: 12),
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(
                  'BATAL',
                  style: TextStyle(
                    color: creamHighlight.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceBrown,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? accentPink).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? accentPink,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: creamHighlight,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: creamHighlight.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: creamHighlight.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfilePicture() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final String? imagePath = await _profilePictureService.pickAndSaveImage();
      
      if (imagePath != null) {
        final user = ref.read(userProvider);
        if (user != null) {
          // Delete old profile picture if exists
          if (user.profilePicturePath != null) {
            await _profilePictureService.deleteImage(user.profilePicturePath!);
          }
          
          // Update user with new profile picture
          ref.read(userProvider.notifier).state = user.copyWith(
            profilePicturePath: imagePath,
          );

          // Save to persistent storage
          await _userStorage.saveUser(user.copyWith(
            profilePicturePath: imagePath,
          ));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Foto profil berhasil diperbarui"),
                backgroundColor: primaryBrown,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengunggah foto: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _deleteProfilePicture() async {
    final user = ref.read(userProvider);
    if (user?.profilePicturePath == null) return;

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: deepDarkBrown,
        title: Text('Hapus Foto Profil?', style: TextStyle(color: creamHighlight)),
        content: Text(
          'Apakah Anda yakin ingin menghapus foto profil?',
          style: TextStyle(color: creamHighlight.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('BATAL', style: TextStyle(color: creamHighlight.withOpacity(0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentPink),
            onPressed: () => Navigator.pop(context, true),
            child: Text('HAPUS', style: TextStyle(color: creamHighlight, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isUploadingImage = true;
      });

      try {
        await _profilePictureService.deleteImage(user!.profilePicturePath!);
        
        // Update user to remove profile picture
        ref.read(userProvider.notifier).state = user.copyWith(
          clearProfilePicture: true,
        );

        // Save to persistent storage
        await _userStorage.saveUser(user.copyWith(
          clearProfilePicture: true,
        ));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Foto profil berhasil dihapus"),
              backgroundColor: primaryBrown,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menghapus foto: $e"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }
    }
  }

  void _showDailyNoteDialog(BuildContext context) {
    _noteController.text = ref.read(dailyNoteProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24, left: 24, right: 24,
        ),
        decoration: BoxDecoration(
          color: deepDarkBrown, // Bottom sheet tetap gelap agar elegan
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Catatan Refleksi", style: TextStyle(color: creamHighlight, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 4,
              style: TextStyle(color: creamHighlight),
              decoration: InputDecoration(
                hintText: "Apa yang kamu rasakan?",
                hintStyle: TextStyle(color: creamHighlight.withOpacity(0.3)),
                filled: true,
                fillColor: surfaceBrown,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPink,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  ref.read(dailyNoteProvider.notifier).state = _noteController.text;
                  Navigator.pop(context);
                },
                child: Text("SIMPAN", style: TextStyle(color: creamHighlight, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final savedNote = ref.watch(dailyNoteProvider);

    return Scaffold(
      // SEKARANG: Background utama menggunakan Cream
      backgroundColor: creamHighlight, 
      appBar: AppBar(
        title: Text('PROFIL', style: TextStyle(color: creamHighlight, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        backgroundColor: deepDarkBrown,
        foregroundColor: creamHighlight,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: accentPink,
        backgroundColor: deepDarkBrown,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), 
          child: Column(
            children: [
              if (user == null) 
                const Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                const SizedBox(height: 30),
                // Avatar dengan Border Accent dan Upload Button
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accentPink, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: deepDarkBrown,
                          backgroundImage: user.profilePicturePath != null
                              ? (kIsWeb 
                                  ? NetworkImage(user.profilePicturePath!) as ImageProvider
                                  : FileImage(File(user.profilePicturePath!)))
                              : null,
                          child: user.profilePicturePath == null
                              ? Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: creamHighlight),
                                )
                              : null,
                        ),
                      ),
                      // Camera Icon Button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isUploadingImage ? null : _showProfilePictureOptions,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentPink,
                              shape: BoxShape.circle,
                              border: Border.all(color: creamHighlight, width: 2),
                            ),
                            child: _isUploadingImage
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(creamHighlight),
                                    ),
                                  )
                                : Icon(Icons.camera_alt, size: 16, color: creamHighlight),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(user.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: deepDarkBrown)),
                Text('${user.age} TAHUN • AKTIF', style: TextStyle(color: accentPink, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1)),

                // Note Container (Versi Cream: Putih/Soft Layer)
                if (savedNote.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Text(
                        savedNote,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: primaryBrown, fontStyle: FontStyle.italic, height: 1.5),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),

                // Menu List Container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileTile(
                        icon: Icons.edit_note_rounded, 
                        title: 'Tulis Catatan', 
                        subtitle: 'Rekam pikiranmu hari ini', 
                        onTap: () => _showDailyNoteDialog(context)
                      ),
                      _buildDivider(),
                      _buildProfileTile(
                        icon: Icons.history_rounded, 
                        title: 'Riwayat Screening', 
                        subtitle: 'Lihat data perkembangan Anda', 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()))
                      ),
                      _buildDivider(),
                      _buildProfileTile(
                        icon: Icons.logout_rounded, 
                        title: 'Keluar Akun', 
                        subtitle: 'Logout dari sistem InsightMind', 
                        textColor: Colors.redAccent, 
                        onTap: () => _logoutAndReset(context, ref)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text("InsightMind v1.0.3", style: TextStyle(color: deepDarkBrown.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color? textColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? accentPink).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textColor ?? accentPink),
      ),
      title: Text(title, style: TextStyle(color: textColor ?? deepDarkBrown, fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: deepDarkBrown.withOpacity(0.4), fontSize: 12)),
      trailing: Icon(Icons.chevron_right_rounded, color: deepDarkBrown.withOpacity(0.2)),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: deepDarkBrown.withOpacity(0.05), indent: 20, endIndent: 20);
}