import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../models/class_model.dart';
import 'stats_page.dart';
import 'profile_page.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  late final String teacherName;
  late final String teacherId;
  late final String teacherGender;

  ClassModel? _classModel;
  List<Map<String, dynamic>> _students = [];
  Map<String, Map<String, dynamic>> _studentProgressMap = {};
  bool _isLoading = true;
  bool _isOffline = false;
  int _selectedIndex = 0;
  bool _hasSetInitialIndex = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    teacherName = user?.fullName ?? user?.username ?? 'Ustadz/ah';
    teacherId = user?.id ?? '';
    teacherGender = user?.gender ?? '';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
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
      try {
        final supabase = SupabaseService();
        final classData = await supabase.getClassByTeacherId(teacherId);
        List<Map<String, dynamic>> students = [];
        Map<String, Map<String, dynamic>> progressMap = {};
        if (classData != null) {
          students = await supabase.getStudentsInClass(classData.id);
          final studentIds = students.map((s) => s['id'] as String).toList();
          progressMap = await supabase.getStudentsQuizAndStreak(studentIds);
        }
        if (mounted) {
          setState(() {
            _classModel = classData;
            _students = students;
            _studentProgressMap = progressMap;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && !_hasSetInitialIndex) {
      _selectedIndex = args;
      _hasSetInitialIndex = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF65A6F1)),
            )
          : SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF65A6F1),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Header Row (scrolls with page content)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Info icon
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/teacher-info'),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFA3C7F0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'i',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Logo tengah
                            Image.asset(
                              'assets/images/imrithys_rhymes.webp',
                              height: 48,
                              fit: BoxFit.contain,
                            ),

                            // Avatar guru sesuai gender — tap untuk buka profil
                            GestureDetector(
                              onTap: () => setState(() => _selectedIndex = 2),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade200,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage(
                                      teacherGender == 'laki-laki'
                                          ? 'assets/images/laki-laki.webp'
                                          : teacherGender == 'perempuan'
                                          ? 'assets/images/perempuan.webp'
                                          : 'assets/images/person.webp',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Konten sesuai tab terpilih
                        _buildTabContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return TeacherStatsPage(
          students: _students,
          studentProgressMap: _studentProgressMap,
          isOffline: _isOffline,
        );
      case 2:
        return TeacherProfilePage(
          teacherName: teacherName,
          teacherGender: teacherGender,
          classModel: _classModel,
          totalStudents: _students.length,
          onLogout: _handleActualLogout,
          isOffline: _isOffline,
        );
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    if (_isOffline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Welcome Card
          _buildWelcomeCard(),
          const SizedBox(height: 20),

          // Offline notice card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(height: 24),
                const Text(
                  'Koneksi Internet Diperlukan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dashboard memerlukan koneksi internet untuk memuat kelas dan perkembangan murid dari server.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.5,
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
                    onPressed: _loadData,
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
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Welcome Card
        _buildWelcomeCard(),
        const SizedBox(height: 14),

        // ── Kode Kelas Card ──
        _buildKodeKelasCard(),
        const SizedBox(height: 14),

        // ── Stats Row ──
        _buildStatsRow(),
        const SizedBox(height: 20),

        // ── Daftar Murid ──
        const Text(
          'Daftar Murid',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(221, 107, 107, 107),
          ),
        ),
        const SizedBox(height: 12),

        _students.isEmpty ? _buildEmptyStudents() : _buildStudentList(),

        const SizedBox(height: 100),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Welcome Card
  // ─────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF65A6F1),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
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
                  'Assalamualaikum,\n$teacherName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                const SizedBox(
                  width: 190,
                  child: Text(
                    'Pantau perkembangan hafalan kelas Anda sekarang!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Gambar kanan
          Positioned(
            right: 10,
            bottom: 0,
            child: Image.asset(
              'assets/images/person.webp',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Kode Kelas Card
  // ─────────────────────────────────────────
  Widget _buildKodeKelasCard() {
    final code = _classModel?.code ?? '------';

    return GestureDetector(
      onTap: () => _copyKodeKelas(code),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFA231),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                  children: [
                    const TextSpan(text: 'Kode Kelas : '),
                    TextSpan(
                      text: '" $code "',
                      style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Bell / Copy icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.copy_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyKodeKelas(String code) {
    if (code == '------') return;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kode kelas "$code" disalin!'),
        backgroundColor: const Color(0xFF65A6F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Stats Row
  // ─────────────────────────────────────────
  Widget _buildStatsRow() {
    final totalMurid = _students.length;
    // Dummy: aktif hari ini (nanti bisa dari field last_active)
    final aktifHariIni = totalMurid > 0 ? (totalMurid * 0.4).ceil() : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '$totalMurid',
            label: 'Total Murid',
            color: const Color(0xFF6E6EB0),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildStatCard(
            value: '$aktifHariIni',
            label: 'Aktif Hari ini',
            color: const Color(0xFFF66893),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Student List
  // ─────────────────────────────────────────
  Widget _buildStudentList() {
    return Column(
      children: List.generate(_students.length, (index) {
        final student = _students[index];
        final id = student['id'] as String? ?? '';
        final name =
            student['full_name'] as String? ??
            student['username'] as String? ??
            'Murid';

        final progress = _studentProgressMap[id];
        final quizPassed = progress?['quiz_passed'] as int? ?? 0;
        final streak = progress?['streak'] as int? ?? 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStudentCard(
            name: name,
            quizDone: quizPassed,
            streak: streak,
          ),
        );
      }),
    );
  }

  Widget _buildStudentCard({
    required String name,
    required int quizDone,
    required int streak,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Info murid
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  'Kuis selesai: $quizDone/33',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Streak badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/api.webp',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStudents() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Text('📚', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Belum ada murid yang bergabung',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bagikan kode kelas ke murid Anda',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Bottom Nav
  // ─────────────────────────────────────────
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
                        _buildNavItem(Icons.home_rounded, 0),
                        _buildNavItem(Icons.bar_chart_rounded, 1),
                        _buildNavItem(Icons.person_rounded, 2),
                        _buildNavItem(Icons.logout_rounded, 3),
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

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 3) _handleLogout();
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
}
