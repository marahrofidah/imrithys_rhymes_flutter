import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: unused_import
import '../../services/auth_service.dart';

class TeacherInfoPage extends StatefulWidget {
  const TeacherInfoPage({super.key});

  @override
  State<TeacherInfoPage> createState() => _TeacherInfoPageState();
}

class _TeacherInfoPageState extends State<TeacherInfoPage> {
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

              // 1. Tentang Aplikasi Card
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
              _buildTeacherFeatures(),
              const SizedBox(height: 24),

              // 3. Panduan Penggunaan Card (Ungu)
              _buildTeacherGuide(),
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
                height: 140,
              ), // Spasi agar tidak tertutup bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTeacherFeatures() {
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
            'Fitur Aplikasi (Guru)',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFiturItem(
                  imagePath: 'assets/images/kelas.webp',
                  label: 'Manajemen\nKelas',
                  textColor: const Color(0xFF526993),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildFiturItem(
                  imagePath: 'assets/images/monitoring.webp',
                  label: 'Monitoring\nProgress Murid',
                  textColor: const Color(0xFF2A617D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
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
            'Panduan Penggunaan (Guru)',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Card 1
          _buildGuideCard(
            step: '1',
            isLeftImage: true,
            imagePath: 'assets/images/dapatkan.webp',
            title: 'Dapatkan Kode Kelas',
            description: const Text.rich(
              TextSpan(
                text: 'Pada halaman ',
                children: [
                  TextSpan(
                    text: 'Beranda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  TextSpan(text: ', guru akan menemukan '),
                  TextSpan(
                    text: 'Kode Kelas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  TextSpan(
                    text:
                        ' yang dibuat secara otomatis. Kode ini digunakan sebagai akses agar ',
                  ),
                  TextSpan(
                    text: 'Murid',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  TextSpan(text: ' dapat bergabung ke dalam kelas.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Card 2
          _buildGuideCard(
            step: '2',
            isLeftImage: false,
            imagePath: 'assets/images/bagikan.webp',
            title: 'Bagikan Kode Kelas',
            description: const Text.rich(
              TextSpan(
                text: 'Ketuk kartu ',
                children: [
                  TextSpan(
                    text: 'Kode Kelas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  TextSpan(
                    text:
                        ' untuk menyalin kode secara otomatis, kemudian bagikan kepada seluruh murid yang akan mengikuti pembelajaran.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Card 3
          _buildGuideCard(
            step: '3',
            isLeftImage: true,
            imagePath: 'assets/images/murid.webp',
            title: 'Murid Bergabung',
            description: const Text.rich(
              TextSpan(
                text: 'Minta murid memasukkan ',
                children: [
                  TextSpan(
                    text: 'Kode Kelas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  TextSpan(
                    text:
                        ' saat pertama kali menggunakan aplikasi. Setelah berhasil, mereka akan langsung terhubung dengan kelas guru.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Card 4
          _buildGuideCard(
            step: '4',
            isLeftImage: false,
            imagePath: 'assets/images/pantau.webp',
            title: 'Pantau Perkembangan',
            description: const Text.rich(
              TextSpan(
                text: 'Lihat aktivitas belajar murid melalui halaman ',
                children: [
                  TextSpan(
                    text: 'Beranda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  TextSpan(
                    text:
                        ', serta pantau statistik penyelesaian materi dan kuis pada menu ',
                  ),
                  TextSpan(
                    text: 'Statistik',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard({
    required String step,
    required bool isLeftImage,
    required String imagePath,
    required String title,
    required Widget description,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: isLeftImage
                ? [
                    // Left Image
                    Image.asset(
                      imagePath,
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 14),
                    // Right Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A327C),
                            ),
                          ),
                          const SizedBox(height: 6),
                          DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                              fontFamily: 'Roboto',
                            ),
                            child: description,
                          ),
                        ],
                      ),
                    ),
                  ]
                : [
                    // Left Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A327C),
                            ),
                          ),
                          const SizedBox(height: 6),
                          DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                              fontFamily: 'Roboto',
                            ),
                            child: description,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Right Image
                    Image.asset(
                      imagePath,
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ],
          ),
        ),

        // Floating Step Number Circle
        Positioned(
          left: isLeftImage ? 0 : null,
          right: !isLeftImage ? 0 : null,
          top: -12,
          child: Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              color: Color(0xFFFCC100),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiturItem({
    required String imagePath,
    required String label,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
          Image.asset(imagePath, height: 60, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(dynamic icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon is IconData
              ? Icon(icon, color: Colors.white, size: 20)
              : FaIcon(icon as FaIconData, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Flexible(
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
                          onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/teacher-dashboard',
                            (route) => false,
                            arguments: 0,
                          ),
                        ),
                        _buildNavItem(
                          Icons.bar_chart_rounded,
                          1,
                          onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/teacher-dashboard',
                            (route) => false,
                            arguments: 1,
                          ),
                        ),
                        _buildNavItem(
                          Icons.person_rounded,
                          2,
                          onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/teacher-dashboard',
                            (route) => false,
                            arguments: 2,
                          ),
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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka $urlString')),
        );
      }
    }
  }
}
