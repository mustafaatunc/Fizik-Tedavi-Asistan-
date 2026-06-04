import 'package:fizik_tedavi_asistani/utils/workout_calculator.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import 'squat_analiz_ekrani.dart';
import 'history_screen.dart';
import 'catalog_screen.dart';
// YENİ: Merkezi Yapay Zeka Motorumuz!

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _seciliFiltre = 'Senin İçin';

  final List<Map<String, dynamic>> _tumEgzersizler = [
    {
      'isim': 'Squat',
      'icon': Icons.fitness_center_rounded,
      'c1': const Color(0xFF4A00E0),
      'c2': const Color(0xFF8E2DE2),
      'hedef': 15,
      'kategori': 'Alt Vücut',
    },
    {
      'isim': 'Lunge',
      'icon': Icons.directions_walk_rounded,
      'c1': const Color(0xFF00B4DB),
      'c2': const Color(0xFF0083B0),
      'hedef': 15,
      'kategori': 'Alt Vücut',
    },
    {
      'isim': 'Düz Bacak Kaldırma',
      'icon': Icons.airline_seat_flat_angled_rounded,
      'c1': const Color(0xFF1CB5E0),
      'c2': const Color(0xFF000046),
      'hedef': 15,
      'kategori': 'Alt Vücut',
    },
    {
      'isim': 'Şınav',
      'icon': Icons.sports_gymnastics_rounded,
      'c1': const Color(0xFFFF416C),
      'c2': const Color(0xFFFF4B2B),
      'hedef': 15,
      'kategori': 'Üst Vücut',
    },
    {
      'isim': 'Bicep Curl',
      'icon': Icons.fitness_center_rounded,
      'c1': const Color(0xFF833AB4),
      'c2': const Color(0xFFFD1D1D),
      'hedef': 15,
      'kategori': 'Üst Vücut',
    },
    {
      'isim': 'Omuz Yana Açış',
      'icon': Icons.accessibility_new_rounded,
      'c1': const Color(0xFF11998e),
      'c2': const Color(0xFF38ef7d),
      'hedef': 15,
      'kategori': 'Üst Vücut',
    },
    {
      'isim': 'Plank',
      'icon': Icons.timer_rounded,
      'c1': const Color(0xFFF2994A),
      'c2': const Color(0xFFF2C94C),
      'hedef': 30,
      'kategori': 'Core',
    },
    {
      'isim': 'Köprü',
      'icon': Icons.airline_seat_recline_normal_rounded,
      'c1': const Color(0xFF00C9FF),
      'c2': const Color(0xFF92FE9D),
      'hedef': 15,
      'kategori': 'Core',
    },
    {
      'isim': 'Mekik',
      'icon': Icons.sports_martial_arts_rounded,
      'c1': const Color(0xFFfc4a1a),
      'c2': const Color(0xFFf7b733),
      'hedef': 15,
      'kategori': 'Core',
    },
  ];

  // YENİ: Tamamen Kullanıcı Odaklı Dinamik AI Programı
  // YENİ: Tamamen Kullanıcı Geçmişine Odaklı Dinamik AI Programı
  Map<String, dynamic> _getGunlukAIProgrami() {
    var kutu = Hive.box('egzersizGecmisi');

    // 1. Kullanıcının tüm geçmişini tara ve kas gruplarını hesapla
    Map<String, int> kasGruplari = {
      "Bacak": 0,
      "Kol/Omuz": 0,
      "Karın": 0,
      "Sırt/Kalça": 0,
    };

    int toplamTekrar = 0;

    for (var key in kutu.keys) {
      var veri = kutu.get(key);
      if (veri != null && veri['tekrar'] != null) {
        int tekrar = veri['tekrar'] as int;
        toplamTekrar += tekrar;

        String keyStr = key.toString();
        List<String> parcalar = keyStr.split('-');
        if (parcalar.length >= 4) {
          String egzersiz = parcalar.sublist(3).join('-');

          // Yapılan hareketleri kas gruplarına dağıt
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

    // 2. Eğer kullanıcı henüz yeterince spor yapmamışsa (Veri yetersizse) AI Keşif modu çalışır
    if (toplamTekrar < 1) {
      return {
        'baslik': 'AI Keşif Antrenmanı 🚀',
        'aciklama':
            'Seni tanıyabilmem ve analiz edebilmem için önce bu temel hareketleri yapmalısın. Sonrasında programın sana özel şekillenecek!',
        'sure': '10 Dk',
        'program': [
          {'egzersiz': 'Squat', 'hedef': 15, 'birim': 'tkr'},
          {'egzersiz': 'Şınav', 'hedef': 10, 'birim': 'tkr'},
          {'egzersiz': 'Plank', 'hedef': 30, 'birim': 'sn'},
        ],
      };
    }

    // 3. --- ASIL YAPAY ZEKA MANTIĞI: Zayıf Bölgeyi Tespit Et ve Program Üret ---
    String enZayifBolge = kasGruplari.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;

    if (enZayifBolge == "Kol/Omuz") {
      return {
        'baslik': 'AI Hedef: Üst Vücut Gelişimi 💪',
        'aciklama':
            'Radar verilerime göre omuz ve kolların bacaklarına kıyasla çok zayıf kalmış. Simetriyi sağlamak için bugün odak noktamız üst vücut!',
        'sure': '15 Dk',
        'program': [
          {'egzersiz': 'Şınav', 'hedef': 15, 'birim': 'tkr'},
          {'egzersiz': 'Bicep Curl', 'hedef': 20, 'birim': 'tkr'},
          {'egzersiz': 'Omuz Yana Açış', 'hedef': 15, 'birim': 'tkr'},
        ],
      };
    } else if (enZayifBolge == "Bacak") {
      return {
        'baslik': 'AI Hedef: Alt Vücut Ateşlemesi 🦵',
        'aciklama':
            'Analizlerime göre üst vücudunu iyi geliştirmişsin ama bacakları ihmal ediyorsun. Dengeyi sağlamak için bugün bacak çalışıyoruz!',
        'sure': '15 Dk',
        'program': [
          {'egzersiz': 'Squat', 'hedef': 20, 'birim': 'tkr'},
          {'egzersiz': 'Lunge', 'hedef': 15, 'birim': 'tkr'},
          {'egzersiz': 'Düz Bacak Kaldırma', 'hedef': 15, 'birim': 'tkr'},
        ],
      };
    } else if (enZayifBolge == "Karın") {
      return {
        'baslik': 'AI Hedef: Çelik Core 🛡️',
        'aciklama':
            'Vücudunun denge merkezi olan karın (Core) kasların diğer bölgelere göre zayıf. Bugün merkez bölgemizi güçlendiriyoruz!',
        'sure': '10 Dk',
        'program': [
          {'egzersiz': 'Plank', 'hedef': 45, 'birim': 'sn'},
          {'egzersiz': 'Mekik', 'hedef': 20, 'birim': 'tkr'},
          {'egzersiz': 'High Knees', 'hedef': 20, 'birim': 'tkr'},
        ],
      };
    } else {
      // Sırt/Kalça en zayıfsa
      return {
        'baslik': 'AI Hedef: Arka Zincir Gücü ⚡',
        'aciklama':
            'Geçmiş antrenmanlarına göre arka bacak ve bel kasların eksik kalmış. Duruş bozukluğunu önlemek için bu zinciri tamamla.',
        'sure': '12 Dk',
        'program': [
          {'egzersiz': 'Köprü', 'hedef': 20, 'birim': 'tkr'},
          {'egzersiz': 'Lunge', 'hedef': 15, 'birim': 'tkr'},
          {'egzersiz': 'Squat', 'hedef': 15, 'birim': 'tkr'},
        ],
      };
    }
  }

  String _getEnCokYapilanEgzersiz() {
    var kutu = Hive.box('egzersizGecmisi');
    Map<String, int> frekans = {};
    for (var key in kutu.keys) {
      String keyStr = key.toString();
      List<String> parcalar = keyStr.split('-');
      if (parcalar.length >= 4) {
        String egzersiz = parcalar.sublist(3).join('-');
        var veri = kutu.get(key);
        if (veri != null && veri['tekrar'] != null) {
          frekans[egzersiz] =
              (frekans[egzersiz] ?? 0) + (veri['tekrar'] as int);
        }
      }
    }
    if (frekans.isEmpty) return "Squat";
    return frekans.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumHeader(),
              Transform.translate(
                offset: const Offset(0, -50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWeeklyActivityBar(),
                      _buildDailyScorecard(context),
                      const SizedBox(height: 35),
                      _buildAITodayRoutineCard(),
                      const SizedBox(height: 35),
                      _buildQuickStartSection(context),
                      const SizedBox(height: 40),
                      const Text(
                        "Bugünkü Aktivite",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2022),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTodaySessionList(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyActivityBar() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('egzersizGecmisi').listenable(),
      builder: (context, Box kutu, _) {
        DateTime now = DateTime.now();
        int currentWeekday = now.weekday;
        DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

        List<Widget> dayWidgets = [];
        List<String> dayNames = [
          "Pzt",
          "Sal",
          "Çar",
          "Per",
          "Cum",
          "Cmt",
          "Paz",
        ];

        for (int i = 0; i < 7; i++) {
          DateTime day = startOfWeek.add(Duration(days: i));
          String dateStr = "${day.day}-${day.month}-${day.year}";
          bool hasWorkout = false;

          for (var key in kutu.keys) {
            if (key.toString().startsWith(dateStr)) {
              hasWorkout = true;
              break;
            }
          }

          bool isToday =
              (day.day == now.day &&
              day.month == now.month &&
              day.year == now.year);

          dayWidgets.add(
            Expanded(
              child: Column(
                children: [
                  Text(
                    dayNames[i],
                    style: TextStyle(
                      color: isToday ? const Color(0xFF00E5FF) : Colors.grey,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasWorkout
                          ? const Color(0xFF00E5FF).withOpacity(0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: hasWorkout
                            ? const Color(0xFF00E5FF)
                            : Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: hasWorkout
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF00E5FF),
                            size: 18,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          margin: const EdgeInsets.only(bottom: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10.0, bottom: 15.0),
                child: Text(
                  "Haftalık Seri",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E2022),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: dayWidgets,
              ),
            ],
          ),
        );
      },
    );
  }

  // --- YENİ: Merkezi Motor (DRY) İle Çalışan Skorbord ---
  Widget _buildDailyScorecard(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('egzersizGecmisi').listenable(),
      builder: (context, Box kutu, _) {
        final simdi = DateTime.now();
        final bugunTarih = "${simdi.day}-${simdi.month}-${simdi.year}";

        int toplamTekrar = 0;
        int toplamHata = 0;
        double toplamKalori = 0.0;
        int toplamAktifSaniye = 0;

        for (var key in kutu.keys) {
          if (key.toString().startsWith(bugunTarih)) {
            String egzersizAdi = key.toString().replaceFirst(
              "$bugunTarih-",
              "",
            );
            var veri = kutu.get(key);

            if (veri != null &&
                veri['tekrar'] != null &&
                egzersizAdi.isNotEmpty &&
                egzersizAdi != bugunTarih) {
              int tekrar = veri['tekrar'] as int;
              toplamTekrar += tekrar;
              toplamHata += (veri['hata'] as int);

              // DRY KURALI UYGULANDI: Kalori ve Süreyi artık tek bir dosyadan hesaplıyoruz!
              var hesap = WorkoutCalculator.hesaplaKaloriVeSure(
                egzersizAdi,
                tekrar,
              );
              toplamKalori += hesap['kalori']!;
              toplamAktifSaniye += hesap['sure']!.toInt();
            }
          }
        }

        double basariOrani = toplamTekrar == 0
            ? 0
            : (toplamTekrar / (toplamTekrar + toplamHata)) * 100;
        double progressOrani = (toplamTekrar / 50.0).clamp(0.0, 1.0);
        int aktifDakika = (toplamAktifSaniye / 60).floor();

        return Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade100,
                      ),
                    ),
                    CircularProgressIndicator(
                      value: progressOrani,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E5FF),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(progressOrani * 100).toInt()}%",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E2022),
                              letterSpacing: -1,
                            ),
                          ),
                          const Text(
                            "Hedef",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Günlük İlerleme",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "$toplamTekrar / 50",
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2022),
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMiniStatBadge(
                          Icons.bolt_rounded,
                          "%${basariOrani.toInt()} Başarı",
                          const Color(0xFF00E5FF),
                        ),
                        _buildMiniStatBadge(
                          Icons.local_fire_department_rounded,
                          "${toplamKalori.toInt()} kcal",
                          Colors.orange,
                        ),
                        _buildMiniStatBadge(
                          Icons.timer_rounded,
                          "$aktifDakika Dk",
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStatBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('egzersizGecmisi').listenable(),
      builder: (context, Box kutu, _) {
        var profilKutusu = Hive.box('userProfile');
        String kullaniciAdi = profilKutusu.get('ad', defaultValue: 'Şampiyon');
        if (kullaniciAdi.contains(" "))
          kullaniciAdi = kullaniciAdi.split(" ")[0];

        int streakGunu = 0;
        DateTime kontrolEdilecekGun = DateTime.now();
        bool seriDevamEdiyor = true;
        Set<String> yapilanGunler = {};
        for (var key in kutu.keys) {
          String keyStr = key.toString();
          List<String> parcalar = keyStr.split('-');
          if (parcalar.length >= 3)
            yapilanGunler.add("${parcalar[0]}-${parcalar[1]}-${parcalar[2]}");
        }
        while (seriDevamEdiyor) {
          String arananTarih =
              "${kontrolEdilecekGun.day}-${kontrolEdilecekGun.month}-${kontrolEdilecekGun.year}";
          if (yapilanGunler.contains(arananTarih)) {
            streakGunu++;
            kontrolEdilecekGun = kontrolEdilecekGun.subtract(
              const Duration(days: 1),
            );
          } else {
            if (streakGunu == 0 &&
                kontrolEdilecekGun.day == DateTime.now().day) {
              kontrolEdilecekGun = kontrolEdilecekGun.subtract(
                const Duration(days: 1),
              );
            } else {
              seriDevamEdiyor = false;
            }
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 20,
            left: 24,
            right: 24,
            bottom: 80,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00E5FF),
                              width: 2,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white12,
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Hazır mısın,",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                kullaniciAdi,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: streakGunu > 0
                          ? const LinearGradient(
                              colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: streakGunu > 0
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF416C).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: streakGunu > 0 ? Colors.white : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$streakGunu Gün",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: streakGunu > 0
                                ? Colors.white
                                : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAITodayRoutineCard() {
    // YENİ: Kart artık veritabanındaki her değişikliği anlık dinliyor!
    return ValueListenableBuilder(
      valueListenable: Hive.box('egzersizGecmisi').listenable(),
      builder: (context, Box kutu, _) {
        final gunlukVeri = _getGunlukAIProgrami();
        final List program = gunlukVeri['program'];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF00E5FF).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF00E5FF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Günün AI Programı",
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      gunlukVeri['sure'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                gunlukVeri['baslik'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                gunlukVeri['aciklama'],
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRoutineStep(
                    program[0]['egzersiz'],
                    "${program[0]['hedef']} ${program[0]['birim']}",
                    true,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white30,
                    size: 14,
                  ),
                  _buildRoutineStep(
                    program[1]['egzersiz'],
                    "${program[1]['hedef']} ${program[1]['birim']}",
                    false,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white30,
                    size: 14,
                  ),
                  _buildRoutineStep(
                    program[2]['egzersiz'],
                    "${program[2]['hedef']} ${program[2]['birim']}",
                    false,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnaEkran(
                          zincirlemeProgram: [
                            {
                              'egzersiz': program[0]['egzersiz'],
                              'hedef': program[0]['hedef'],
                            },
                            {
                              'egzersiz': program[1]['egzersiz'],
                              'hedef': program[1]['hedef'],
                            },
                            {
                              'egzersiz': program[2]['egzersiz'],
                              'hedef': program[2]['hedef'],
                            },
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Programı Başlat",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoutineStep(String ad, String hedef, bool aktif) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: aktif
                ? const Color(0xFF00E5FF).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: aktif ? const Color(0xFF00E5FF) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: aktif ? const Color(0xFF00E5FF) : Colors.white54,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ad,
          style: TextStyle(
            color: aktif ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          hedef,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildQuickStartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Hızlı Başlat",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E2022),
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CatalogScreen(),
                  ),
                );
              },
              child: const Row(
                children: [
                  Text(
                    "Tümünü Gör",
                    style: TextStyle(
                      color: Color(0xFF4A00E0),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF4A00E0),
                    size: 18,
                  ),
                ],
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
            children: [
              _buildFilterChip("🔥 Senin İçin"),
              const SizedBox(width: 10),
              _buildFilterChip("🦵 Alt Vücut"),
              const SizedBox(width: 10),
              _buildFilterChip("💪 Üst Vücut"),
              const SizedBox(width: 10),
              _buildFilterChip("🛡️ Core"),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(children: _buildFilteredCards()),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String etiket) {
    bool secili = _seciliFiltre == etiket;
    return GestureDetector(
      onTap: () => setState(() => _seciliFiltre = etiket),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: secili ? const Color(0xFF1E2022) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: secili
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
          border: Border.all(
            color: secili ? Colors.transparent : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          etiket,
          style: TextStyle(
            color: secili ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFilteredCards() {
    List<Widget> kartlar = [];
    if (_seciliFiltre == "🔥 Senin İçin") {
      String favoriAd = _getEnCokYapilanEgzersiz();
      var favoriEgzersiz = _tumEgzersizler.firstWhere(
        (e) => e['isim'] == favoriAd,
        orElse: () => _tumEgzersizler[0],
      );
      kartlar.add(
        _buildWorkoutCard(
          favoriEgzersiz['isim'],
          favoriEgzersiz['icon'],
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
          favoriEgzersiz['hedef'],
          rozet: "👑 Favorin",
        ),
      );
      kartlar.add(const SizedBox(width: 20));
      var rastgele = _tumEgzersizler[Random().nextInt(_tumEgzersizler.length)];
      while (rastgele['isim'] == favoriAd) {
        rastgele = _tumEgzersizler[Random().nextInt(_tumEgzersizler.length)];
      }
      kartlar.add(
        _buildWorkoutCard(
          rastgele['isim'],
          rastgele['icon'],
          rastgele['c1'],
          rastgele['c2'],
          rastgele['hedef'],
          rozet: "🎲 Sürpriz",
        ),
      );
      kartlar.add(const SizedBox(width: 20));
      var gununOnerisi = _tumEgzersizler.firstWhere(
        (e) => e['isim'] == 'Plank',
      );
      kartlar.add(
        _buildWorkoutCard(
          gununOnerisi['isim'],
          gununOnerisi['icon'],
          gununOnerisi['c1'],
          gununOnerisi['c2'],
          gununOnerisi['hedef'],
        ),
      );
    } else {
      String aranacakKategori = _seciliFiltre.split(" ")[1];
      if (_seciliFiltre.contains("Core")) aranacakKategori = "Core";
      if (_seciliFiltre.contains("Üst Vücut")) aranacakKategori = "Üst Vücut";
      var filtrelenmisler = _tumEgzersizler
          .where((e) => e['kategori'] == aranacakKategori)
          .toList();
      for (int i = 0; i < filtrelenmisler.length; i++) {
        var e = filtrelenmisler[i];
        kartlar.add(
          _buildWorkoutCard(e['isim'], e['icon'], e['c1'], e['c2'], e['hedef']),
        );
        if (i != filtrelenmisler.length - 1)
          kartlar.add(const SizedBox(width: 20));
      }
    }
    return kartlar;
  }

  Widget _buildWorkoutCard(
    String egzersiz,
    IconData icon,
    Color colorStart,
    Color colorEnd,
    int varsayilanHedef, {
    String? rozet,
  }) {
    return GestureDetector(
      onTap: () {
        _akilliHedefBottomSheet(context, egzersiz, false, varsayilanHedef);
      },
      child: Container(
        width: 170,
        height: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          gradient: LinearGradient(
            colors: [colorStart, colorEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorEnd.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 120,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    if (rozet != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          rozet,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      egzersiz,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "AI Analizi",
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _akilliHedefBottomSheet(
    BuildContext context,
    String egzersizAdi,
    bool isTest,
    int varsayilanHedef,
  ) {
    bool isSaniye = egzersizAdi == "Plank";
    String birim = isSaniye ? "sn" : "tekrar";
    var kutu = Hive.box('egzersizGecmisi');
    int rekor = varsayilanHedef;
    for (var key in kutu.keys) {
      if (key.toString().endsWith("-$egzersizAdi")) {
        var veri = kutu.get(key);
        int gecmisTekrar = veri['tekrar'] ?? 0;
        if (gecmisTekrar > rekor) rekor = gecmisTekrar;
      }
    }
    int recoveryHedef = (rekor * 0.6).round();
    int optimalHedef = (rekor * 1.1).round();
    int challengeHedef = (rekor * 1.3).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Color(0xFF1E2022),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF00E5FF),
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "AI Hedef Analizi",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Geçmiş performansına ve kişisel rekorlarına göre bugün senin için en ideal hedefleri hesapladım.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildTargetSelectCard(
                context,
                "Aktif Dinlenme",
                "Kaslarını yormadan formunu koru",
                recoveryHedef,
                birim,
                Colors.greenAccent,
                egzersizAdi,
                isTest,
                false,
              ),
              const SizedBox(height: 15),
              _buildTargetSelectCard(
                context,
                "AI Optimum Gelişim",
                "Senin için hesaplanan en verimli büyüme",
                optimalHedef,
                birim,
                const Color(0xFF00E5FF),
                egzersizAdi,
                isTest,
                true,
              ),
              const SizedBox(height: 15),
              _buildTargetSelectCard(
                context,
                "Sınırları Zorla",
                "Kişisel rekorunu (PR) kırma vakti!",
                challengeHedef,
                birim,
                const Color(0xFFFF416C),
                egzersizAdi,
                isTest,
                false,
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargetSelectCard(
    BuildContext context,
    String baslik,
    String altBaslik,
    int hedef,
    String birim,
    Color renk,
    String egzersiz,
    bool isTest,
    bool recommended,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnaEkran(
              testModu: isTest,
              egzersizTipi: egzersiz,
              hedefTekrar: hedef,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: recommended
              ? renk.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: recommended ? renk : Colors.white.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: recommended
              ? [
                  BoxShadow(
                    color: renk.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (recommended)
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFF00E5FF),
                          size: 18,
                        ),
                      if (recommended) const SizedBox(width: 6),
                      Text(
                        baslik,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: recommended ? renk : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    altBaslik,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: renk.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "$hedef\n$birim",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: renk,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySessionList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('egzersizGecmisi').listenable(),
      builder: (context, Box kutu, _) {
        final simdi = DateTime.now();
        final bugunTarih = "${simdi.day}-${simdi.month}-${simdi.year}";
        List<Widget> gunlukDetaylar = [];

        for (var key in kutu.keys) {
          if (key.toString().startsWith(bugunTarih)) {
            String egzersizAdi = key.toString().replaceFirst(
              "$bugunTarih-",
              "",
            );
            var veri = kutu.get(key);
            if (veri != null &&
                veri['tekrar'] != null &&
                egzersizAdi.isNotEmpty &&
                egzersizAdi != bugunTarih) {
              gunlukDetaylar.add(
                _buildTodayListItem(egzersizAdi, veri['tekrar'], veri['hata']),
              );
            }
          }
        }

        if (gunlukDetaylar.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A00E0).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_run_rounded,
                    size: 60,
                    color: const Color(0xFF4A00E0).withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Henüz Hareket Yok",
                  style: TextStyle(
                    color: Color(0xFF1E2022),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Hadi, günün ilk hareketini yaparak seriye başla!",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          return Column(children: gunlukDetaylar.reversed.toList());
        }
      },
    );
  }

  Widget _buildTodayListItem(String egzersiz, int tekrar, int hata) {
    String birim = egzersiz == "Plank" ? "saniye" : "tekrar";
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A00E0).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  egzersiz,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF1E2022),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "$tekrar $birim",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (hata > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$hata Hata",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
