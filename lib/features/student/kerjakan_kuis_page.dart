import 'package:flutter/material.dart';

class KerjakanKuisPage extends StatefulWidget {
  const KerjakanKuisPage({super.key});

  @override
  State<KerjakanKuisPage> createState() => _KerjakanKuisPageState();
}

class _KerjakanKuisPageState extends State<KerjakanKuisPage> {
  final List<Map<String, String>> _babList = [
    {'key': 'pembukaan', 'label': 'Pembukaan – المقدمة'},
    {'key': 'bab_kalam', 'label': 'Bab Kalam – باب الكلام'},
    {'key': 'bab_irob', 'label': "Bab I'rob – باب الإعراب"},
    {
      'key': 'bab_alamat_irob',
      'label': "Bab Alamat I'rob – باب علامات الإعراب",
    },
    {
      'key': 'bab_alamat_nashob',
      'label': "Bab Alamat Nashob – باب علامات النّصب",
    },
    {'key': 'bab_alamat_jer', 'label': 'Bab Alamat Jer – باب علامات الخفض'},
    {'key': 'bab_alamat_jazam', 'label': 'Bab Alamat Jazam – باب علامات الجزم'},
    {'key': 'fasal', 'label': "Fasal – فضّل"},
    {
      'key': 'bab_makrifat',
      'label': "Bab Makrifat dan Nakirah – باب المعرفة والنّكرة",
    },
  ];

  final List<Map<String, dynamic>> _historyList = [
    {
      'babLabel': "Bab I'rob – باب الإعراب",
      'date': 'Senin, 20 April 2026',
      'score': 80,
    },
    {
      'babLabel': 'Pembukaan – المقدمة',
      'date': 'Senin, 20 April 2026',
      'score': 90,
    },
    {
      'babLabel': 'Bab Kalam – باب الكلام',
      'date': 'Minggu, 19 April 2026',
      'score': 70,
    },
  ];

  Map<String, String>? _selectedBab;
  bool _dropdownOpen = false;
  final int _completedBabs = 5;
  final int _totalBabs = 33;

  // Overlay dropdown – pakai GlobalKey untuk ukur tinggi container
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _babContainerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showDropdown() {
    final RenderBox box =
        _babContainerKey.currentContext!.findRenderObject() as RenderBox;
    final double containerH = box.size.height;
    final double containerW = box.size.width;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Tap di luar → tutup
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
            ),
          ),
          // List dropdown — muncul tepat di bawah container
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
                    constraints: const BoxConstraints(maxHeight: 240),
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
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final bab = _babList[index];
                          final isSelected = _selectedBab?['key'] == bab['key'];
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedBab = bab);
                              _hideDropdown();
                            },
                            child: Container(
                              color: isSelected
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
                                      bab['label']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFFFF3270)
                                            : const Color(0xFF2D2D2D),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
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
              'assets/images/logo.png',
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
              width: 140,
              height: 140,
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
                    'Pertahankan streakmu dengan quiz setiap hari!',
                    style: TextStyle(
                      fontSize: 15,
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
    final double progressValue = _completedBabs / _totalBabs;
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
          Stack(
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
    // CompositedTransformTarget membungkus SELURUH container pink
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
            // White pill trigger
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
    final bool enabled = _selectedBab != null;
    return GestureDetector(
      onTap: enabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Memulai kuis: ${_selectedBab!['label']}'),
                  backgroundColor: const Color(0xFFFF3270),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFFF3270) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(50),
          boxShadow: enabled
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
                color: enabled ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HISTORY ───────────────────────────────────────────────
  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'History Kuis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_historyList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
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
            final label = item['babLabel'] as String;
            final parts = label.split(' – ');
            final nameId = parts[0];
            final nameAr = parts.length > 1 ? parts[1] : '';
            Color scoreColor;
            if (score >= 90) {
              scoreColor = const Color(0xFF4CAF50);
            } else if (score >= 70) {
              scoreColor = const Color(0xFF9E9E9E);
            } else {
              scoreColor = const Color(0xFFEF4444);
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          if (nameAr.isNotEmpty)
                            Text(
                              nameAr,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF697B91),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            item['date'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scoreColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
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
