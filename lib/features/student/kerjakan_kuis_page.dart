import 'package:flutter/material.dart';

class KerjakanKuisPage extends StatefulWidget {
  const KerjakanKuisPage({super.key});

  @override
  State<KerjakanKuisPage> createState() => _KerjakanKuisPageState();
}

class _KerjakanKuisPageState extends State<KerjakanKuisPage> {
  // Dummy data bab (nanti diganti dari Supabase)
  final List<Map<String, String>> _babList = [
    {'key': 'pembukaan', 'label': 'Pembukaan – المقدمة'},
    {'key': 'bab_kalam', 'label': 'Bab Kalam – باب الكلام'},
    {'key': 'bab_irob', 'label': "Bab I'rob – باب الإعراب"},
    {'key': 'bab_alamat_irob', 'label': "Bab Alamat I'rob – باب علامات الإعراب"},
    {'key': 'bab_alamat_nashob', 'label': "Bab Alamat Nashob – باب علامات النّصب"},
    {'key': 'bab_alamat_jer', 'label': 'Bab Alamat Jer – باب علامات الخفض'},
    {'key': 'bab_alamat_jazam', 'label': 'Bab Alamat Jazam – باب علامات الجزم'},
    {'key': 'fasal', 'label': "Fasal – فضّل"},
    {'key': 'bab_makrifat', 'label': "Bab Makrifat dan Nakirah – باب المعرفة والنّكرة"},
  ];

  // Dummy history
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

  // Dummy progress
  final int _completedBabs = 5;
  final int _totalBabs = 33;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Text(
          'Quiz Harian',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Header ──────────────────────────────────────
            _buildHeader(),
            const SizedBox(height: 20),

            // ── Progress Kuis ────────────────────────────────
            _buildProgressCard(),
            const SizedBox(height: 20),

            // ── Pilih Bab ────────────────────────────────────
            _buildBabSelector(),
            const SizedBox(height: 16),

            // ── Tombol Mulai Kuis ────────────────────────────
            _buildMulaiKuisButton(),
            const SizedBox(height: 28),

            // ── History Kuis ─────────────────────────────────
            _buildHistorySection(),
            const SizedBox(height: 24),
          ],
        ),
      ),

      // ── Bottom Nav ───────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ──────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clock icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.timer_rounded,
                size: 50,
                color: Color(0xFFF59E0B),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Teks kuis
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kuis',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
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

        // Logo
        Image.asset(
          'assets/images/imrithys_rhymes.png',
          height: 36,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // PROGRESS CARD
  // ──────────────────────────────────────────────────────────
  Widget _buildProgressCard() {
    final double progressValue = _completedBabs / _totalBabs;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E8C), Color(0xFFFF6B9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E8C).withValues(alpha: 0.35),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Kerjakan kuis dan tingkatkan progressmu »',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // PILIH BAB
  // ──────────────────────────────────────────────────────────
  Widget _buildBabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header "Pilih Bab"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE91E8C), Color(0xFFFF6B9D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Text(
              'Pilih Bab',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Dropdown trigger
          GestureDetector(
            onTap: () => setState(() => _dropdownOpen = !_dropdownOpen),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _dropdownOpen
                    ? BorderRadius.zero
                    : const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                border: Border.all(
                  color: Colors.grey.shade100,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedBab?['label'] ?? 'Pilih bab...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedBab != null
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                  Icon(
                    _dropdownOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFE91E8C),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Dropdown list
          if (_dropdownOpen)
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _babList.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade100,
                ),
                itemBuilder: (context, index) {
                  final bab = _babList[index];
                  final isSelected =
                      _selectedBab?['key'] == bab['key'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBab = bab;
                        _dropdownOpen = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      color: isSelected
                          ? const Color(0xFFE91E8C).withValues(alpha: 0.06)
                          : Colors.transparent,
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
                                    ? const Color(0xFFE91E8C)
                                    : const Color(0xFF2D2D2D),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_rounded,
                                color: Color(0xFFE91E8C), size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // TOMBOL MULAI KUIS
  // ──────────────────────────────────────────────────────────
  Widget _buildMulaiKuisButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _selectedBab == null
            ? null
            : () {
                // Nanti navigate ke quiz session
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Memulai kuis: ${_selectedBab!['label']}'),
                    backgroundColor: const Color(0xFFE91E8C),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
        icon: const Text('⏳', style: TextStyle(fontSize: 20)),
        label: const Text(
          'Mulai Kuis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedBab == null
              ? Colors.grey.shade300
              : const Color(0xFFE91E8C),
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: _selectedBab == null ? 0 : 4,
          shadowColor:
              const Color(0xFFE91E8C).withValues(alpha: 0.4),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // HISTORY KUIS
  // ──────────────────────────────────────────────────────────
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
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
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
                    horizontal: 18, vertical: 14),
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
                    // Info bab
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

                    // Score badge
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

  // ──────────────────────────────────────────────────────────
  // BOTTOM NAV (sama seperti dashboard)
  // ──────────────────────────────────────────────────────────
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
              _buildNavItem(Icons.home_rounded, 0, onTap: () {
                Navigator.pop(context);
              }),
              _buildNavItem(Icons.quiz_rounded, 1, isActive: true),
              _buildNavItem(Icons.person_rounded, 2),
              _buildNavItem(Icons.logout_rounded, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index,
      {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFE91E8C).withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive
              ? const Color(0xFFE91E8C)
              : Colors.grey.shade400,
        ),
      ),
    );
  }
}
