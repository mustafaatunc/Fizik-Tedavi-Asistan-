import 'package:flutter/material.dart';
import 'squat_analiz_ekrani.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  //  EGZERSİZ VERİTABANI
  final List<Map<String, dynamic>> egzersizler = const [
    {
      "title": "Squat",
      "subtitle": "Diz & Kalça",
      "icon": Icons.fitness_center,
      "color": Colors.blueAccent,
      "id": "Squat",
      "image": "assets/images/squat.png",
    },
    {
      "title": "Lunge",
      "subtitle": "İleri Adım",
      "icon": Icons.directions_walk_rounded,
      "color": Colors.green,
      "id": "Lunge",
      "image": "assets/images/lunge.png",
    },
    {
      "title": "Bicep Curl",
      "subtitle": "Kol Bükme",
      "icon": Icons.fitness_center_outlined,
      "color": Colors.purpleAccent,
      "id": "Bicep Curl",
      "image": "assets/images/bicep.png",
    },
    {
      "title": "Omuz Açış",
      "subtitle": "Yanal Gövde",
      "icon": Icons.accessibility_new_rounded,
      "color": Colors.teal,
      "id": "Omuz Yana Açış",
      "image": "assets/images/raise.png",
    },
    {
      "title": "Bacak Kaldırma",
      "subtitle": "Düz Bacak",
      "icon": Icons.airline_seat_flat_angled,
      "color": Colors.indigo,
      "id": "Düz Bacak Kaldırma",
      "image": "assets/images/leg.png",
    },
    {
      "title": "Şınav",
      "subtitle": "Göğüs & Kol",
      "icon": Icons.sports_gymnastics,
      "color": Colors.redAccent,
      "id": "Şınav",
      "image": "assets/images/pushup.png",
    },
    {
      "title": "Plank",
      "subtitle": "Süre & Omurga",
      "icon": Icons.timer_outlined,
      "color": Colors.orange,
      "id": "Plank",
      "image": "assets/images/plank.png",
    },
    {
      "title": "Köprü (Bridge)",
      "subtitle": "Bel & Kalça",
      "icon": Icons.airline_seat_recline_normal_rounded,
      "color": Colors.cyan,
      "id": "Köprü",
      "image": "assets/images/bridge.png",
    },
    {
      "title": "Mekik",
      "subtitle": "Karın (Core)",
      "icon": Icons.sports_martial_arts,
      "color": Colors.deepOrange,
      "id": "Mekik",
      "image": "assets/images/crunch.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Egzersiz Kataloğu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3142),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Text(
              "Hedefini Seç",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              itemCount: egzersizler.length,
              itemBuilder: (context, index) {
                final egzersiz = egzersizler[index];
                return _buildModernGridCard(
                  context,
                  title: egzersiz["title"],
                  subtitle: egzersiz["subtitle"],
                  icon: egzersiz["icon"],
                  color: egzersiz["color"],
                  egzersizAdi: egzersiz["id"],
                  imagePath: egzersiz["image"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String egzersizAdi,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () {
        _nasilYapilirDialog(context, egzersizAdi, false);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                icon,
                size: 110,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(icon, color: color, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  void _zorlukSeviyesiDialog(
    BuildContext context,
    String egzersizAdi,
    bool isTest,
  ) {
    bool isSaniye = egzersizAdi == "Plank";
    String birim = isSaniye ? "Saniye" : "Tekrar";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text(
            "$egzersizAdi Hedefi",
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Kendine uygun zorluk seviyesini seç:",
                style: TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildLevelButton(
                context,
                "Başlangıç 🌟",
                isSaniye ? 30 : 10,
                birim,
                Colors.green,
                egzersizAdi,
                isTest,
              ),
              const SizedBox(height: 12),
              _buildLevelButton(
                context,
                "Orta Seviye 🔥",
                isSaniye ? 60 : 15,
                birim,
                Colors.orange,
                egzersizAdi,
                isTest,
              ),
              const SizedBox(height: 12),
              _buildLevelButton(
                context,
                "İleri Seviye 💪",
                isSaniye ? 90 : 25,
                birim,
                Colors.redAccent,
                egzersizAdi,
                isTest,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "İptal",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLevelButton(
    BuildContext context,
    String levelName,
    int hedef,
    String birim,
    Color color,
    String egzersizAdi,
    bool isTest,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnaEkran(
                testModu: isTest,
                egzersizTipi: egzersizAdi,
                hedefTekrar: hedef,
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              levelName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "$hedef $birim",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _nasilYapilirDialog(
    BuildContext context,
    String egzersizAdi,
    bool isTest,
  ) {
    String aciklama = "";
    String videoYolu = "";

    if (egzersizAdi == "Squat") {
      aciklama =
          "1. Ayaklarınızı omuz hizasında açın.\n2. Telefonu tüm vücudunuzu görecek şekilde karşıya koyun.\n3. Sırtınızı dik tutarak dizleriniz 90° olana kadar çömelin ve kalkın.";
      videoYolu = "assets/videos/squat.mp4";
    } else if (egzersizAdi == "Lunge") {
      aciklama =
          "1. Telefonu sizi yandan (profil) görecek şekilde yerleştirin.\n2. Bir adım öne atarak dizinizi yere yaklaştırın (yaklaşık 100°).\n3. Başlangıç pozisyonuna dönün.";
      videoYolu = "assets/videos/lunge.mp4";
    } else if (egzersizAdi == "Bicep Curl") {
      aciklama =
          "1. Telefonu sizi YANDAN (profil) görecek şekilde yerleştirin.\n2. Kollarınızı vücudunuza yapıştırın.\n3. Dirseğinizi bükerek ağırlığı omuz hizanıza kaldırın ve kollarınız düzelene kadar indirin.";
      videoYolu = "assets/videos/bicep.mp4";
    } else if (egzersizAdi == "Omuz Yana Açış") {
      aciklama =
          "1. Ayakta dik durun ve kolları yanda tutun.\n2. Kollarınızı kırmadan, omuz hizasına gelene kadar (80° ve üstü) iki yana kaldırıp indirin.";
      videoYolu = "assets/videos/raise.mp4";
    } else if (egzersizAdi == "Düz Bacak Kaldırma") {
      aciklama =
          "1. Yere sırt üstü uzanın. Telefon sizi yandan görmeli.\n2. Bacağınızı dizden kırmadan dümdüz havaya kaldırın ve yavaşça indirin.";
      videoYolu = "assets/videos/leg.mp4";
    } else if (egzersizAdi == "Şınav") {
      aciklama =
          "1. Yere yüz üstü uzanıp şınav pozisyonu alın.\n2. Telefon sizi yandan görmeli.\n3. Dirsekleriniz 90° olana kadar inin ve kollarınız dümdüz olana kadar kendinizi itin.";
      videoYolu = "assets/videos/pushup.mp4";
    } else if (egzersizAdi == "Plank") {
      aciklama =
          "1. Şınav pozisyonu alın veya dirseklerinizin üzerinde durun.\n2. Sırtınızı ve kalçanızı dümdüz (180°) tutmaya çalışın.\n3. Süre boyunca pozisyonu bozmayın.";
      videoYolu = "assets/videos/plank.mp4";
    } else if (egzersizAdi == "Köprü") {
      aciklama =
          "1. Sırt üstü uzanın, dizlerinizi bükün ve ayak tabanlarınızı yere basın.\n2. Kalçanızı sıkarak gövdeniz dümdüz olana kadar (180°) yukarı kaldırın.\n3. Tepe noktasında 1 saniye bekleyip yavaşça inin.";
      videoYolu = "assets/videos/bridge.mp4";
    } else if (egzersizAdi == "Mekik") {
      aciklama =
          "1. Sırt üstü uzanıp dizlerinizi bükün.\n2. Ellerinizi başınızın arkasına veya göğsünüze koyun.\n3. Sadece omuzlarınızı ve sırtınızın üst kısmını yerden kaldırarak (110°) karın kaslarınızı sıkıştırın ve yavaşça inin.";
      videoYolu = "assets/videos/crunch.mp4";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Row(
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$egzersizAdi Nasıl Yapılır?",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: LocalVideoPlayer(videoPath: videoYolu),
                ),
                const SizedBox(height: 20),
                Text(
                  aciklama,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF2D3142),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "İptal",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                // DÜZELTME: Anladım dedikten sonra eski hantal sayaç yerine yeni ŞIK seviye ekranı açılıyor!
                _zorlukSeviyesiDialog(context, egzersizAdi, isTest);
              },
              child: const Text(
                "Anladım, Hedef Belirle",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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
        color: Colors.grey[200],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text("Video Oynatılamadı", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    if (!_initialized) {
      return const SizedBox(
        height: 220,
        width: double.infinity,
        child: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
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
