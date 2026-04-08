import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../data/local/user_storage.dart';
import 'home_page.dart';
import '../../domain/entities/user.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final UserStorage _userStorage = UserStorage();

  // Palette Warna Terang & Elegan
  final Color deepDarkBrown = const Color(0xFF2D1B14); 
  final Color primaryBrown = const Color(0xFF634832);  
  final Color accentPink = const Color(0xFFE07A5F);    
  final Color creamHighlight = const Color(0xFFF4F1DE); // Background Utama

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    final savedUser = await _userStorage.loadUser();
    if (savedUser != null && mounted) {
      _nameController.text = savedUser.name;
      _ageController.text = savedUser.age.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamHighlight, // Latar belakang Cream
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Ornamen Glow yang lebih lembut di latar belakang terang
            Positioned(
              top: -100,
              right: -50,
              child: _buildVibrantGlow(accentPink.withOpacity(0.15), 400),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _buildVibrantGlow(primaryBrown.withOpacity(0.1), 350),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // LOGO (Tetap Bold dengan gradasi)
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [deepDarkBrown, primaryBrown],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBrown.withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 60,
                            color: creamHighlight,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Judul (Warna Cokelat Tua agar Kontras di atas Cream)
                        Text(
                          'InsightMind',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: deepDarkBrown,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TEMUKAN MAKNA DI BALIK SETIAP PIKIRAN',
                          style: TextStyle(
                            fontSize: 13,
                            color: accentPink,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Form Section
                        _buildInputLabel("IDENTITAS PENGGUNA"),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Masukkan nama Anda...',
                          icon: Icons.person_pin_rounded,
                          validator: (value) => (value == null || value.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 28),

                        _buildInputLabel("USIA SAAT INI"),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _ageController,
                          hint: 'Berapa usia Anda?',
                          icon: Icons.cake_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Usia diperlukan';
                            final age = int.tryParse(value);
                            if (age == null || age < 13) return 'Minimal 13 tahun';
                            return null;
                          },
                        ),
                        const SizedBox(height: 60),

                        // BUTTON (Warna Gelap agar jadi pusat perhatian/Call to Action)
                        GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              final name = _nameController.text.trim();
                              final age = int.parse(_ageController.text);
                              
                              // Load existing user data to preserve profile picture
                              final savedUser = await _userStorage.loadUser();
                              
                              User user;
                              if (savedUser != null && savedUser.name == name) {
                                // User exists - update age but keep profile picture
                                user = savedUser.copyWith(age: age);
                              } else {
                                // New user or different name - create fresh user
                                user = User(name: name, age: age);
                              }
                              
                              // Save to persistent storage
                              await _userStorage.saveUser(user);
                              
                              // Update provider
                              ref.read(userProvider.notifier).state = user;
                              
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomePage()),
                                );
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: deepDarkBrown,
                              boxShadow: [
                                BoxShadow(
                                  color: deepDarkBrown.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: creamHighlight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibrantGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: deepDarkBrown.withOpacity(0.6),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        // Teks input warna Cokelat Tua
        style: TextStyle(color: deepDarkBrown, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: deepDarkBrown.withOpacity(0.3), fontWeight: FontWeight.normal),
          prefixIcon: Icon(icon, color: primaryBrown, size: 24),
          filled: true,
          fillColor: Colors.white, // Input field putih agar bersih di atas cream
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: deepDarkBrown.withOpacity(0.05), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryBrown, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }
}