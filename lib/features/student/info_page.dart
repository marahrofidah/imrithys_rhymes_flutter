import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: unused_import
import '../../services/auth_service.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol Back di kiri atas
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF65A6F1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Logo Tengah di bawah tombol back
              Center(
                child: Image.asset(
                  'assets/images/logo.webp',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Tentang Aplikasi Card (dengan overlapping icon tentang.webp)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 25, left: 25),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Tentang Aplikasi',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF65A6F1),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Aplikasi pembelajaran kitab Imrithi yang membantu pengguna menghafal, mendengarkan, dan menguji pemahaman secara interaktif dilengkapi metode tikrar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: -5,
                    top: -10,
                    child: Image.asset(
                      'assets/images/tentang.webp',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Fitur Aplikasi Card (Kuning)
              _buildStudentFeatures(),
              const SizedBox(height: 24),

              // 3. Panduan Penggunaan Card (Ungu)
              _buildStudentGuide(),
              const SizedBox(height: 24),

              // 4. Tentang Penyusun Card (Pink)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF66893),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tentang Penyusun',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Mar'ah Rofidah Abidah Kh.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Mahasiswa Teknik Informatika\nUniversitas Darussalam Gontor",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dosen Pembimbing :',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '1. Al-Ustadz Dihin Muriyatmoko S.ST., M.T.\n2. Al-Ustadz Faisal Reza Pradhana S.Kom., M.Kom.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Social Links Card (Biru Muda)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF9CCAFF),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildContactRow(
                      Icons.email_outlined,
                      'marahrofidah7@gmail.com',
                      () => _launchUrl('mailto:marahrofidah7@gmail.com'),
                    ),
                    const SizedBox(height: 12),
                    _buildContactRow(
                      FontAwesomeIcons.github,
                      'marahrofidah',
                      () => _launchUrl('https://github.com/marahrofidah'),
                    ),
                    const SizedBox(height: 12),
                    _buildContactRow(
                      FontAwesomeIcons.linkedin,
                      "Mar'ah Rofidah Abidah Kh.",
                      () => _launchUrl('https://www.linkedin.com/in/-fdaabdh/'),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 130,
              ), // Spasi agar tidak tertutup bottom nav
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────

  Widget _buildFiturItem({
    required String imagePath,
    required String label,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 70, width: 70, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $urlString: $e');
    }
  }

  Widget _buildContactRow(dynamic icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          icon is IconData
              ? Icon(icon, color: Colors.white, size: 22)
              : FaIcon(icon as FaIconData, color: Colors.white, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          Icons.home_rounded,
                          0,
                          onTap: () => Navigator.pop(context),
                        ),
                        _buildNavItem(
                          Icons.menu_book_rounded,
                          1,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/pelajari-kitab');
                          },
                        ),
                        _buildNavItem(
                          Icons.person_rounded,
                          2,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                        _buildNavItem(
                          Icons.logout_rounded,
                          3,
                          onTap: () => _handleLogout(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    int index, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFF66893).withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFFF66893) : Colors.grey.shade400,
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Aplikasi'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentFeatures() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCC100),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Fitur Aplikasi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFiturItem(
                  imagePath: 'assets/images/earphone.webp',
                  label: 'Dengarkan\nSyair',
                  textColor: const Color(0xFF3A327C),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildFiturItem(
                  imagePath: 'assets/images/kelas.webp',
                  label: 'Monitoring\nGuru',
                  textColor: const Color(0xFF3A327C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildFiturItem(
                  imagePath: 'assets/images/kitab.webp',
                  label: 'Pelajari Kitab',
                  textColor: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildFiturItem(
                  imagePath: 'assets/images/kuis.webp',
                  label: 'Kerjakan Kuis',
                  textColor: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF6E6EB0),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Panduan Penggunaan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/images/1.webp',
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Image.asset(
            'assets/images/2.webp',
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Image.asset(
            'assets/images/3.webp',
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Image.asset(
            'assets/images/4.webp',
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
