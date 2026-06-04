// workout_calculator.dart
class WorkoutCalculator {
  /// Her hareketin biyomekanik katsayısına göre kalori ve süre hesaplar
  static Map<String, double> hesaplaKaloriVeSure(String egzersiz, int tekrar) {
    double kalori = 0.0;
    int sureSaniye = 0;

    if (egzersiz == "Plank") {
      // İzometrik Core
      kalori = tekrar * 0.1; // Plank için tekrar aslında saniyedir
      sureSaniye = tekrar;
    } else if (egzersiz == "Squat" || egzersiz == "Lunge") {
      // Büyük Kas Grupları (Alt Vücut)
      kalori = tekrar * 0.45;
      sureSaniye = tekrar * 3;
    } else if (egzersiz == "Şınav") {
      // Büyük Kas Grupları (Üst Vücut)
      kalori = tekrar * 0.5;
      sureSaniye = tekrar * 3;
    } else if (egzersiz == "Jumping Jack" || egzersiz == "High Knees") {
      // YENİ: Kardiyo / HIIT (Hızlı ve Yüksek Kalorili)
      kalori = tekrar * 0.65;
      sureSaniye = (tekrar * 1.2).toInt(); // Hızlı yapıldığı için saniye düşük
    } else if (egzersiz == "Mekik" ||
        egzersiz == "Köprü" ||
        egzersiz == "Düz Bacak Kaldırma") {
      // YENİ: Core ve Yerde Yapılan Hareketler
      kalori = tekrar * 0.25;
      sureSaniye = (tekrar * 2.5).toInt();
    } else if (egzersiz == "Bicep Curl" ||
        egzersiz == "Front Raise" ||
        egzersiz == "Omuz Yana Açış") {
      // YENİ: İzole Üst Vücut Hareketleri
      kalori = tekrar * 0.20;
      sureSaniye = (tekrar * 2.5).toInt();
    } else {
      // Varsayılan Ortalama Hareket
      kalori = tekrar * 0.3;
      sureSaniye = tekrar * 2;
    }

    return {"kalori": kalori, "sure": sureSaniye.toDouble()};
  }

  /// Kullanıcının başarı oranına göre kişiselleştirilmiş AI tavsiyesi üretir
  static String aiSetTavsiyesiVer(
    double basariOrani,
    int toplamTekrar,
    String seviye,
  ) {
    if (toplamTekrar == 0) return "";

    if (basariOrani >= 90 && toplamTekrar > 50) {
      if (seviye == 'İleri Düzey') {
        return "\n\n🚀 ELİT ANALİZ: Formun kusursuz! Yapay zeka bir sonraki antrenmanında set hedeflerini %30 artırmanı ve dinlenme sürelerini 10 saniye azaltmanı zorunlu kılıyor.";
      }
      return "\n\n🚀 İLERİ SEVİYE ANALİZİ: Formun kusursuz. Yapay zeka bir sonraki antrenmanında setlerini %20 artırmanı öneriyor.";
    } else if (basariOrani < 60 && toplamTekrar > 0) {
      return "\n\n⚠️ FORM DÜZELTME ANALİZİ: Çok fazla hata yapıyorsun. Yapay zeka eklemlerini korumak için setlerini yarıya indirdi ve hareket hızını yavaşlatmanı istiyor.";
    }

    return "\n\n✅ STABİL DURUM: Formun gayet iyi. Yapay zeka bu istikrarı koruman için mevcut set düzenine devam etmeni onaylıyor.";
  }
}
