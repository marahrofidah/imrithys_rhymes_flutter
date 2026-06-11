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
  late final String userGender;
  final int _streakCount = 9;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    userName = user?.fullName ?? user?.username ?? 'Murid';
    userGender = user?.gender ?? ''; // 'laki-laki', 'perempuan', atau ''
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
                color: const Color(0xFFA3C7F0).withValues(alpha: 0.18),
              ),
              child: const Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color.fromARGB(255, 255, 255, 255),
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

            // User avatar — sesuai gender dari database
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: AssetImage(
                    userGender == 'laki-laki'
                        ? 'assets/images/laki-laki.png'
                        : userGender == 'perempuan'
                        ? 'assets/images/perempuan.png'
                        : 'assets/images/person.png', // default
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF65A6F1),
                  borderRadius: BorderRadius.circular(50),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Teks kiri
                    Positioned(
                      left: 30,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Assalamualaikum,\n$userName',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Siap menaklukkan\nbait hari ini?',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Gambar orang di kanan (menonjol ke atas)
                    Positioned(
                      right: 20,
                      bottom: 0,
                      child: Image.asset(
                        'assets/images/person.png',
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA231),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    // Lingkaran putih dengan api + angka streak
                    Container(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 18,
                        top: 12,
                        bottom: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(139, 255, 255, 255),
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/api.png',
                            width: 38,
                            height: 38,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 0),
                          Text(
                            '$_streakCount',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B00),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Dengarkan 1 Bab Syair sebanyak 5x agar Focus Track bertambah',
                            style: TextStyle(
                              fontSize: 15,
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

              const Center(
                child: Text(
                  'Rhymes Activity',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 131, 131, 131),
                  ),
                ),
              ),
              const SizedBox(height: 0),

              SizedBox(
                height: 140,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Card background
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6E6EB0),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.only(
                          left: 130,
                          right: 20,
                          top: 12,
                          bottom: 12,
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Dengarkan Syair',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Pilih bab yang ingin kamu\ndengarkan!',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: -5,
                      top: 0,
                      child: Image.asset(
                        'assets/images/earphone.png',
                        width: 124,
                        height: 124,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kerjakan Kuis (Pink) - image kiri atas, teks kiri bawah
                  Expanded(
                    child: _buildSquareCard(
                      imagePath: 'assets/images/kuis.png',
                      label: 'Kerjakan\nKuis',
                      color: const Color(0xFFF66893),
                      imageAlignment: Alignment.topLeft,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Pelajari Kitab (Yellow) - image kanan atas, teks kanan bawah
                  Expanded(
                    child: _buildSquareCard(
                      imagePath: 'assets/images/kitab.png',
                      label: 'Pelajari\nKitab',
                      color: const Color(0xFFFCC100),
                      imageAlignment: Alignment.topRight,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -5),
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
    Alignment imageAlignment = Alignment.topLeft,
    TextAlign textAlign = TextAlign.center,
  }) {
    final bool isRight = imageAlignment == Alignment.topRight;
    final bool isTextRight =
        textAlign == TextAlign.right; // posisi teks independen

    return GestureDetector(
      onTap: () {},
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card background
            Positioned(
              left: 2,
              right: 2,
              bottom: -14,
              top: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: isTextRight
                    ? Alignment
                          .bottomRight // teks mepet kanan
                    : Alignment.bottomLeft, // teks mepet kiri
                padding: EdgeInsets.only(
                  bottom: 18,
                  left: isTextRight ? 0 : 28,
                  right: isTextRight ? 28 : 0,
                ),
                child: Text(
                  label,
                  textAlign: textAlign,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ),

            // Image overflow ke atas
            Positioned(
              top: -12,
              left: isRight ? null : -10,
              right: isRight ? -7 : null,
              child: Image.asset(
                imagePath,
                width: 130,
                height: 130,
                fit: BoxFit.contain,
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
