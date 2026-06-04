class AntrenmanKaydi {
  final String id;
  final String egzersizAdi;
  final DateTime tarih;
  final List<SetDetayi> setler;
  final double genelBasariOrani;

  // --- YAPAY ZEKA HAFIZA VERİLERİ (AI MEMORY) ---
  final String
  secilenHedefModu; // Örn: "AI Optimum Gelişim" veya "Sınırları Zorla"
  final String aiEtiketi; // Örn: "Maksimum Verim 🔥"
  final String
  aiOneriMesaji; // Örn: "Harika form! Alt vücut kasların ateşlenmiş..."

  AntrenmanKaydi({
    required this.id,
    required this.egzersizAdi,
    required this.tarih,
    required this.setler,
    required this.genelBasariOrani,
    this.secilenHedefModu = "Standart",
    this.aiEtiketi = "Analiz Edilmedi",
    this.aiOneriMesaji = "",
  });

  // 1. Veritabanına Yazmak İçin (Serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'egzersizAdi': egzersizAdi,
      'tarih': tarih.toIso8601String(),
      'setler': setler.map((x) => x.toMap()).toList(),
      'genelBasariOrani': genelBasariOrani,
      'secilenHedefModu': secilenHedefModu,
      'aiEtiketi': aiEtiketi,
      'aiOneriMesaji': aiOneriMesaji,
    };
  }

  // 2. Veritabanından Okumak İçin (Deserialization - YENİ EKLENDİ)
  factory AntrenmanKaydi.fromMap(Map<dynamic, dynamic> map) {
    return AntrenmanKaydi(
      id: map['id'] ?? '',
      egzersizAdi: map['egzersizAdi'] ?? '',
      tarih: DateTime.parse(map['tarih']),
      setler: List<SetDetayi>.from(
        (map['setler'] ?? []).map((x) => SetDetayi.fromMap(x)),
      ),
      genelBasariOrani: (map['genelBasariOrani'] ?? 0.0).toDouble(),
      secilenHedefModu: map['secilenHedefModu'] ?? "Standart",
      aiEtiketi: map['aiEtiketi'] ?? "Analiz Edilmedi",
      aiOneriMesaji: map['aiOneriMesaji'] ?? "",
    );
  }
}

class SetDetayi {
  final int setNo;
  final int tamamlananTekrar;
  final int hataSayisi;
  final int dinlenmeSuresiSaniye;

  // --- YAPAY ZEKA SET ANALİZİ ---
  final double
  setBasariOrani; // Sadece bu setin 100 üzerinden biyomekanik skoru
  final List<String> yapilanHatalar; // Kameranın yakaladığı spesifik hatalar

  SetDetayi({
    required this.setNo,
    required this.tamamlananTekrar,
    required this.hataSayisi,
    required this.dinlenmeSuresiSaniye,
    this.setBasariOrani = 0.0,
    this.yapilanHatalar = const [],
  });

  // 1. Veritabanına Yazmak İçin
  Map<String, dynamic> toMap() {
    return {
      'setNo': setNo,
      'tamamlananTekrar': tamamlananTekrar,
      'hataSayisi': hataSayisi,
      'dinlenmeSuresiSaniye': dinlenmeSuresiSaniye,
      'setBasariOrani': setBasariOrani,
      'yapilanHatalar': yapilanHatalar,
    };
  }

  // 2. Veritabanından Okumak İçin (Deserialization - YENİ EKLENDİ)
  factory SetDetayi.fromMap(Map<dynamic, dynamic> map) {
    return SetDetayi(
      setNo: map['setNo']?.toInt() ?? 1,
      tamamlananTekrar: map['tamamlananTekrar']?.toInt() ?? 0,
      hataSayisi: map['hataSayisi']?.toInt() ?? 0,
      dinlenmeSuresiSaniye: map['dinlenmeSuresiSaniye']?.toInt() ?? 0,
      setBasariOrani: (map['setBasariOrani'] ?? 0.0).toDouble(),
      yapilanHatalar: List<String>.from(map['yapilanHatalar'] ?? []),
    );
  }
}
