import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../models/class_model.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  late final String userId;
  late final String userName;
  late final String userUsername;
  late final String userEmail;
  late final String userGender;
  late final DateTime? userCreatedAt;

  int _streakCount = 0;
  int _completedBabs = 0;
  String _className = 'Belum bergabung ke kelas';
  String _classEnrollmentDate = '';
  bool _loading = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    userId = user?.id ?? '';
    userName = user?.fullName ?? user?.username ?? 'Murid';
    userUsername = user?.username ?? '-';
    userEmail = user?.email ?? '-';
    userGender = user?.gender ?? '';
    userCreatedAt = user?.createdAt;
    _checkOfflineAndLoad();
  }

  Future<void> _checkOfflineAndLoad() async {
    if (mounted) setState(() => _loading = true);
    
    bool offline = false;
    try {
      final result = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 2));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        offline = true;
      }
    } catch (_) {
      offline = true;
    }

    if (mounted) {
      setState(() {
        _isOffline = offline;
      });
    }

    if (!offline) {
      _loadProfileData();
    } else {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadProfileData() async {
    if (userId.isEmpty) return;

    try {
      final results = await Future.wait([
        SupabaseService().getStudentStreakCount(userId),
        SupabaseService().getPassedBabCount(userId),
        SupabaseService().getStudentClassesWithEnrollment(userId),
      ]);

      final streak = results[0] as int;
      final completed = results[1] as int;
      final enrollments = results[2] as List<Map<String, dynamic>>;

      String className = 'Belum bergabung ke kelas';
      String enrollmentDate = '';
      if (enrollments.isNotEmpty) {
        final firstEnrollment = enrollments.first;
        final classInfo = firstEnrollment['class'] as ClassModel;
        className = classInfo.name;

        final joinedAtStr = firstEnrollment['joined_at'] as String?;
        if (joinedAtStr != null) {
          final joinedAt = DateTime.tryParse(joinedAtStr);
          if (joinedAt != null) {
            enrollmentDate = _formatDate(joinedAt);
          }
        }
      }

      if (mounted) {
        setState(() {
          _streakCount = streak;
          _completedBabs = completed;
          _className = className;
          _classEnrollmentDate = enrollmentDate;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: _isOffline
          ? _buildOfflineScreen()
          : _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF65A6F1)),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Statistik Belajar'),
                            const SizedBox(height: 12),
                            _buildStatsGrid(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Detail Akun'),
                            const SizedBox(height: 12),
                            _buildAccountDetailsCard(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Kelas Saya'),
                            const SizedBox(height: 12),
                            _buildClassCard(),
                            const SizedBox(height: 36),
                            _buildLogoutButton(),
                            const SizedBox(height: 130),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildOfflineScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 40),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEAEA),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      color: Color(0xFFEF4444),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Koneksi Internet Diperlukan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Profil memerlukan koneksi internet untuk memuat statistik belajar dan info kelas dari server.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 180,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65A6F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _checkOfflineAndLoad,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Coba Lagi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 180,
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _handleActualLogout,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Logout Akun',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 130),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF65A6F1),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 188, 188, 188),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(80),
          bottomRight: Radius.circular(80),
        ),
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              image: DecorationImage(
                image: AssetImage(
                  userGender == 'laki-laki'
                      ? 'assets/images/laki-laki.webp'
                      : userGender == 'perempuan'
                      ? 'assets/images/perempuan.webp'
                      : 'assets/images/person.webp',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nama Lengkap
          Text(
            userName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          // Peran / Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Murid',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(221, 131, 131, 131),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        // Streak Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA231),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Image(
                  image: AssetImage('assets/images/api.webp'),
                  width: 50,
                  height: 50,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Focus Track',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_streakCount Hari',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Progress Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF66893),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Image(
                  image: AssetImage('assets/images/kuis.webp'),
                  width: 50,
                  height: 50,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Progress Kuis',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_completedBabs/33 Lulus',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Username', userUsername),
          const SizedBox(height: 12),
          _buildDetailRow('Email', userEmail),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Jenis Kelamin',
            userGender.isEmpty
                ? '-'
                : (userGender == 'laki-laki' ? 'Laki-laki' : 'Perempuan'),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Tanggal Bergabung', _formatDate(userCreatedAt)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Color.fromARGB(221, 131, 131, 131),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 45, 45, 45),
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            // decoration: BoxDecoration(
            //   color: const Color.fromARGB(
            //     255,
            //     164,
            //     164,
            //     164,
            //   ).withValues(alpha: 0.1),
            //   shape: BoxShape.circle,
            // ),
            child: Image(
              image: AssetImage('assets/images/kelas.webp'),
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _className,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                if (_classEnrollmentDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tanggal Bergabung: $_classEnrollmentDate',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(221, 131, 131, 131),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _handleActualLogout,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 8),
            Text(
              'Keluar dari Akun',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleActualLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Anda? Sesi login akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              AuthService().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
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

  Widget _buildBottomNav() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
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
                        _buildNavItem(Icons.person_rounded, 2, isActive: true),
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
              ? const Color(0xFF65A6F1).withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFF65A6F1) : Colors.grey.shade400,
        ),
      ),
    );
  }
}
