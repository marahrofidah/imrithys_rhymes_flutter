import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

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
  late final String userId;
  bool _checkingEnrollment = true;
  int _streakCount = 0;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    userName = user?.fullName ?? user?.username ?? 'Murid';
    userGender = user?.gender ?? '';
    userId = user?.id ?? '';
    _checkEnrollment();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    if (userId.isEmpty) return;
    final count = await SupabaseService().getStudentStreakCount(userId);
    if (mounted) setState(() => _streakCount = count);
  }

  Future<void> _checkEnrollment() async {
    final enrolled = await SupabaseService().isStudentEnrolled(userId);
    if (!mounted) return;
    setState(() {
      _checkingEnrollment = false;
    });

    // Tampilkan dialog jika belum punya kelas
    if (!enrolled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showJoinClassDialog();
      });
    }
  }

  void _showJoinClassDialog() {
    final codeController = TextEditingController();
    bool isJoining = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon kelas
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF65A6F1).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🏫', style: TextStyle(fontSize: 34)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Masukkan Kode Kelas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Minta kode kelas kepada gurumu\nuntuk bergabung ke kelas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input kode
                    TextField(
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: Color(0xFF2D2D2D),
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'XXXXXX',
                        hintStyle: TextStyle(
                          fontSize: 22,
                          letterSpacing: 4,
                          color: Colors.grey.shade300,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF65A6F1),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Gabung
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65A6F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isJoining
                            ? null
                            : () async {
                                final code = codeController.text
                                    .trim()
                                    .toUpperCase();
                                if (code.length != 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Kode kelas harus 6 karakter!',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setDialogState(() => isJoining = true);

                                final supabase = SupabaseService();
                                final classData = await supabase.getClassByCode(
                                  code,
                                );

                                if (classData == null) {
                                  if (context.mounted) {
                                    setDialogState(() => isJoining = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Kode kelas tidak ditemukan!',
                                        ),
                                        backgroundColor: Colors.red.shade400,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                final success = await supabase
                                    .enrollStudentToClass(userId, classData.id);

                                if (!context.mounted) return;

                                if (success) {
                                  Navigator.of(dialogContext).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Berhasil bergabung ke ${classData.name}! 🎉',
                                      ),
                                      backgroundColor: const Color(0xFF65A6F1),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                } else {
                                  setDialogState(() => isJoining = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Gagal bergabung ke kelas.',
                                      ),
                                      backgroundColor: Colors.red.shade400,
                                    ),
                                  );
                                }
                              },
                        child: isJoining
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Gabung Kelas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingEnrollment) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF65A6F1)),
        ),
      );
    }

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
            // Info icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA3C7F0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
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

            // Logo tengah
            Image.asset(
              'assets/images/imrithys_rhymes.png',
              height: 48,
              fit: BoxFit.contain,
            ),

            // User avatar — sesuai gender dari database
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(
                    userGender == 'laki-laki'
                        ? 'assets/images/laki-laki.png'
                        : userGender == 'perempuan'
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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

              GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(context, '/dengarkan-syair');
                  // Refresh streak setelah kembali dari halaman syair
                  _loadStreak();
                },
                child: SizedBox(
                  height: 140,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        top: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6E6EB0),
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
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
    final bool isTextRight = textAlign == TextAlign.right;

    return GestureDetector(
      onTap: () {},
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 2,
              right: 2,
              bottom: -14,
              top: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
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
                alignment: isTextRight
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
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
