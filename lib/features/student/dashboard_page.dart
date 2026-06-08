import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class StudentDashboardPage extends StatefulWidget {
  final String? classId;

  const StudentDashboardPage({super.key, this.classId});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  int _selectedIndex = 0;
  late final String userName;
  final int _streakCount = 9; // Bisa diambil dari backend nanti

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    // Gunakan fullName (nama lengkap dari register), bukan username
    userName = user?.fullName ?? user?.username ?? 'Murid';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Info icon (lingkaran biru muda)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5BAEF0).withValues(alpha: 0.18),
              ),
              child: const Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF5BAEF0),
                  ),
                ),
              ),
            ),

            // Logo tengah
            Image.asset(
              'assets/images/imrithys_rhymes.png',
              height: 48,
              fit: BoxFit.contain,
            ),

            // User avatar (foto orang bulat)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                image: const DecorationImage(
                  image: AssetImage('assets/images/person.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== WELCOME CARD (Biru) =====
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF5BAEF0),
                  borderRadius: BorderRadius.circular(22),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Teks kiri
                    Positioned(
                      left: 20,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Assalamualaikum,\n$userName',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Siap menaklukkan\nbait hari ini?',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Gambar orang di kanan (menonjol ke atas)
                    Positioned(
                      right: -4,
                      bottom: 0,
                      child: Image.asset(
                        'assets/images/person.png',
                        height: 155,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Bintang kecil dekorasi
                    const Positioned(
                      right: 110,
                      top: 14,
                      child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                    const Positioned(
                      right: 95,
                      top: 30,
                      child: Text('✦', style: TextStyle(color: Colors.white60, fontSize: 8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ===== FOCUS TRACK CARD (Orange) =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC436),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    // Lingkaran putih dengan api + angka streak
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/api.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Text(
                              '$_streakCount',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B00),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Teks Focus Track
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Focus Track',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Dengarkan 1 Bab Syair\nsebanyak 5x agar Focus\nTrack bertambah',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ===== RHYMES ACTIVITY HEADER =====
              const Center(
                child: Text(
                  'Rhymes Activity',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ===== DENGARKAN SYAIR CARD (Purple) =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B6FB5),
                  borderRadius: BorderRadius.circular(22),
                ),
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    // Gambar earphone menonjol ke kiri
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
                      child: Image.asset(
                        'assets/images/earphone.png',
                        width: 110,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Teks
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dengarkan Syair',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Pilih bab yang ingin kamu\ndengarkan!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ===== GRID 2 KARTU: Kerjakan Kuis + Pelajari Kitab =====
              Row(
                children: [
                  // Kerjakan Kuis (Pink)
                  Expanded(
                    child: _buildSquareCard(
                      imagePath: 'assets/images/kius.png',
                      label: 'Kerjakan\nKuis',
                      color: const Color(0xFFEF6285),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Pelajari Kitab (Yellow/Amber)
                  Expanded(
                    child: _buildSquareCard(
                      imagePath: 'assets/images/kitab.png',
                      label: 'Pelajari\nKitab',
                      color: const Color(0xFFFFC436),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ===== BOTTOM NAVIGATION BAR =====
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 0),
                _buildNavItem(Icons.list_alt_rounded, 1),
                _buildNavItem(Icons.person_rounded, 2),
                _buildNavItem(Icons.logout_rounded, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareCard({
    required String imagePath,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Gambar di atas
            Positioned(
              top: 10,
              child: Image.asset(
                imagePath,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),

            // Label di bawah
            Positioned(
              bottom: 14,
              left: 10,
              right: 10,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 3) {
          _handleLogout();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5BAEF0).withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? const Color(0xFF5BAEF0) : Colors.grey.shade400,
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
