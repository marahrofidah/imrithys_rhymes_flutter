import 'package:flutter_dotenv/flutter_dotenv.dart';

class BabModel {
  final String key;
  final String labelId; // bahasa Indonesia
  final String labelAr; // bahasa Arab
  final String audioUrl; // URL dari Supabase Storage

  const BabModel({
    required this.key,
    required this.labelId,
    required this.labelAr,
    required this.audioUrl,
  });

  String get fullLabel => '$labelId – $labelAr';
}

/// Daftar bab statik — audioUrl diisi secara dinamis menggunakan url Supabase dari .env
class BabList {
  static List<BabModel> getBabs() {
    final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://YOUR_SUPABASE_URL.supabase.co';
    // Menyesuaikan nama bucket berdasarkan screenshot user: imrithys-rhymes-audio
    final String bucketBase = '$supabaseUrl/storage/v1/object/public/imrithys-rhymes-audio';

    return [
      BabModel(
        key: 'pembukaan',
        labelId: 'Pembukaan',
        labelAr: 'المقدمة',
        // Menggunakan ekstensi .mp3 sesuai saran ke user
        audioUrl: '$bucketBase/pembukaan.mp3',
      ),
      BabModel(
        key: 'bab_kalam',
        labelId: 'Bab Kalam',
        labelAr: 'باب الكلام',
        audioUrl: '$bucketBase/bab_kalam.mp3',
      ),
      BabModel(
        key: 'bab_irob',
        labelId: "Bab I'rob",
        labelAr: 'باب الإعراب',
        audioUrl: '$bucketBase/bab_irob.mp3',
      ),
      BabModel(
        key: 'bab_alamat_irob',
        labelId: "Bab Alamat I'rob",
        labelAr: 'باب علامات الإعراب',
        audioUrl: '$bucketBase/bab_alamat_irob.mp3',
      ),
      BabModel(
        key: 'bab_alamat_nashob',
        labelId: 'Bab Alamat Nashob',
        labelAr: "باب علامات النّصب",
        audioUrl: '$bucketBase/bab_alamat_nashob.mp3',
      ),
      BabModel(
        key: 'bab_alamat_jer',
        labelId: 'Bab Alamat Jer',
        labelAr: 'باب علامات الخفض',
        audioUrl: '$bucketBase/bab_alamat_jer.mp3',
      ),
      BabModel(
        key: 'bab_alamat_jazam',
        labelId: 'Bab Alamat Jazam',
        labelAr: 'باب علامات الجزم',
        audioUrl: '$bucketBase/bab_alamat_jazam.mp3',
      ),
      BabModel(
        key: 'fasal',
        labelId: 'Fasal',
        labelAr: "فضّل",
        audioUrl: '$bucketBase/fasal.mp3',
      ),
      BabModel(
        key: 'bab_makrifat_nakirah',
        labelId: 'Bab Makrifat dan Nakirah',
        labelAr: "باب المعرفة والنّكرة",
        audioUrl: '$bucketBase/bab_makrifat_nakirah.mp3',
      ),
    ];
  }
}
