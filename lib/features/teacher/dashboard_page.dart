import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../models/class_model.dart';

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
  bool _isLoading = true;
  int _selectedIndex = 0;

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
    try {
      final supabase = SupabaseService();
      final classData = await supabase.getClassByTeacherId(teacherId);
      List<Map<String, dynamic>> students = [];
      if (classData != null) {
        students = await supabase.getStudentsInClass(classData.id);
      }
      if (mounted) {
        setState(() {
          _classModel = classData;
          _students = students;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    color: Color(0xFF65A6F1),
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

            // Avatar guru sesuai gender
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: AssetImage(
                    teacherGender == 'laki-laki'
                        ? 'assets/images/laki-laki.png'
                        : teacherGender == 'perempuan'
                        ? 'assets/images/perempuan.png'
                        : 'assets/images/person.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF65A6F1)),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF65A6F1),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Column(
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

                      _students.isEmpty
                          ? _buildEmptyStudents()
                          : _buildStudentList(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

      bottomNavigationBar: _buildBottomNav(),
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
              'assets/images/person.png',
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
        final name =
            student['full_name'] as String? ??
            student['username'] as String? ??
            'Murid';

        // Data dummy untuk quiz count & streak
        // Nanti diganti dengan data real dari tabel progress
        final dummyQuizDone = (index * 3 + 1) % 10;
        final dummyStreak = (index * 4 + 3) % 15;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStudentCard(
            name: name,
            quizDone: dummyQuizDone,
            streak: dummyStreak,
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kuis selesai: $quizDone/33',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
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
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: const TextStyle(
                    fontSize: 16,
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
    return Container(
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
              _buildNavItem(Icons.bar_chart_rounded, 1),
              _buildNavItem(Icons.person_rounded, 2),
              _buildNavItem(Icons.logout_rounded, 3),
            ],
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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
