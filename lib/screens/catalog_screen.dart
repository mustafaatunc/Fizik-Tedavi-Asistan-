import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // YENİ: Haptik (Dokunsal) Geri Bildirim
import 'package:hive/hive.dart';
import 'dart:ui';
import 'squat_analiz_ekrani.dart';
import 'package:video_player/video_player.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _aramaMetni = "";
  String _seciliKategori = "Tümü";

  // YENİ: Kardiyo kategorisi eklendi
  final List<String> _kategoriler = [
    "Tümü",
    "Alt Vücut",
    "Üst Vücut",
    "Core",
    "Kardiyo",
  ];

  // DÜZENLEME: Tüm 'image' parametreleri kaldırıldı, yeni hareketler eklendi.
  final List<Map<String, dynamic>> _egzersizler = const [
    {
      "title": "Squat",
      "subtitle": "Diz & Kalça",
      "kategori": "Alt Vücut",
      "zorluk": "🟡 Orta",
      "zorlukRenk": Colors.amber,
      "hedef": 15,
      "icon": Icons.fitness_center,
      "color": Colors.blueAccent,
      "id": "Squat",
    },
    {
      "title": "Lunge",
      "subtitle": "İleri Adım",
      "kategori": "Alt Vücut",
      "zorluk": "🟢 Başlangıç",
      "zorlukRenk": Colors.greenAccent,
      "hedef": 15,
      "icon": Icons.directions_walk_rounded,
      "color": Colors.green,
      "id": "Lunge",
    },
    {
      "title": "Jumping Jack",
      "subtitle": "Isınma & Yağ Yakımı",
      "kategori": "Kardiyo",
      "zorluk": "🟢 Başlangıç",
      "zorlukRenk": Colors.greenAccent,
      "hedef": 30,
      "icon": Icons.accessibility_new_rounded,
      "color": Colors.pinkAccent,
      "id": "Jumping Jack",
    },
    {
      "title": "High Knees",
      "subtitle": "Diz Çekme",
      "kategori": "Kardiyo",
      "zorluk": "🟡 Orta",
      "zorlukRenk": Colors.amber,
      "hedef": 20,
      "icon": Icons.directions_run_rounded,
      "color": Colors.orangeAccent,
      "id": "High Knees",
    },
    {
      "title": "Bicep Curl",
      "subtitle": "Kol Bükme",
      "kategori": "Üst Vücut",
      "zorluk": "🟢 Başlangıç",
      "zorlukRenk": Colors.greenAccent,
      "hedef": 15,
      "icon": Icons.fitness_center_outlined,
      "color": Colors.purpleAccent,
      "id": "Bicep Curl",
    },
    {
      "title": "Front Raise",
      "subtitle": "Öne Omuz Kaldırma",
      "kategori": "Üst Vücut",
      "zorluk": "🟡 Orta",
      "zorlukRenk": Colors.amber,
      "hedef": 15,
      "icon": Icons.sports_gymnastics_rounded,
      "color": Colors.tealAccent,
      "id": "Front Raise",
    },
    {
      "title": "Omuz Açış",
      "subtitle": "Yanal Gövde",
      "kategori": "Üst Vücut",
      "zorluk": "🟡 Orta",
      "zorlukRenk": Colors.amber,
      "hedef": 15,
      "icon": Icons.accessibility_new_rounded,
      "color": Colors.teal,
      "id": "Omuz Yana Açış",
    },
    {
      "title": "Bacak Kaldırma",
      "subtitle": "Düz Bacak",
      "kategori": "Alt Vücut",
      "zorluk": "🟢 Başlangıç",
      "zorlukRenk": Colors.greenAccent,
      "hedef": 15,
      "icon": Icons.airline_seat_flat_angled,
      "color": Colors.indigo,
      "id": "Düz Bacak Kaldırma",
    },
    {
      "title": "Şınav",
      "subtitle": "Göğüs & Kol",
      "kategori": "Üst Vücut",
      "zorluk": "🔴 İleri",
      "zorlukRenk": Colors.redAccent,
      "hedef": 10,
      "icon": Icons.sports_gymnastics,
      "color": Colors.redAccent,
      "id": "Şınav",
    },
    {
      "title": "Plank",
      "subtitle": "Süre & Omurga",
      "kategori": "Core",
      "zorluk": "🟡 Orta",
      "zorlukRenk": Colors.amber,
      "hedef": 30,
      "icon": Icons.timer_outlined,
      "color": Colors.orange,
      "id": "Plank",
    },
    {
      "title": "Köprü (Bridge)",
      "subtitle": "Bel & Kalça",
      "kategori": "Core",
      "zorluk": "🟢 Başlangıç",
      "zorlukRenk": Colors.greenAccent,
      "hedef": 15,
      "icon": Icons.airline_seat_recline_normal_rounded,
      "color": Colors.cyan,
      "id": "Köprü",
    },
    {
      "title": "Mekik",
      "subtitle": "Karın (Core)",
      "kategori": "Core",
      "zorluk": "🟡 Orta",
      "zorlukRenk": Colors.amber,
      "hedef": 15,
      "icon": Icons.sports_martial_arts,
      "color": Colors.deepOrange,
      "id": "Mekik",
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtrelenmisListe = _egzersizler.where((e) {
      bool kategoriUyuyor =
          _seciliKategori == "Tümü" || e["kategori"] == _seciliKategori;
      bool aramaUyuyor =
          e["title"].toString().toLowerCase().contains(
            _aramaMetni.toLowerCase(),
          ) ||
          e["id"].toString().toLowerCase().contains(_aramaMetni.toLowerCase());
      return kategoriUyuyor && aramaUyuyor;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Egzersiz Kütüphanesi",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E2022),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (deger) => setState(() => _aramaMetni = deger),
                decoration: const InputDecoration(
                  hintText: "Hareket Ara (Örn: Plank)",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: Color(0xFF4A00E0)),
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: _kategoriler.map((kategori) {
                bool secili = _seciliKategori == kategori;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _seciliKategori = kategori);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: secili ? const Color(0xFF1E2022) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: secili
                            ? Colors.transparent
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: secili
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      kategori,
                      style: TextStyle(
                        color: secili ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filtrelenmisListe.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio:
                              0.85, // Kart boyut oranı hafif güncellendi
                        ),
                    itemCount: filtrelenmisListe.length,
                    itemBuilder: (context, index) {
                      final e = filtrelenmisListe[index];
                      return _buildModernGridCard(
                        context,
                        title: e["title"],
                        subtitle: e["subtitle"],
                        icon: e["icon"],
                        color: e["color"],
                        egzersizAdi: e["id"],
                        zorluk: e["zorluk"],
                        zorlukRenk: e["zorlukRenk"],
                        hedef: e["hedef"],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: const Color(0xFF4A00E0).withOpacity(0.2),
          ),
          const SizedBox(height: 20),
          const Text(
            "Sonuç Bulunamadı",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E2022),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Farklı bir hareket aramayı dene.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // DÜZENLEME: imagePath parametresi tamamen silindi.
  Widget _buildModernGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String egzersizAdi,
    required String zorluk,
    required Color zorlukRenk,
    required int hedef,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _nasilYapilirBottomSheet(context, egzersizAdi, false, hedef);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Resim yerine arka planda dev ve yarı saydam ikon gösteriyoruz (Premium Hissiyat)
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: 110,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      zorluk,
                      style: TextStyle(
                        color: zorlukRenk,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nasilYapilirBottomSheet(
    BuildContext context,
    String egzersizAdi,
    bool isTest,
    int varsayilanHedef,
  ) {
    String aciklama = "";
    String videoYolu = "";

    // YENİ VE ESKİ HAREKETLERİN VİDEO VE AÇIKLAMALARI
    if (egzersizAdi == "Squat") {
      aciklama =
          "1. Ayaklarınızı omuz hizasında açın.\n2. Telefonu tüm vücudunuzu görecek şekilde karşıya koyun.\n3. Sırtınızı dik tutarak dizleriniz 90° olana kadar çömelin ve kalkın.";
      videoYolu = "assets/videos/squat.mp4";
    } else if (egzersizAdi == "Lunge") {
      aciklama =
          "1. Telefonu sizi yandan (profil) görecek şekilde yerleştirin.\n2. Bir adım öne atarak dizinizi yere yaklaştırın (yaklaşık 100°).\n3. Başlangıç pozisyonuna dönün.";
      videoYolu = "assets/videos/lunge.mp4";
    } else if (egzersizAdi == "Jumping Jack") {
      aciklama =
          "1. Ayakta dik durun.\n2. Zıplayarak bacaklarınızı omuz genişliğinde açarken kollarınızı başınızın üzerinde birleştirin.\n3. Tekrar zıplayarak başlangıç pozisyonuna dönün.";
      videoYolu = "assets/videos/jumping_jack.mp4";
    } else if (egzersizAdi == "High Knees") {
      aciklama =
          "1. Telefonu sizi yandan görecek şekilde koyun.\n2. Olduğunuz yerde koşar gibi yaparak dizlerinizi sırayla kalça hizanıza (90 derece) kadar çekin.";
      videoYolu = "assets/videos/high_knees.mp4";
    } else if (egzersizAdi == "Bicep Curl") {
      aciklama =
          "1. Telefonu sizi YANDAN görecek şekilde yerleştirin.\n2. Kollarınızı vücudunuza yapıştırın.\n3. Dirseğinizi bükerek ağırlığı omuz hizanıza kaldırın.";
      videoYolu = "assets/videos/bicep.mp4";
    } else if (egzersizAdi == "Front Raise") {
      aciklama =
          "1. Telefonu sizi yandan görecek şekilde yerleştirin.\n2. Kollarınızı bükmeden, dambılları (veya su şişelerini) göz hizanıza kadar öne doğru kaldırıp indirin.";
      videoYolu = "assets/videos/front_raise.mp4";
    } else if (egzersizAdi == "Omuz Yana Açış") {
      aciklama =
          "1. Ayakta dik durun ve kolları yanda tutun.\n2. Kollarınızı kırmadan, omuz hizasına gelene kadar (80° ve üstü) iki yana kaldırıp indirin.";
      videoYolu = "assets/videos/raise.mp4";
    } else if (egzersizAdi == "Düz Bacak Kaldırma") {
      aciklama =
          "1. Yere sırt üstü uzanın.\n2. Bacağınızı dizden kırmadan dümdüz havaya kaldırın ve yavaşça indirin.";
      videoYolu = "assets/videos/leg.mp4";
    } else if (egzersizAdi == "Şınav") {
      aciklama =
          "1. Yere yüz üstü uzanıp şınav pozisyonu alın.\n2. Dirsekleriniz 90° olana kadar inin ve kollarınız dümdüz olana kadar kendinizi itin.";
      videoYolu = "assets/videos/pushup.mp4";
    } else if (egzersizAdi == "Plank") {
      aciklama =
          "1. Şınav pozisyonu alın veya dirseklerinizin üzerinde durun.\n2. Sırtınızı ve kalçanızı dümdüz (180°) tutmaya çalışın.";
      videoYolu = "assets/videos/plank.mp4";
    } else if (egzersizAdi == "Köprü") {
      aciklama =
          "1. Sırt üstü uzanın, ayak tabanlarınızı yere basın.\n2. Kalçanızı sıkarak gövdeniz dümdüz olana kadar yukarı kaldırın.";
      videoYolu = "assets/videos/bridge.mp4";
    } else if (egzersizAdi == "Mekik") {
      aciklama =
          "1. Sırt üstü uzanıp dizlerinizi bükün.\n2. Sadece omuzlarınızı ve sırtınızın üst kısmını yerden kaldırarak karın kaslarınızı sıkıştırın.";
      videoYolu = "assets/videos/crunch.mp4";
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "$egzersizAdi Nasıl Yapılır?",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E2022),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LocalVideoPlayer(videoPath: videoYolu),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  aciklama,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A00E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: const Color(0xFF4A00E0).withOpacity(0.5),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    _akilliHedefBottomSheet(
                      context,
                      egzersizAdi,
                      isTest,
                      varsayilanHedef,
                    );
                  },
                  child: const Text(
                    "Anladım, Hedef Belirle",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
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
        HapticFeedback.heavyImpact();
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
}

class LocalVideoPlayer extends StatefulWidget {
  final String videoPath;
  const LocalVideoPlayer({Key? key, required this.videoPath}) : super(key: key);
  @override
  _LocalVideoPlayerState createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize()
          .then((_) {
            setState(() {
              _initialized = true;
              _controller.setLooping(true);
              _controller.setVolume(0.0);
              _controller.play();
            });
          })
          .catchError((error) {
            setState(() {
              _hasError = true;
            });
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded, size: 50, color: Colors.white54),
            SizedBox(height: 10),
            Text(
              "Video Bulunamadı",
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    if (!_initialized) {
      return const SizedBox(
        height: 220,
        width: double.infinity,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
    }
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.black,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}
