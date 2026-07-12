import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
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
                size: 16,
                color: Color.fromARGB(255, 57, 143, 241),
              ),
            ),
          ),
        ),
        title: const Text(
          'Informasi Aplikasi',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Logo & Deskripsi Singkat
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF65A6F1).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 40,
                          color: Color(0xFF65A6F1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Imrithy's Rhymes",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF65A6F1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versi 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Deskripsi Aplikasi
            const Text(
              'Tentang Aplikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Imrithy's Rhymes adalah aplikasi pembelajaran interaktif untuk membantu kamu menghafal dan memahami bait-bait Nazham Al-Imrithi (kitab Nahwu) dengan metode Tikror (pengulangan mendengar) serta evaluasi kuis.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // Panduan Fitur
            const Text(
              'Panduan Fitur Utama',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),

            // 1. Focus Track (Streak)
            _buildFeatureCard(
              iconEmoji: '🔥',
              title: 'Focus Track (Streak)',
              description:
                  'Jaga konsistensi belajarmu! Dengarkan minimal salah satu bab syair sebanyak 5x sehari untuk mempertahankan dan menambah streak. Jika terlewat 1 hari saja, streak kamu akan padam kembali ke 0.',
              color: const Color(0xFFFFA231),
            ),
            const SizedBox(height: 12),

            // 2. Dengarkan Syair
            _buildFeatureCard(
              iconEmoji: '🎧',
              title: 'Dengarkan Syair',
              description:
                  'Putar audio rekaman bait syair Al-Imrithi secara berulang. Putaran audio yang didengar hingga 95% dari durasi akan otomatis tercatat sebagai 1 kali putaran progress harian.',
              color: const Color(0xFF6E6EB0),
            ),
            const SizedBox(height: 12),

            // 3. Kerjakan Kuis
            _buildFeatureCard(
              iconEmoji: '📝',
              title: 'Kerjakan Kuis',
              description:
                  'Uji pemahaman Nahwu kamu melalui kuis pilihan ganda berisi 10 soal di tiap bab. Kamu dinyatakan Lulus jika berhasil meraih nilai minimal 80 (menjawab 8 soal benar).',
              color: const Color(0xFFFF3270),
            ),
            const SizedBox(height: 12),

            // 4. Pelajari Kitab
            _buildFeatureCard(
              iconEmoji: '📖',
              title: 'Pelajari Kitab',
              description:
                  'Baca teks bait dan penjelasan materi kitab Al-Imrithi secara mandiri kapan saja untuk memperkuat pemahaman sebelum mengerjakan kuis.',
              color: const Color(0xFFFCC100),
            ),
            const SizedBox(height: 28),

            // Tips Sukses
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF65A6F1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF65A6F1).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tips Belajar Efektif',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Dengarkan syair minimal 5 kali di pagi atau sore hari saat santai, kemudian coba kerjakan kuisnya untuk mengevaluasi ingatanmu!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String iconEmoji,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bundaran Icon Emoji
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(iconEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
