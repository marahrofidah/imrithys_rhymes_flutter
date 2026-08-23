import 'dart:ui';
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
  bool _isClassMode = false;
  String? _classId;
  List<Map<String, dynamic>> _topActiveClassmates = [];
  bool _loadingClassmates = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    userName = user?.fullName ?? user?.username ?? 'Murid';
    userGender = user?.gender ?? '';
    userId = user?.id ?? '';
    _isClassMode = AuthService().isClassMode;
    _checkEnrollment();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    if (userId.isEmpty) return;
    try {
      bool streakReset = false;
      int count = 0;
      if (_isClassMode) {
        streakReset = await SupabaseService().checkAndResetStreak(userId);
        count = await SupabaseService().getStudentStreakCount(userId);
        if (_classId != null) {
          _loadClassmates(_classId!);
        }
      } else {
        streakReset = await AuthService().checkAndResetLocalStreak(userId);
        count = await AuthService().getLocalStreakCount(userId);
      }
      if (mounted) {
        setState(() => _streakCount = count);
        if (streakReset) {
          _showStreakLoseDialog();
        }
      }
    } catch (e) {
      debugPrint('Error loading streak: $e');
    }
  }

  Future<void> _loadClassmates(String classId) async {
    if (!mounted) return;
    setState(() => _loadingClassmates = true);
    try {
      final classmates = await SupabaseService().getStudentsInClass(classId);
      if (classmates.isNotEmpty) {
        final studentIds = classmates.map((s) => s['id'] as String).toList();
        final progress = await SupabaseService().getStudentsQuizAndStreak(
          studentIds,
        );

        final List<Map<String, dynamic>> mappedClassmates = [];
        for (var student in classmates) {
          final sId = student['id'] as String;
          final stats = progress[sId] ?? {'streak': 0, 'quiz_passed': 0};
          mappedClassmates.add({
            'id': sId,
            'name': student['full_name'] ?? student['username'] ?? 'Murid',
            'gender': student['gender'] ?? '',
            'streak': stats['streak'] ?? 0,
            'quiz_passed': stats['quiz_passed'] ?? 0,
          });
        }

        // Sort by streak desc, then quiz_passed desc
        mappedClassmates.sort((a, b) {
          final streakCompare = (b['streak'] as int).compareTo(
            a['streak'] as int,
          );
          if (streakCompare != 0) return streakCompare;
          return (b['quiz_passed'] as int).compareTo(a['quiz_passed'] as int);
        });

        if (mounted) {
          setState(() {
            _topActiveClassmates = mappedClassmates.take(3).toList();
            _loadingClassmates = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _loadingClassmates = false);
        }
      }
    } catch (err) {
      debugPrint('Error loading active classmates: $err');
      if (mounted) {
        setState(() => _loadingClassmates = false);
      }
    }
  }

  Future<void> _checkEnrollment() async {
    try {
      final enrollments = await SupabaseService()
          .getStudentClassesWithEnrollment(userId);
      if (!mounted) return;

      String? classId;
      if (enrollments.isNotEmpty) {
        classId = enrollments.first['class'].id;
      }

      setState(() {
        _classId = classId;
        _checkingEnrollment = false;
      });

      if (classId != null) {
        _loadClassmates(classId);
      }
    } catch (e) {
      debugPrint('Error checking enrollment: $e');
      if (mounted) {
        setState(() {
          _checkingEnrollment = false;
        });
      }
    }
  }

  void _showStreakLoseDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon api padam/sedih
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAEA),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('💔', style: TextStyle(fontSize: 34)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Streak Lose!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yah, streak kamu terputus karena kemarin kamu tidak menyelesaikan target belajar. Yuk dengarkan syair lagi hari ini untuk memulai streak baru!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA231),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'Mulai Lagi',
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
  }

  // ignore: unused_element
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
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 40,
                      bottom: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon kelas
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF65A6F1,
                            ).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.school_rounded,
                              size: 34,
                              color: Color(0xFF65A6F1),
                            ),
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
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                    final classData = await supabase
                                        .getClassByCode(code);

                                    if (classData == null) {
                                      if (context.mounted) {
                                        setDialogState(() => isJoining = false);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Kode kelas tidak ditemukan!',
                                            ),
                                            backgroundColor:
                                                Colors.red.shade400,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    final success = await supabase
                                        .enrollStudentToClass(
                                          userId,
                                          classData.id,
                                        );

                                    if (!context.mounted) return;

                                    if (success) {
                                      await AuthService().setClassMode(true);
                                      if (!context.mounted) return;
                                      if (!dialogContext.mounted) return;
                                      if (mounted) {
                                        setState(() {
                                          _isClassMode = true;
                                        });
                                        _loadStreak();
                                      }
                                      Navigator.of(dialogContext).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Berhasil bergabung ke ${classData.name}! 🎉',
                                          ),
                                          backgroundColor: const Color(
                                            0xFF65A6F1,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      setDialogState(() => isJoining = false);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF2D2D2D),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleModeChange(bool isClass) async {
    if (isClass == _isClassMode) return;

    if (isClass) {
      setState(() => _checkingEnrollment = true);
      try {
        final enrolled = await SupabaseService().isStudentEnrolled(userId);
        if (!mounted) return;
        if (enrolled) {
          await AuthService().setClassMode(true);
          if (!mounted) return;
          setState(() {
            _isClassMode = true;
            _checkingEnrollment = false;
          });
          _loadStreak();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda di dalam Kelas!'),
              backgroundColor: Color(0xFF65A6F1),
            ),
          );
        } else {
          setState(() => _checkingEnrollment = false);
          _showJoinClassDialog();
        }
      } catch (e) {
        debugPrint('Error switching to class mode: $e');
        if (mounted) {
          setState(() => _checkingEnrollment = false);
        }
      }
    } else {
      await AuthService().setClassMode(false);
      if (!mounted) return;
      setState(() {
        _isClassMode = false;
      });
      _loadStreak();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil beralih ke Mandiri!'),
          backgroundColor: Color(0xFF65A6F1),
        ),
      );
    }
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
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (scrolls with page content)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Info icon
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/info'),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFA3C7F0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
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

                    // User avatar — sesuai gender dari database
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: Container(
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
                                  ? 'assets/images/laki-laki.webp'
                                  : userGender == 'perempuan'
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
                Container(
                  width: double.infinity,
                  height: 195,
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
                            const SizedBox(height: 10),
                            Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(cardColor: Colors.white),
                              child: PopupMenuButton<bool>(
                                onSelected: (bool isClass) {
                                  _handleModeChange(isClass);
                                },
                                offset: const Offset(0, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                itemBuilder: (context) => [
                                  const PopupMenuItem<bool>(
                                    value: false,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.menu_book_rounded,
                                          color: Color(0xFF65A6F1),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Mandiri',
                                          style: TextStyle(
                                            color: Color(0xFF2D2D2D),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<bool>(
                                    value: true,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.school_rounded,
                                          color: Color(0xFF65A6F1),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Dalam Kelas',
                                          style: TextStyle(
                                            color: Color(0xFF2D2D2D),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFCC100),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isClassMode
                                            ? Icons.school_rounded
                                            : Icons.menu_book_rounded,
                                        color: const Color(0xFF65A6F1),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isClassMode
                                            ? 'Dalam Kelas'
                                            : 'Mandiri',
                                        style: const TextStyle(
                                          color: Color(0xFF65A6F1),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF65A6F1),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        right: 20,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/person.webp',
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (_classId != null && _isClassMode) ...[
                  _buildSimpleClassmateLeaderboard(),
                  const SizedBox(height: 14),
                ],

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
                              'assets/images/api.webp',
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
                    // Refresh streak setelah kembali dari halaman sy
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
                            'assets/images/earphone.webp',
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
                        imagePath: 'assets/images/kuis_db.webp',
                        label: 'Kerjakan\nKuis',
                        color: const Color(0xFFF66893),
                        imageAlignment: Alignment.topLeft,
                        textAlign: TextAlign.right,
                        onTap: () =>
                            Navigator.pushNamed(context, '/kerjakan-kuis'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildSquareCard(
                        imagePath: 'assets/images/kitab.webp',
                        label: 'Pelajari\nKitab',
                        color: const Color(0xFFFCC100),
                        imageAlignment: Alignment.topRight,
                        textAlign: TextAlign.left,
                        onTap: () =>
                            Navigator.pushNamed(context, '/pelajari-kitab'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 130),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Theme(
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
                          _buildNavItem(Icons.menu_book_rounded, 1),
                          _buildNavItem(Icons.person_rounded, 2),
                        ],
                      ),
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

  Widget _buildSquareCard({
    required String imagePath,
    required String label,
    required Color color,
    Alignment imageAlignment = Alignment.topLeft,
    TextAlign textAlign = TextAlign.center,
    VoidCallback? onTap,
  }) {
    final bool isRight = imageAlignment == Alignment.topRight;
    final bool isTextRight = textAlign == TextAlign.right;

    return GestureDetector(
      onTap: onTap ?? () {},
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

  Widget _buildSimpleClassmateLeaderboard() {
    if (_loadingClassmates) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FD),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF65A6F1),
            ),
          ),
        ),
      );
    }

    if (_topActiveClassmates.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FD),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE3EFFC), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Peringkat aktif di Kelas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF65A6F1),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_topActiveClassmates.length, (index) {
              final student = _topActiveClassmates[index];
              final rank = index + 1;
              final isCurrentUser = student['id'] == userId;
              final gender = student['gender'] as String;

              final Color rankColor;
              if (rank == 1) {
                rankColor = const Color(0xFFFCC100);
              } else if (rank == 2) {
                rankColor = const Color(0xFFC0C0C0);
              } else {
                rankColor = const Color(0xFFCD7F32);
              }

              // Take only the first name to keep it extremely clean
              final fullName = student['name'] as String;
              final firstName = fullName.split(' ').first;

              return Expanded(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrentUser
                                  ? const Color(0xFF65A6F1)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: AssetImage(
                                gender == 'laki-laki'
                                    ? 'assets/images/laki-laki.webp'
                                    : gender == 'perempuan'
                                    ? 'assets/images/perempuan.webp'
                                    : 'assets/images/person.webp',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Rank Badge
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: rankColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Name
                    Text(
                      isCurrentUser ? 'Kamu' : firstName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrentUser
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isCurrentUser
                            ? const Color(0xFF65A6F1)
                            : const Color(0xFF2D2D2D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Stats (Streak count & Quiz progress)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFFFA231),
                          size: 13,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${student['streak']}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFA231),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '|',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.assignment_turned_in_rounded,
                          color: Colors.grey.shade400,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${student['quiz_passed']}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          setState(() => _selectedIndex = 0);
        } else if (index == 1) {
          Navigator.pushNamed(context, '/pelajari-kitab').then((_) {
            if (mounted) setState(() => _selectedIndex = 0);
          });
        } else if (index == 2) {
          Navigator.pushNamed(context, '/profile').then((_) {
            if (mounted) setState(() => _selectedIndex = 0);
          });
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
}
