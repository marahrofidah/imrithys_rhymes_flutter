import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';
import 'quiz_session_page.dart';

class KerjakanKuisPage extends StatefulWidget {
  const KerjakanKuisPage({super.key});

  @override
  State<KerjakanKuisPage> createState() => _KerjakanKuisPageState();
}

class _KerjakanKuisPageState extends State<KerjakanKuisPage> {
  String? _studentId;

  // ── 33 Bab Imrithyi ───────────────────────────────────────
  final List<Map<String, dynamic>> _babList = [
    {'key': 'pembukaan', 'label': 'Pembukaan – المقدمة', 'number': 1},
    {'key': 'bab_kalam', 'label': 'Bab Kalam – باب الكلام', 'number': 2},
    {'key': 'bab_irob', 'label': "Bab I'rob – باب الإعراب", 'number': 3},
    {
      'key': 'bab_alamat_irob',
      'label': "Bab Alamat I'rob – باب علامات الإعراب",
      'number': 4,
    },
    {
      'key': 'bab_rofa',
      'label': 'Bab Alamat Rofa – باب علامات الرفع',
      'number': 5,
    },
    {
      'key': 'bab_nashob',
      'label': 'Bab Alamat Nashob – باب علامات النصب',
      'number': 6,
    },
    {
      'key': 'bab_jer',
      'label': 'Bab Alamat Jer – باب علامات الجر',
      'number': 7,
    },
    {
      'key': 'bab_jazam',
      'label': 'Bab Alamat Jazam – باب علامات الجزم',
      'number': 8,
    },
    {
      'key': 'fasal_murofa',
      'label': 'Fasal Marfu\'at – فصل المرفوعات',
      'number': 9,
    },
    {'key': 'bab_fail', 'label': "Bab Fa'il – باب الفاعل", 'number': 10},
    {
      'key': 'bab_naib_fail',
      'label': "Bab Naib Fa'il – باب نائب الفاعل",
      'number': 11,
    },
    {'key': 'bab_mubtada', 'label': 'Bab Mubtada – باب المبتدأ', 'number': 12},
    {'key': 'bab_khobar', 'label': 'Bab Khobar – باب الخبر', 'number': 13},
    {
      'key': 'bab_nawasikh',
      'label': 'Bab Nawasikh – باب النواسخ',
      'number': 14,
    },
    {'key': 'bab_inna', 'label': 'Bab Inna – باب إن وأخواتها', 'number': 15},
    {'key': 'bab_kaana', 'label': 'Bab Kaana – باب كان وأخواتها', 'number': 16},
    {'key': 'bab_tabi', 'label': "Bab Tabi' – باب التوابع", 'number': 17},
    {'key': 'bab_naad', 'label': 'Bab Na\'at – باب النعت', 'number': 18},
    {'key': 'bab_atof', 'label': "Bab 'Atof – باب العطف", 'number': 19},
    {'key': 'bab_taukid', 'label': 'Bab Taukid – باب التوكيد', 'number': 20},
    {'key': 'bab_badal', 'label': 'Bab Badal – باب البدل', 'number': 21},
    {
      'key': 'fasal_manshub',
      'label': 'Fasal Manshubat – فصل المنصوبات',
      'number': 22,
    },
    {
      'key': 'bab_mafulmutlaq',
      'label': 'Bab Maf\'ul Mutlaq – باب المفعول المطلق',
      'number': 23,
    },
    {
      'key': 'bab_mafulajl',
      'label': "Bab Maf'ul Lah – باب المفعول له",
      'number': 24,
    },
    {
      'key': 'bab_mafulmah',
      'label': "Bab Maf'ul Maah – باب المفعول معه",
      'number': 25,
    },
    {
      'key': 'bab_mustasna',
      'label': 'Bab Mustasna – باب الاستثناء',
      'number': 26,
    },
    {'key': 'bab_hal', 'label': 'Bab Hal – باب الحال', 'number': 27},
    {'key': 'bab_tamyiz', 'label': 'Bab Tamyiz – باب التمييز', 'number': 28},
    {'key': 'bab_munada', 'label': 'Bab Munada – باب المنادى', 'number': 29},
    {
      'key': 'fasal_majrur',
      'label': 'Fasal Majrurat – فصل المجرورات',
      'number': 30,
    },
    {'key': 'bab_idofah', 'label': 'Bab Idafah – باب الإضافة', 'number': 31},
    {
      'key': 'bab_maqsur',
      'label': 'Bab Isim Maqsur – باب الاسم المقصور',
      'number': 32,
    },
    {
      'key': 'bab_mamdud',
      'label': 'Bab Isim Mamdud – باب الاسم الممدود',
      'number': 33,
    },
  ];

  // ── State ─────────────────────────────────────────────────
  Map<String, dynamic>? _selectedBab;
  bool _dropdownOpen = false;
  bool _loadingData = true;

  int _completedBabs = 0;
  final int _totalBabs = 33;
  Set<String> _passedBabKeys = {};
  List<Map<String, dynamic>> _historyList = [];

  // Overlay dropdown
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _babContainerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _loadData() async {
    _studentId = AuthService().currentUser?.id;
    if (_studentId == null) {
      setState(() => _loadingData = false);
      return;
    }
    setState(() => _loadingData = true);
    final results = await Future.wait([
      SupabaseService().getPassedBabs(_studentId!),
      SupabaseService().getQuizHistory(_studentId!),
    ]);

    final passed = results[0] as Set<String>;
    final history = results[1] as List<Map<String, dynamic>>;

    if (mounted) {
      setState(() {
        _passedBabKeys = passed;
        _completedBabs = passed.length;
        _historyList = history;
        _loadingData = false;
        // Reset pilihan jika bab yang dipilih sudah lolos
        if (_selectedBab != null && passed.contains(_selectedBab!['key'])) {
          _selectedBab = null;
        }
      });
    }
  }

