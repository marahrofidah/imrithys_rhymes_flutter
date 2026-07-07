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
    final String supabaseUrl =
        dotenv.env['SUPABASE_URL'] ?? 'https://YOUR_SUPABASE_URL.supabase.co';
    // Menyesuaikan nama bucket berdasarkan screenshot user: imrithys-rhymes-audio
    final String bucketBase =
        '$supabaseUrl/storage/v1/object/public/imrithys-rhymes-audio';

    return [
      BabModel(
        key: '1_pembukaan',
        labelId: 'Pembukaan',
        labelAr: 'المقدمة',
        // Menggunakan ekstensi .mp3 sesuai saran ke user
        audioUrl: '$bucketBase/1_pembukaan.mp3',
      ),
      BabModel(
        key: '2_bab_kalam',
        labelId: 'Bab Kalam',
        labelAr: 'باب الكلام',
        audioUrl: '$bucketBase/2_bab_kalam.mp3',
      ),
      BabModel(
        key: '3_bab_irab',
        labelId: "Bab I'rab",
        labelAr: 'باب الإعراب',
        audioUrl: '$bucketBase/3_bab_irab.mp3',
      ),
      BabModel(
        key: '4_bab_alamat_irab',
        labelId: "Bab Alamat I'rab",
        labelAr: 'باب علامات الإعراب',
        audioUrl: '$bucketBase/4_bab_alamat_irab.mp3',
      ),
      BabModel(
        key: '5_bab_alamat_nashob',
        labelId: 'Bab Alamat Nashob',
        labelAr: "باب علامات النّصب",
        audioUrl: '$bucketBase/5_bab_alamat_nashob.mp3',
      ),
      BabModel(
        key: '6_bab_alamat_jer',
        labelId: 'Bab Alamat Jer',
        labelAr: 'باب علامات الخفض',
        audioUrl: '$bucketBase/6_bab_alamat_jer.mp3',
      ),
      BabModel(
        key: '7_bab_alamat_jazam',
        labelId: 'Bab Alamat Jazam',
        labelAr: 'باب علامات الجزم',
        audioUrl: '$bucketBase/7_bab_alamat_jazam.mp3',
      ),
      BabModel(
        key: '8_fasal',
        labelId: 'Fasal',
        labelAr: "فضّل",
        audioUrl: '$bucketBase/8_fasal.mp3',
      ),
      BabModel(
        key: '9_bab_makrifat_nakirah',
        labelId: 'Bab Makrifat dan Nakirah',
        labelAr: "باب المعرفة والنّكرة",
        audioUrl: '$bucketBase/9_bab_makrifat_nakirah.mp3',
      ),
      BabModel(
        key: '10_bab_fiil_fiil',
        labelId: 'Bab Fiil Fiil',
        labelAr: "باب الفعل الفعل",
        audioUrl: '$bucketBase/10_bab_fiil_fiil.mp3',
      ),
      BabModel(
        key: '11_bab_irab_fiil',
        labelId: 'Bab Irab Fiil',
        labelAr: "باب الإعراب الفعل",
        audioUrl: '$bucketBase/11_bab_irab_fiil.mp3',
      ),
      BabModel(
        key: '12_bab_isim_yang_dibaca_rafa',
        labelId: 'Bab Isim yang dibaca Rafa',
        labelAr: "باب مرفوعات الأسماء",
        audioUrl: '$bucketBase/12_bab_isim_yang_dibaca_rafa.mp3',
      ),
      BabModel(
        key: '13_bab_naibul_fail',
        labelId: 'Bab Naibul Fail',
        labelAr: "باب نائب الفاعل",
        audioUrl: '$bucketBase/13_bab_naibul_fail.mp3',
      ),
      BabModel(
        key: '14_bab_mubtada_khobar',
        labelId: 'Bab Mubtada Khobar',
        labelAr: "باب المبتدأ والخبار",
        audioUrl: '$bucketBase/14_bab_mubtada_khobar.mp3',
      ),
      BabModel(
        key: '15_bab_kanna_dan_saudaranya',
        labelId: 'Bab Kanna dan Saudaranya',
        labelAr: "باب كان وأخواتها",
        audioUrl: '$bucketBase/15_bab_kanna_dan_saudaranya.mp3',
      ),
      BabModel(
        key: '16_bab_inna_dan_saudaranya',
        labelId: 'Bab Inna dan Saudaranya',
        labelAr: "باب إن وأخواتها",
        audioUrl: '$bucketBase/16_bab_inna_dan_saudaranya.mp3',
      ),
      BabModel(
        key: '17_bab_dzanna_dan_saudaranya',
        labelId: 'Bab Dzanna dan Saudaranya',
        labelAr: "باب ظن وأخواتها",
        audioUrl: '$bucketBase/17_bab_dzanna_dan_saudaranya.mp3',
      ),
      BabModel(
        key: '18_bab_naat',
        labelId: 'Bab Na\'at',
        labelAr: "باب النعت",
        audioUrl: '$bucketBase/18_bab_naat.mp3',
      ),
      BabModel(
        key: '19_bab_ataf',
        labelId: 'Bab Ataf',
        labelAr: "باب العطف",
        audioUrl: '$bucketBase/19_bab_ataf.mp3',
      ),
      BabModel(
        key: '20_bab_taukid',
        labelId: 'Bab Taukid',
        labelAr: "باب التوكيد",
        audioUrl: '$bucketBase/20_bab_taukid.mp3',
      ),
      BabModel(
        key: '21_bab_badal',
        labelId: 'Bab Badal',
        labelAr: "باب البدل",
        audioUrl: '$bucketBase/21_bab_badal.mp3',
      ),
      BabModel(
        key: '22_bab_isim_yang_dibaca_nashob',
        labelId: 'Bab Isim yang dibaca Nashob',
        labelAr: "باب منصوبات الأسماء",
        audioUrl: '$bucketBase/22_bab_isim_yang_dibaca_nashob.mp3',
      ),
      BabModel(
        key: '23_bab_masdar',
        labelId: 'Bab Masdar',
        labelAr: "باب المصدر",
        audioUrl: '$bucketBase/23_bab_masdar.mp3',
      ),
      BabModel(
        key: '24_bab_dhorof',
        labelId: 'Bab Dhorof',
        labelAr: "باب الظرف",
        audioUrl: '$bucketBase/24_bab_dhorof.mp3',
      ),
      BabModel(
        key: '25_bab_hal',
        labelId: 'Bab Hal',
        labelAr: "باب الحال",
        audioUrl: '$bucketBase/25_bab_hal.mp3',
      ),
      BabModel(
        key: '26_bab_tamyiz',
        labelId: 'Bab Tamyiz',
        labelAr: "باب التمييز",
        audioUrl: '$bucketBase/26_bab_tamyiz.mp3',
      ),
      BabModel(
        key: '27_bab_istisna',
        labelId: 'Bab Istisna',
        labelAr: "باب الاستثناء",
        audioUrl: '$bucketBase/27_bab_istisna.mp3',
      ),
      BabModel(
        key: '28_bab_la_yang_beramal_seperti_amal_inna',
        labelId: 'Bab La yang Beramal Seperti Amal Inna',
        labelAr: "باب لا العاملة عمل إن",
        audioUrl: '$bucketBase/28_bab_la_yang_beramal_seperti_amal_inna.mp3',
      ),
      BabModel(
        key: '29_bab_munada',
        labelId: 'Bab Munada',
        labelAr: "باب النداء",
        audioUrl: '$bucketBase/29_bab_munada.mp3',
      ),
      BabModel(
        key: '30_bab_maful_li_ajlih',
        labelId: 'Bab Maful li Ajlih',
        labelAr: "باب المفعول لأجله",
        audioUrl: '$bucketBase/30_bab_maful_li_ajlih.mp3',
      ),
      BabModel(
        key: '31_bab_maful_maah',
        labelId: 'Bab Maful Ma\'ah',
        labelAr: "باب المفعول معه",
        audioUrl: '$bucketBase/31_bab_maful_maah.mp3',
      ),
      BabModel(
        key: '32_bab_isim_yang_dibaca_jer',
        labelId: 'Bab Isim yang dibaca Jer',
        labelAr: "باب مخفوضات الأسماء",
        audioUrl: '$bucketBase/32_bab_isim_yang_dibaca_jer.mp3',
      ),
      BabModel(
        key: '33_bab_idofah',
        labelId: 'Bab Idofah',
        labelAr: "باب الإضافة",
        audioUrl: '$bucketBase/33_bab_idofah.mp3',
      ),
    ];
  }
}
