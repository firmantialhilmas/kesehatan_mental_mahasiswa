import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/questionnaire_provider.dart';
import 'screening_page.dart';
import 'result_page.dart';
import 'profile_page.dart';
import 'dashboard_page.dart';

// Provider untuk navigasi antar tab
final navigationIndexProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // Palette Warna Tema Premium
  static const Color deepDarkBrown = Color(0xFF2D1B14);
  static const Color primaryBrown = Color(0xFF634832);
  static const Color accentPink = Color(0xFFE07A5F);
  static const Color creamHighlight = Color(0xFFF4F1DE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final selectedIndex = ref.watch(navigationIndexProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: creamHighlight,
        body: Center(child: Text('User tidak ditemukan')),
      );
    }

    final List<Widget> pages = [
      _buildHomeContent(context, ref, user), // Tab Home
      const DashboardPage(),               // Tab Stats
      const ProfilePage(),                 // Tab Profil
    ];

    return Scaffold(
      backgroundColor: creamHighlight,
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(ref, selectedIndex),
    );
  }

  // --- LOGIKA UNTUK MOOD TRACKER ---
  void _showMoodFeedback(BuildContext context, String mood, String emoji) {
    String message = "";
    if (mood == 'Senang' || mood == 'Semangat') {
      message = "Luar biasa! Pertahankan energi positif ini ya. Apa yang membuatmu merasa $mood hari ini?";
    } else if (mood == 'Biasa') {
      message = "Hari yang stabil adalah awal yang baik untuk fokus. Tetap semangat!";
    } else {
      message = "Tidak apa-apa merasa $mood. Ambil napas dalam, kamu sudah melakukan yang terbaik hari ini.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$emoji $message"),
        backgroundColor: deepDarkBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- LOGIKA FUNGSI QUICK ACTIONS (Pop-up Info) ---
  void _handleQuickAction(BuildContext context, String label) {
    String title = "";
    String content = "";
    IconData icon = Icons.info_outline;

    switch (label) {
      case 'Tips':
        title = "Tips Mental Health";
        content = "Gunakan teknik 4-7-8 (tarik napas 4 detik, tahan 7 detik, buang 8 detik) untuk menenangkan sistem saraf Anda dengan cepat.";
        icon = Icons.lightbulb;
        break;
      case 'Meditasi':
        title = "Sesi Meditasi";
        content = "Duduklah dengan tegak, pejamkan mata, dan fokus pada aliran napas Anda selama 3 menit untuk menjernihkan pikiran.";
        icon = Icons.self_improvement;
        break;
      case 'Jurnal':
        title = "Jurnal Syukur";
        content = "Mencatat 3 hal kecil yang Anda syukuri hari ini dapat meningkatkan mood secara signifikan dalam jangka panjang.";
        icon = Icons.history_edu;
        break;
      default:
        title = "Bantuan";
        content = "Hubungi layanan profesional jika Anda merasa butuh teman bicara yang lebih intensif.";
        icon = Icons.support_agent;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: creamHighlight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryBrown.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Icon(icon, size: 50, color: accentPink),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: deepDarkBrown)),
            const SizedBox(height: 12),
            Text(content, textAlign: TextAlign.center, style: const TextStyle(color: primaryBrown, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepDarkBrown, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text("Mengerti"),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- KONTEN UTAMA HALAMAN HOME ---
  Widget _buildHomeContent(BuildContext context, WidgetRef ref, dynamic user) {
    final questionnaire = ref.watch(questionnaireProvider);
    final bool hasCompletedScreening = questionnaire.isComplete;

    return Scaffold(
      backgroundColor: creamHighlight,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('INSIGHTMIND', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: deepDarkBrown,
        foregroundColor: creamHighlight,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 20,
              decoration: const BoxDecoration(color: deepDarkBrown, borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildWelcomeCard(user),
                  const SizedBox(height: 20),
                  _buildDailyQuote(),
                  
                  // --- FITUR BARU: MOOD TRACKER ---
                  const SizedBox(height: 32),
                  _buildSectionLabel("BAGAIMANA PERASAANMU?"),
                  const SizedBox(height: 16),
                  _buildMoodTracker(context),

                  const SizedBox(height: 32),
                  _buildSectionLabel("QUICK ACTIONS"),
                  const SizedBox(height: 12),
                  _buildQuickActionChips(context),
                  
                  const SizedBox(height: 32),
                  _buildSectionLabel("CORE ASSESSMENT"),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    title: 'Mulai Screening Baru',
                    subtitle: 'Evaluasi intelligence system anda',
                    icon: Icons.psychology_outlined,
                    color1: accentPink,
                    color2: primaryBrown,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreeningPage())),
                  ),
                  // const SizedBox(height: 32),
                  // // _buildSectionLabel("SIMULASI DATA"),
                  // const SizedBox(height: 16),
                  // _buildSimulasiBox(questionnaire),
                  const SizedBox(height: 24),
                  hasCompletedScreening
                      ? _buildActionButton(
                          title: 'Lihat Hasil Analisis',
                          subtitle: 'Data sudah siap diproses',
                          icon: Icons.insights_rounded,
                          color1: const Color(0xFF588157),
                          color2: const Color(0xFF3A5A40),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultPage())),
                        )
                      : _buildDisabledButton('Hasil Belum Tersedia'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KOMPONEN WIDGET ---

  Widget _buildMoodTracker(BuildContext context) {
    final moods = [
      {'emoji': '😔', 'label': 'Sedih'},
      {'emoji': '😐', 'label': 'Biasa'},
      {'emoji': '😊', 'label': 'Senang'},
      {'emoji': '🤩', 'label': 'Semangat'},
      {'emoji': '😴', 'label': 'Lelah'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: moods.map((m) => GestureDetector(
          onTap: () => _showMoodFeedback(context, m['label']!, m['emoji']!),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: creamHighlight, shape: BoxShape.circle),
                child: Text(m['emoji']!, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 8),
              Text(m['label']!, style: const TextStyle(fontSize: 10, color: primaryBrown, fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildDailyQuote() {
    final quotes = [
      "\"Setiap langkah kecil menuju pemulihan adalah kemenangan besar bagi jiwamu.\"",
      "\"Pikiranmu adalah benih. Kamu bisa menanam bunga atau rumput liar.\"",
      "\"Istirahat bukan berarti menyerah, tapi mengisi tenaga untuk melangkah.\""
    ];
    final randomQuote = quotes[DateTime.now().second % quotes.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentPink.withOpacity(0.2))
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: accentPink, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(randomQuote, style: const TextStyle(color: deepDarkBrown, fontStyle: FontStyle.italic, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildQuickActionChips(BuildContext context) {
    final actions = [
      {'label': 'Tips', 'icon': Icons.lightbulb_outline},
      {'label': 'Meditasi', 'icon': Icons.self_improvement},
      {'label': 'Jurnal', 'icon': Icons.history_edu},
      {'label': 'Bantuan', 'icon': Icons.support_agent},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: actions.map((act) => Container(
          margin: const EdgeInsets.only(right: 10),
          child: ActionChip(
            onPressed: () => _handleQuickAction(context, act['label'] as String),
            backgroundColor: Colors.white,
            side: BorderSide(color: primaryBrown.withOpacity(0.1)),
            avatar: Icon(act['icon'] as IconData, size: 16, color: accentPink),
            label: Text(act['label'] as String, style: const TextStyle(color: primaryBrown, fontSize: 12, fontWeight: FontWeight.w600)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildWelcomeCard(dynamic user) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: deepDarkBrown, 
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: deepDarkBrown.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]
    ),
    child: Row(children: [
      CircleAvatar(radius: 25, backgroundColor: accentPink, child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Selamat Datang,', style: TextStyle(color: Colors.white70, fontSize: 11)),
          Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis),
        ]),
      )
    ]),
  );

  Widget _buildSectionLabel(String label) => Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: primaryBrown, letterSpacing: 1.5));

  // Widget _buildSimulasiBox(dynamic q) => Container(
  //   padding: const EdgeInsets.all(16),
  //   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.05))),
  //   child: Wrap(spacing: 8, runSpacing: 8, children: List.generate(20, (i) {
  //     final val = q.answers[i] ?? 0;
  //     return Container(width: 39, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: creamHighlight, borderRadius: BorderRadius.circular(10)), child: Text('$val', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBrown)));
  //   })),
  // );

  Widget _buildActionButton({required String title, required String subtitle, required IconData icon, required Color color1, required Color color2, required VoidCallback onPressed}) => InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color1.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ])),
        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
      ]),
    ),
  );

  Widget _buildDisabledButton(String text) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
    child: Row(children: [const Icon(Icons.lock_outline, color: Colors.grey), const SizedBox(width: 16), Text(text, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))]),
  );

  Widget _buildBottomNav(WidgetRef ref, int index) => Container(
    decoration: BoxDecoration(boxShadow: [BoxShadow(color: deepDarkBrown.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))]),
    child: BottomNavigationBar(
      currentIndex: index,
      onTap: (i) => ref.read(navigationIndexProvider.notifier).state = i,
      backgroundColor: Colors.white,
      selectedItemColor: accentPink,
      unselectedItemColor: primaryBrown.withOpacity(0.5),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
      ],
    ),
  );
}