  // ── Overlay dropdown ──────────────────────────────────────
  void _showDropdown() {
    final RenderBox box =
        _babContainerKey.currentContext!.findRenderObject() as RenderBox;
    final double containerH = box.size.height;
    final double containerW = box.size.width;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, containerH + 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: containerW,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _babList.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final bab = _babList[index];
                          final isPassed = _passedBabKeys.contains(bab['key']);
                          final isSelected = _selectedBab?['key'] == bab['key'];

                          return GestureDetector(
                            onTap: isPassed
                                ? null
                                : () {
                                    setState(() => _selectedBab = bab);
                                    _hideDropdown();
                                  },
                            child: Container(
                              color: isPassed
                                  ? Colors.grey.shade50
                                  : isSelected
                                  ? const Color(
                                      0xFFFF3270,
                                    ).withValues(alpha: 0.06)
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      bab['label'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isPassed
                                            ? Colors.grey.shade400
                                            : isSelected
                                            ? const Color(0xFFFF3270)
                                            : const Color(0xFF2D2D2D),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isPassed)
                                    const Icon(
                                      Icons.lock_rounded,
                                      color: Color(0xFF4CAF50),
                                      size: 16,
                                    )
                                  else if (isSelected)
                                    const Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFFFF3270),
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _dropdownOpen = true);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _dropdownOpen = false);
  }

  void _startQuiz() {
    if (_selectedBab == null || _studentId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizSessionPage(
          studentId: _studentId!,
          babKey: _selectedBab!['key'] as String,
          babLabel: _selectedBab!['label'] as String,
          babNumber: _selectedBab!['number'] as int,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadData(); // reload setelah selesai kuis
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(bottom: false, child: SizedBox(height: 8)),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProgressCard(),
            const SizedBox(height: 20),
            _buildBabSelector(),
            const SizedBox(height: 16),
            _buildMulaiKuisButton(),
            const SizedBox(height: 24),
            _buildHistorySection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HEADER ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            Image.asset(
              'assets/images/imrithys_rhymes.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/kuis.png',
              width: 110,
              height: 110,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kuis',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pertahankan streakmu\ndengan quiz setiap hari!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF697B91),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── PROGRESS CARD ─────────────────────────────────────────
  Widget _buildProgressCard() {
    final double progressValue = _totalBabs > 0
        ? _completedBabs / _totalBabs
        : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3270),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3270).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Kuis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kerjakan kuis dan tingkatkan progressmu »',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          _loadingData
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFF5A623),
                    ),
                    minHeight: 22,
                  ),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFF5A623),
                        ),
                        minHeight: 22,
                      ),
                    ),
                    Text(
                      '$_completedBabs/$_totalBabs',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  // ── PILIH BAB ─────────────────────────────────────────────
  Widget _buildBabSelector() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _babContainerKey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3270),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3270).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Pilih Bab',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _dropdownOpen ? _hideDropdown : _showDropdown,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedBab?['label'] ?? 'Pilih bab...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _selectedBab != null
                              ? const Color(0xFFFF3270)
                              : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                    Icon(
                      _dropdownOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFFFF3270),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MULAI KUIS ────────────────────────────────────────────
  Widget _buildMulaiKuisButton() {
    final bool hasBab = _selectedBab != null;
    return GestureDetector(
      onTap: hasBab ? _startQuiz : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: hasBab ? const Color(0xFFFF3270) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(50),
          boxShadow: hasBab
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF3270).withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⏳', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              'Mulai Kuis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: hasBab ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HISTORY ───────────────────────────────────────────────
  Widget _buildHistorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'History Kuis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingData)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Color(0xFFFF3270)),
              ),
            )
          else if (_historyList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text('📝', style: TextStyle(fontSize: 36)),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada riwayat kuis',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_historyList.length, (index) {
              final item = _historyList[index];
              final score = item['score'] as int;
              final label = item['bab_label'] as String;
              final isPassed = item['is_passed'] as bool? ?? score >= 80;

              final Color scoreColor = isPassed
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF9E9E9E);

              // Format tanggal
              final raw = item['attempted_at'] as String? ?? '';
              String dateStr = '';
              if (raw.isNotEmpty) {
                try {
                  final dt = DateTime.parse(raw).toLocal();
                  const months = [
                    '',
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
                  const days = [
                    '',
                    'Senin',
                    'Selasa',
                    'Rabu',
                    'Kamis',
                    'Jumat',
                    'Sabtu',
                    'Minggu',
                  ];
                  dateStr =
                      '${days[dt.weekday]}, ${dt.day} ${months[dt.month]} ${dt.year}';
                } catch (_) {
                  dateStr = raw.substring(0, 10);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────
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
              _buildNavItem(
                Icons.home_rounded,
                0,
                onTap: () => Navigator.pop(context),
              ),
              _buildNavItem(Icons.quiz_rounded, 1, isActive: true),
              _buildNavItem(Icons.person_rounded, 2),
              _buildNavItem(Icons.logout_rounded, 3),
            ],
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
              ? const Color(0xFFFF3270).withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFFFF3270) : Colors.grey.shade400,
        ),
      ),
    );
  }
}
