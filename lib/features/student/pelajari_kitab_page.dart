import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
    {'key': '3_bab_irob', 'label': "Bab I'rob – bab الإعراب", 'number': 3},
    {
      'key': '4_bab_rofa',
      'label': 'Bab Alamat Rofa – bab علامات الرفع',
      'number': 4,
    },
    {
      'key': '5_bab_nashob',
      'label': 'Bab Alamat Nashob – bab علامات النصب',
      'number': 5,
    },
    {
      'key': '6_bab_jer',
      'label': 'Bab Alamat Jer – bab علامات الجر',
      'number': 6,
    },
    {
      'key': '7_bab_jazam',
      'label': 'Bab Alamat Jazam – bab علامات الجزم',
      'number': 7,
    },
    {'key': '8_fasal', 'label': 'Fasal (Ringkasan I\'rab) – فصل', 'number': 8},
    {
      'key': '9_bab_makrifat',
      'label': 'Bab Makrifat dan Nakirah – bab المعرفة والنّكرة',
      'number': 9,
    },
    {
      'key': '10_bab_fiil',
      'label': 'Bab Fiil-fiil – bab الأفعal',
      'number': 10,
    },
    {
      'key': '11_bab_irob_fiil',
      'label': 'Bab I\'rab Fiil – bab إعراب الأفعال',
      'number': 11,
    },
    {'key': '12_bab_fail', 'label': "Bab Fa'il – bab الفاعل", 'number': 12},
    {
      'key': '13_bab_naib_fail',
      'label': "Bab Naib Fa'il – bab نائب الفاعل",
      'number': 13,
    },
    {
      'key': '14_bab_mubtada',
      'label': 'Bab Mubtada – bab המبتدأ',
      'number': 14,
    },
    {'key': '15_bab_khobar', 'label': 'Bab Khobar – bab الخبر', 'number': 15},
    {
      'key': '16_bab_kaana',
      'label': 'Bab Kaana – bab كان وأخواتها',
      'number': 16,
    },
    {'key': '17_bab_inna', 'label': 'Bab Inna – bab إن وأخواتها', 'number': 17},
    {
      'key': '18_bab_zhanna',
      'label': 'Bab Zhanna – bab ظن وأخواتها',
      'number': 18,
    },
    {'key': '19_bab_naat', 'label': 'Bab Na\'at – bab النعت', 'number': 19},
    {'key': '20_bab_athaf', 'label': 'Bab Athaf – bab العطف', 'number': 20},
    {'key': '21_bab_taukid', 'label': 'Bab Taukid – bab التوكيد', 'number': 21},
    {'key': '22_bab_badal', 'label': 'Bab Badal – bab البدل', 'number': 22},
    {
      'key': '23_bab_maful_bih',
      'label': 'Bab Maf\'ul Bih – bab المفعول به',
      'number': 23,
    },
    {
      'key': '24_bab_maful_mutlaq',
      'label': 'Bab Maf\'ul Mutlaq – bab المفعول المطلق',
      'number': 24,
    },
    {'key': '25_bab_zharaf', 'label': 'Bab Zharaf – bab الظرف', 'number': 25},
    {'key': '26_bab_hal', 'label': 'Bab Hal – bab الحال', 'number': 26},
    {'key': '27_bab_tamyiz', 'label': 'Bab Tamyiz – bab التمييز', 'number': 27},
    {
      'key': '28_bab_istitsna',
      'label': 'Bab Istitsna – bab الاستثناء',
      'number': 28,
    },
    {
      'key': '29_bab_laa',
      'label': 'Bab Laa – bab لا النافية للجنس',
      'number': 29,
    },
    {'key': '30_bab_munada', 'label': 'Bab Munada – bab المنادى', 'number': 30},
    {
      'key': '31_bab_maful_liajlih',
      'label': 'Bab Maf\'ul Li Ajlih – bab المفعول لأجله',
      'number': 31,
    },
    {
      'key': '32_bab_maful_maah',
      'label': 'Bab Maf\'ul Ma\'ah – bab المفعول معه',
      'number': 32,
    },
    {
      'key': '33_bab_idhafah',
      'label': 'Bab Idhafah – bab الإضافة',
      'number': 33,
    },
  ];

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
            const SizedBox(height: 4),
            _buildBabList(),
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
                  color: const Color.fromARGB(255, 233, 233, 233),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color.fromARGB(255, 0, 0, 0),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/kitab.png',
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
                    color: const Color(0xFFFCC100).withValues(alpha: 0.35),
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
              _buildNavItem(Icons.menu_book_rounded, 1, isActive: true),
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
// huhu