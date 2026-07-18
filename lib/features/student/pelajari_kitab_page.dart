import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// ignore: unused_import
import '../../services/auth_service.dart';

class PelajariKitabPage extends StatefulWidget {
  const PelajariKitabPage({super.key});

  @override
  State<PelajariKitabPage> createState() => _PelajariKitabPageState();
}

class _PelajariKitabPageState extends State<PelajariKitabPage> {
  // ── 33 Bab Imrithyi ───────────────────────────────────────
  final List<Map<String, dynamic>> _babList = [
    {'key': '1_pembukaan', 'label': 'Pembukaan – المقدمة', 'number': 1},
    {'key': '2_bab_kalam', 'label': 'Bab Kalam – bab الكلام', 'number': 2},
    {'key': '3_bab_irab', 'label': "Bab I'rab – bab الإعراب", 'number': 3},
    {
      'key': '4_bab_alamat_irab',
      'label': 'Bab Alamat I\'rab – باب علامات الإعراب',
      'number': 4,
    },
    {
      'key': '5_bab_alamat_nashob',
      'label': 'Bab Alamat Nashob – باب علامات النّصب',
      'number': 5,
    },
    {
      'key': '6_bab_alamat_jer',
      'label': 'Bab Alamat Jer – باب علامات الخفض',
      'number': 6,
    },
    {
      'key': '7_bab_alamat_jazam',
      'label': 'Bab Alamat Jazam – باب علامات الجزم',
      'number': 7,
    },
    {'key': '8_fasal', 'label': 'Fasal (Ringkasan I\'rab) – فصل', 'number': 8},
    {
      'key': '9_bab_makrifat_nakirah',
      'label': 'Bab Makrifat dan Nakirah – باب المعرفة والنّكرة',
      'number': 9,
    },
    {
      'key': '10_bab_fiil_fiil',
      'label': 'Bab Fiil-fiil – باب الأفعال',
      'number': 10,
    },
    {
      'key': '11_bab_irab_fiil',
      'label': 'Bab I\'rab Fiil – باب الإعراب الفعل',
      'number': 11,
    },
    {
      'key': '12_bab_isim_yang_dibaca_rafa',
      'label': "Bab Isim yang dibaca Rafa – باب مرفوعات الأسماء",
      'number': 12,
    },
    {
      'key': '13_bab_naibul_fail',
      'label': 'Bab Naibul Fa\'il – باب نائب الفاعل',
      'number': 13,
    },
    {
      'key': '14_bab_mubtada_khobar',
      'label': 'Bab Mubtada Khobar – باب المبتدأ والخبار',
      'number': 14,
    },
    {
      'key': '15_bab_kanna_dan_saudaranya',
      'label': 'Bab Kanna dan Saudaranya – باب كان وأخواتها',
      'number': 15,
    },
    {
      'key': '16_bab_inna_dan_saudaranya',
      'label': 'Bab Inna dan Saudaranya – باب إن وأخواتها',
      'number': 16,
    },
    {
      'key': '17_bab_dzonna_dan_saudaranya',
      'label': 'Bab Dzonna dan Saudaranya – باب ظن وأخواتها',
      'number': 17,
    },
    {'key': '18_bab_naat', 'label': 'Bab Na\'at – باب النعت', 'number': 18},
    {'key': '19_bab_ataf', 'label': 'Bab Ataf – باب العطف', 'number': 19},
    {'key': '20_bab_taukid', 'label': 'Bab Taukid – باب التوكيد', 'number': 20},
    {'key': '21_bab_badal', 'label': 'Bab Badal – باب البدل', 'number': 21},
    {
      'key': '22_bab_isim_yang_dibaca_nashob',
      'label': 'Bab Isim yang dibaca Nashob – باب منصوبات الأسماء',
      'number': 22,
    },
    {'key': '23_bab_masdar', 'label': 'Bab Masdar – باب المصدر', 'number': 23},
    {'key': '24_bab_dhorof', 'label': 'Bab Dhorof – باب الظرف', 'number': 24},
    {'key': '25_bab_hal', 'label': 'Bab Hal – باب الحال', 'number': 25},
    {'key': '26_bab_tamyiz', 'label': 'Bab Tamyiz – باب التمييز', 'number': 26},
    {
      'key': '27_bab_istisna',
      'label': 'Bab Istisna – باب الاستثناء',
      'number': 27,
    },
    {
      'key': '28_bab_la_yang_beramal_seperti_amal_inna',
      'label': 'Bab La yang Beramal Seperti Amal Inna – باب لا العاملة عمل إن',
      'number': 28,
    },
    {'key': '29_bab_munada', 'label': 'Bab Munada – باب النداء', 'number': 29},
    {
      'key': '30_bab_maful_li_ajlih',
      'label': 'Bab Maful Li Ajlih – باب المفعول لأجله',
      'number': 30,
    },
    {
      'key': '31_bab_maful_maah',
      'label': 'Bab Maf\'ul Ma\'ah – باب المفعول معه',
      'number': 31,
    },
    {
      'key': '32_bab_isim_yang_dibaca_jer',
      'label': 'Bab Isim yang dibaca Jer – باب مخفوضات الأسماء',
      'number': 32,
    },
    {'key': '33_bab_idofah', 'label': 'Bab Idofah – باب الإضافة', 'number': 33},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(bottom: false, child: SizedBox(height: 8)),
            _buildHeader(),
            const SizedBox(height: 4),
            _buildBabList(),
            const SizedBox(height: 130),
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
                  color: const Color.fromARGB(255, 255, 255, 255),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        0,
                        0,
                        0,
                      ).withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color.fromARGB(255, 57, 143, 241),
                ),
              ),
            ),
            Image.asset(
              'assets/images/logo.webp',
              height: 40,
              fit: BoxFit.contain,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/kitab.webp',
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
                    'Pelajari Kitab',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF66362F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pilih bab yang ingin kamu pelajari!!',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF66362F),
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

  // ── BAB LIST ──────────────────────────────────────────────
  Widget _buildBabList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _babList.length,
      itemBuilder: (context, index) {
        final bab = _babList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => _openPdf(bab),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFFCC100),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      50,
                      50,
                      50,
                    ).withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                bab['label'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openPdf(Map<String, dynamic> bab) {
    // URL dasar dari Supabase Storage bucket 'pdf-bab'
    // Menggunakan key dari bab sebagai nama file .pdf
    final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
    final String pdfUrl =
        '$supabaseUrl/storage/v1/object/public/pdf-bab/${bab['key']}.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PdfViewerPage(babLabel: bab['label'] as String, pdfUrl: pdfUrl),
      ),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────
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
                        _buildNavItem(
                          Icons.home_rounded,
                          0,
                          onTap: () => Navigator.pop(context),
                        ),
                        _buildNavItem(
                          Icons.menu_book_rounded,
                          1,
                          isActive: true,
                        ),
                        _buildNavItem(
                          Icons.person_rounded,
                          2,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
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
              ? const Color(0xFFFCC100).withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFFFCC100) : Colors.grey.shade400,
        ),
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

// ── PDF VIEWER PAGE ─────────────────────────────────────────
class PdfViewerPage extends StatelessWidget {
  final String babLabel;
  final String pdfUrl;

  const PdfViewerPage({
    super.key,
    required this.babLabel,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2D2D2D),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          babLabel,
          style: const TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat PDF: ${details.description}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
