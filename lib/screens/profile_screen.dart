import 'package:fizik_tedavi_asistani/utils/workout_calculator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _adController = TextEditingController();
  final TextEditingController _yasController = TextEditingController();
  final TextEditingController _boyController = TextEditingController();
  final TextEditingController _kiloController = TextEditingController();

  String _seciliSakatlik = 'Genel Fitness';
  final List<String> _sakatlikBolgeleri = [
    'Diz',
    'Omuz',
    'Bel',
    'Ayak Bileği',
    'Genel Fitness',
  ];

  late Box _profilKutusu;
  double _vki = 0.0;
  String _vkiDurum = "";

  // Bu değişkenler artık Builder içinde anlık olarak beslenecek
  int _toplamTekrar = 0;
  int _toplamHata = 0;
  double _genelBasari = 0.0;
  String _aiAnalizMesaji =
      "Yapay zekanın seni analiz edebilmesi için veriler yükleniyor...";
  Map<String, int> _kisiselRekorlar = {};
  Map<String, double> _kasGelisimi = {
    "Bacak": 0,
    "Kol/Omuz": 0,
    "Karın": 0,
    "Sırt/Kalça": 0,
  };

  @override
  void initState() {
    super.initState();
    _profilKutusu = Hive.box('userProfile');
    _verileriYukle();
  }

  void _verileriYukle() {
    _adController.text = _profilKutusu.get('ad', defaultValue: 'Şampiyon');
    _yasController.text =
        _profilKutusu.get('yas', defaultValue: '')?.toString() ?? '';
    _boyController.text =
        _profilKutusu.get('boy', defaultValue: '')?.toString() ?? '';
    _kiloController.text =
        _profilKutusu.get('kilo', defaultValue: '')?.toString() ?? '';
    _seciliSakatlik = _profilKutusu.get(
      'sakatlik',
      defaultValue: 'Genel Fitness',
    );
    _vkiHesapla();
  }

  // YENİ: setState içermeyen, Builder içinde anlık çalışan süper hızlı hesaplama motoru!
  void _istatistikleriAnlikGuncelle(Box egzersizKutusu, Box profilKutu) {
    int tTekrar = 0;
    int tHata = 0;
    Map<String, int> rekorlar = {};
    Map<String, double> kasGruplari = {
      "Bacak": 0,
      "Kol/Omuz": 0,
      "Karın": 0,
      "Sırt/Kalça": 0,
    };

    for (var key in egzersizKutusu.keys) {
      var veri = egzersizKutusu.get(key);
      if (veri is Map) {
        int tekrar = veri['tekrar'] as int? ?? 0;
        int hata = veri['hata'] as int? ?? 0;
        tTekrar += tekrar;
        tHata += hata;

        List<String> parcalar = key.toString().split('-');
        if (parcalar.length >= 4) {
          String egzersiz = parcalar.sublist(3).join('-');

          if ((rekorlar[egzersiz] ?? 0) < tekrar) {
            rekorlar[egzersiz] = tekrar;
          }

          // YENİ: Tüm hareketler kas haritasına eksiksiz eklendi!
          if (egzersiz == "Squat" ||
              egzersiz == "Lunge" ||
              egzersiz == "High Knees" ||
              egzersiz == "Düz Bacak Kaldırma") {
            kasGruplari["Bacak"] = (kasGruplari["Bacak"] ?? 0) + tekrar;
          } else if (egzersiz == "Şınav" ||
              egzersiz == "Bicep Curl" ||
              egzersiz == "Front Raise" ||
              egzersiz == "Jumping Jack" ||
              egzersiz == "Omuz Yana Açış") {
            kasGruplari["Kol/Omuz"] = (kasGruplari["Kol/Omuz"] ?? 0) + tekrar;
          } else if (egzersiz == "Plank" || egzersiz == "Mekik") {
            kasGruplari["Karın"] = (kasGruplari["Karın"] ?? 0) + tekrar;
          } else if (egzersiz == "Köprü") {
            kasGruplari["Sırt/Kalça"] =
                (kasGruplari["Sırt/Kalça"] ?? 0) + tekrar;
          }
        }
      }
    }

    double maxDeger = 1.0;
    kasGruplari.forEach((key, value) {
      if (value > maxDeger) maxDeger = value;
    });

    String seviye = profilKutu.get('seviye', defaultValue: 'Yeni Başlayan');
    String aiMesaj = "";
    double basari = tTekrar == 0 ? 0 : (tTekrar / (tTekrar + tHata)) * 100;

    if (tTekrar == 0) {
      aiMesaj =
          "Seni tanımam ve analiz edebilmem için ilk antrenmanını tamamlamalısın.";
    } else {
      String enGucluBolge = kasGruplari.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      String enZayifBolge = kasGruplari.entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;

      if (basari < 60) {
        aiMesaj =
            "Son antrenmanlarında formunda belirgin bozulmalar var. Vücudunu dinlendirmeli ve esneme hareketlerine ağırlık vermelisin.";
      } else if (kasGruplari[enGucluBolge] == 0) {
        aiMesaj =
            "Harika bir başlangıç! Vücudunu dengeli geliştirmek için AI önerilerine uymaya devam et.";
      } else if (kasGruplari[enGucluBolge]! >
          (kasGruplari[enZayifBolge]! * 3)) {
        aiMesaj =
            "Radar verilerime göre $enGucluBolge kasların çok iyi gelişmiş, ancak $enZayifBolge bölgen çok zayıf kalmış. Simetriyi sağlamak için bir sonraki seansında $enZayifBolge odaklı çalışmalısın.";
      } else {
        aiMesaj =
            "Mükemmel bir denge! Vücut haritana göre tüm kas gruplarını orantılı şekilde geliştiriyorsun. Bu istikrarı koru.";
      }

      aiMesaj += WorkoutCalculator.aiSetTavsiyesiVer(basari, tTekrar, seviye);
    }

    _toplamTekrar = tTekrar;
    _toplamHata = tHata;
    _genelBasari = basari;
    _kisiselRekorlar = rekorlar;
    _aiAnalizMesaji = aiMesaj;
    _kasGelisimi = kasGruplari.map(
      (key, value) => MapEntry(key, (value / maxDeger) * 10),
    );
  }

  void _verileriKaydet() {
    if (_formKey.currentState!.validate()) {
      _profilKutusu.put('ad', _adController.text);
      _profilKutusu.put('yas', int.parse(_yasController.text));
      _profilKutusu.put('boy', int.parse(_boyController.text));
      _profilKutusu.put('kilo', double.parse(_kiloController.text));
      _profilKutusu.put('sakatlik', _seciliSakatlik);

      _vkiHesapla();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Profilin başarıyla güncellendi! 🚀',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1E2022),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    }
  }

  void _vkiHesapla() {
    if (_boyController.text.isNotEmpty && _kiloController.text.isNotEmpty) {
      double boyMetre = double.parse(_boyController.text) / 100;
      double kilo = double.parse(_kiloController.text);
      _vki = kilo / (boyMetre * boyMetre);
      if (_vki < 18.5)
        _vkiDurum = "Zayıf";
      else if (_vki >= 18.5 && _vki < 24.9)
        _vkiDurum = "İdeal";
      else if (_vki >= 25 && _vki < 29.9)
        _vkiDurum = "Fazla Kilolu";
      else
        _vkiDurum = "Obez";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Sporcu Profili',
          style: TextStyle(
            color: Color(0xFF1E2022),
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => _profilDuzenleBottomSheet(context),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4A00E0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_rounded, color: Color(0xFF4A00E0), size: 16),
                  SizedBox(width: 4),
                  Text(
                    "Düzenle",
                    style: TextStyle(
                      color: Color(0xFF4A00E0),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // YENİ: Çift Dinleyici ile Ekran Anında Güncellenecek!
      body: ValueListenableBuilder(
        valueListenable: Hive.box('userProfile').listenable(),
        builder: (context, Box profilKutusu, _) {
          return ValueListenableBuilder(
            valueListenable: Hive.box('egzersizGecmisi').listenable(),
            builder: (context, Box egzersizKutusu, _) {
              // Veriler UI çizilmeden milisaniyeler önce hesaplanır
              _istatistikleriAnlikGuncelle(egzersizKutusu, profilKutusu);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildGamerProfileHeader(),
                      const SizedBox(height: 25),
                      _buildAICoachCard(),
                      const SizedBox(height: 25),
                      _buildLifetimeStatsRow(),
                      const SizedBox(height: 35),
                      _buildMuscleRadarChart(),
                      const SizedBox(height: 35),
                      _buildPersonalRecordsSection(),
                      const SizedBox(height: 35),
                      _buildAchievementSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAICoachCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Color(0xFF00E5FF),
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Antrenör Analizi",
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _aiAnalizMesaji,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamerProfileHeader() {
    int seviye = (_toplamTekrar / 150).floor() + 1;
    double expOrani = (_toplamTekrar % 150) / 150.0;
    String unvan = "Çaylak";
    if (seviye >= 3) unvan = "Amatör Atlet";
    if (seviye >= 6) unvan = "Sıkı Sporcu";
    if (seviye >= 10) unvan = "Demir İrade";
    if (seviye >= 20) unvan = "Elit AI Atleti";

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E5FF), width: 3),
                ),
                child: const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF1E2022),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _adController.text.isNotEmpty
                          ? _adController.text
                          : "Şampiyon",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E2022),
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A00E0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Seviye $seviye • $unvan",
                        style: const TextStyle(
                          color: Color(0xFF4A00E0),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sonraki Seviye",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                "${_toplamTekrar % 150} / 150 EXP",
                style: const TextStyle(
                  color: Color(0xFF1E2022),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: expOrani,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00E5FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatKutu(
            "Kaldırılan\nTekrar",
            _toplamTekrar.toString(),
            Icons.fitness_center_rounded,
            const Color(0xFF4A00E0),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatKutu(
            "Genel\nBaşarı",
            "%${_genelBasari.toInt()}",
            Icons.bolt_rounded,
            Colors.green,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatKutu(
            "Güncel\nVKİ",
            _vki > 0 ? _vki.toStringAsFixed(1) : "--",
            Icons.monitor_weight_rounded,
            const Color(0xFFFF416C),
          ),
        ),
      ],
    );
  }

  Widget _buildStatKutu(
    String baslik,
    String deger,
    IconData ikon,
    Color renk,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(ikon, color: renk, size: 28),
          const SizedBox(height: 12),
          Text(
            deger,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: renk,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            baslik,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleRadarChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vücut Odak Haritası 🧬",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E2022),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _toplamTekrar == 0
              ? const Center(
                  child: Text(
                    "Analiz için antrenman yapmalısın.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    dataSets: [
                      RadarDataSet(
                        fillColor: const Color(0xFF00E5FF).withOpacity(0.3),
                        borderColor: const Color(0xFF00E5FF),
                        entryRadius: 4,
                        dataEntries: [
                          RadarEntry(value: _kasGelisimi["Bacak"] ?? 0),
                          RadarEntry(value: _kasGelisimi["Kol/Omuz"] ?? 0),
                          RadarEntry(value: _kasGelisimi["Karın"] ?? 0),
                          RadarEntry(value: _kasGelisimi["Sırt/Kalça"] ?? 0),
                        ],
                        borderWidth: 3,
                      ),
                    ],
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData: const BorderSide(
                      color: Colors.transparent,
                    ),
                    titlePositionPercentageOffset: 0.2,
                    titleTextStyle: const TextStyle(
                      color: Color(0xFF1E2022),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0:
                          return const RadarChartTitle(text: 'Bacak');
                        case 1:
                          return const RadarChartTitle(text: 'Kol/Omuz');
                        case 2:
                          return const RadarChartTitle(text: 'Karın');
                        case 3:
                          return const RadarChartTitle(text: 'Sırt/Kalça');
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                    tickCount: 4,
                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                    tickBorderData: const BorderSide(color: Colors.transparent),
                    gridBorderData: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 400),
                ),
        ),
      ],
    );
  }

  Widget _buildPersonalRecordsSection() {
    if (_kisiselRekorlar.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Kişisel Rekorlar 👑",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E2022),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "${_kisiselRekorlar.length} Rekor",
              style: const TextStyle(
                color: Color(0xFFFF8008),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: _kisiselRekorlar.entries.map((entry) {
              String birim = entry.key == "Plank" ? "sn" : "tekrar";
              return Container(
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(20),
                width: 150,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1C29), Color(0xFF2A2D3E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1C29).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${entry.value} $birim",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Max ${entry.key}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementSection() {
    bool ilkAdim = _toplamTekrar >= 1;
    bool usta = _toplamTekrar >= 500;
    bool efsane = _toplamTekrar >= 1000;
    bool keskinGoz = _genelBasari >= 90 && _toplamTekrar >= 50;
    bool plankCanavari = (_kisiselRekorlar['Plank'] ?? 0) >= 60;
    bool simetrikGuc =
        (_kasGelisimi["Bacak"] ?? 0) > 0 &&
        (_kasGelisimi["Kol/Omuz"] ?? 0) > 0 &&
        (_kasGelisimi["Karın"] ?? 0) > 0 &&
        (_kasGelisimi["Sırt/Kalça"] ?? 0) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Koleksiyon 🏅",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E2022),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.75,
          children: [
            _buildBadgeItem(
              Icons.star_rounded,
              "İlk Adım",
              ilkAdim,
              const Color(0xFFFF8008),
            ),
            _buildBadgeItem(
              Icons.military_tech_rounded,
              "500 Tekrar",
              usta,
              const Color(0xFF00C9FF),
            ),
            _buildBadgeItem(
              Icons.verified_user_rounded,
              "Kusursuz",
              keskinGoz,
              const Color(0xFF00B4DB),
            ),
            _buildBadgeItem(
              Icons.diamond_rounded,
              "Demir İrade",
              efsane,
              const Color(0xFF8A2BE2),
            ),
            _buildBadgeItem(
              Icons.timer_rounded,
              "Süre Uzmanı",
              plankCanavari,
              const Color(0xFFFF416C),
            ),
            _buildBadgeItem(
              Icons.balance_rounded,
              "Simetrik Güç",
              simetrikGuc,
              const Color(0xFF00E5FF),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeItem(
    IconData icon,
    String label,
    bool isUnlocked,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isUnlocked ? color.withOpacity(0.15) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isUnlocked
                    ? color.withOpacity(0.4)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: isUnlocked ? color : Colors.grey.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isUnlocked ? color : Colors.grey[300],
            size: 38,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isUnlocked ? const Color(0xFF1E2022) : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  void _profilDuzenleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Profili Düzenle",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E2022),
                  ),
                ),
                const SizedBox(height: 25),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        _adController,
                        'Ad Soyad',
                        Icons.person_rounded,
                        TextInputType.name,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _yasController,
                              'Yaş',
                              Icons.calendar_month_rounded,
                              TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTextField(
                              _boyController,
                              'Boy (cm)',
                              Icons.height_rounded,
                              TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _kiloController,
                        'Kilo (kg)',
                        Icons.scale_rounded,
                        TextInputType.number,
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _seciliSakatlik,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Odak / Sakatlık',
                            labelStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: const Icon(
                              Icons.medical_information_rounded,
                              color: Color(0xFF4A00E0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: _sakatlikBolgeleri
                              .map(
                                (String bolge) => DropdownMenuItem<String>(
                                  value: bolge,
                                  child: Text(
                                    bolge,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (String? yeniDeger) =>
                              setState(() => _seciliSakatlik = yeniDeger!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _verileriKaydet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2022),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Değişiklikleri Kaydet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    TextInputType type,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E2022),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF4A00E0)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Gerekli' : null,
      ),
    );
  }
}
