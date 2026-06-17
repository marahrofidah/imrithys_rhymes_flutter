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

/// Daftar bab statik — audioUrl diisi setelah upload ke Supabase Storage
/// Format URL: https://[project].supabase.co/storage/v1/object/public/audio-bab/[filename].mp3
class BabList {
  static const String _bucketBase =
      'YOUR_SUPABASE_URL/storage/v1/object/public/audio-bab';

  static List<BabModel> getBabs() => [
    const BabModel(
      key: 'pembukaan',
      labelId: 'Pembukaan',
      labelAr: 'المقدمة',
      audioUrl: '$_bucketBase/pembukaan.mp3',
    ),
    const BabModel(
      key: 'bab_kalam',
      labelId: 'Bab Kalam',
      labelAr: 'باب الكلام',
      audioUrl: '$_bucketBase/bab_kalam.mp3',
    ),
    const BabModel(
      key: 'bab_irob',
      labelId: "Bab I'rob",
      labelAr: 'باب الإعراب',
      audioUrl: '$_bucketBase/bab_irob.mp3',
    ),
    const BabModel(
      key: 'bab_alamat_irob',
      labelId: "Bab Alamat I'rob",
      labelAr: 'باب علامات الإعراب',
      audioUrl: '$_bucketBase/bab_alamat_irob.mp3',
    ),
    const BabModel(
      key: 'bab_alamat_nashob',
      labelId: 'Bab Alamat Nashob',
      labelAr: "باب علامات النّصب",
      audioUrl: '$_bucketBase/bab_alamat_nashob.mp3',
    ),
    const BabModel(
      key: 'bab_alamat_jer',
      labelId: 'Bab Alamat Jer',
      labelAr: 'باب علامات الخفض',
      audioUrl: '$_bucketBase/bab_alamat_jer.mp3',
    ),
    const BabModel(
      key: 'bab_alamat_jazam',
      labelId: 'Bab Alamat Jazam',
      labelAr: 'باب علامات الجزم',
      audioUrl: '$_bucketBase/bab_alamat_jazam.mp3',
    ),
    const BabModel(
      key: 'fasal',
      labelId: 'Fasal',
      labelAr: "فضّل",
      audioUrl: '$_bucketBase/fasal.mp3',
    ),
    const BabModel(
      key: 'bab_makrifat_nakirah',
      labelId: 'Bab Makrifat dan Nakirah',
      labelAr: "باب المعرفة والنّكرة",
      audioUrl: '$_bucketBase/bab_makrifat_nakirah.mp3',
    ),
  ];
}
