import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'squat_analiz_ekrani.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 15.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                _buildPremiumHeader(),
                const SizedBox(height: 30),

                _buildDailyScorecard(context),
                const SizedBox(height: 35),

                _buildQuickStartSection(context),
                const SizedBox(height: 35),

                // BUGÜNKÜ SEANS DETAYI
                const Text(
                  "Bugünkü Aktivite",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 15),
                _buildTodaySessionList(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hoş Geldin Mustafa, 👋",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Sağlık Olsun!",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 5),
              Text(
                "5 Gün",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyScorecard(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('egzersizGecmisi').listenable(),
      builder: (context, Box kutu, _) {
        final simdi = DateTime.now();
        final bugunTarih = "${simdi.day}-${simdi.month}-${simdi.year}";

        int toplamTekrar = 0;
        int toplamHata = 0;
        Set<String> yapilanEgzersizler = {};

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
              toplamTekrar += (veri['tekrar'] as int);
              toplamHata += (veri['hata'] as int);
              yapilanEgzersizler.add(egzersizAdi);
            }
          }
        }

        double basariOrani = toplamTekrar == 0
            ? 0
            : (toplamTekrar / (toplamTekrar + toplamHata)) * 100;
        double progressOrani = (toplamTekrar / 50.0).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              //  Dairesel İlerleme Çubuğu
              SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progressOrani,
                      strokeWidth: 12,
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blueAccent,
                      ),
                    ),
                    Center(
                      child: Text(
                        "${(progressOrani * 100).toInt()}%",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              // Stats Listesi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Günlük Hedef",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "$toplamTekrar / 50 Tekrar",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "%${basariOrani.toInt()} Başarı",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.track_changes_rounded,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${yapilanEgzersizler.length} Hareket",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),

            TextButton(
              onPressed: () {},
              child: const Text(
                "Tümünü Gör",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildQuickStartButton(
                context,
                "Squat",
                Icons.fitness_center,
                Colors.blueAccent,
                15,
              ),
              const SizedBox(width: 15),
              _buildQuickStartButton(
                context,
                "Köprü",
                Icons.airline_seat_recline_normal_rounded,
                Colors.cyan,
                12,
              ),
              const SizedBox(width: 15),
              _buildQuickStartButton(
                context,
                "Plank",
                Icons.timer_outlined,
                Colors.orange,
                30,
              ), // 30 sn
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStartButton(
    BuildContext context,
    String egzersiz,
    IconData icon,
    Color color,
    int hedef,
  ) {
    String birim = egzersiz == "Plank" ? "sn" : "tekrar";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnaEkran(
                testModu: false,
                egzersizTipi: egzersiz,
                hedefTekrar: hedef,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 15),
              Text(
                egzersiz,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$hedef $birim",
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySessionList(BuildContext context) {
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
                _buildTodayListItem(
                  context,
                  egzersizAdi,
                  veri['tekrar'],
                  veri['hata'],
                ),
              );
            }
          }
        }

        if (gunlukDetaylar.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                "Bugün henüz antrenman yapmadın.\nHızlı Başlat'tan bir hareket seç!",
                style: TextStyle(color: Colors.grey, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          return Column(children: gunlukDetaylar.reversed.toList());
        }
      },
    );
  }

  // Bugünün Liste Elemanı Tasarımı
  Widget _buildTodayListItem(
    BuildContext context,
    String egzersiz,
    int tekrar,
    int hata,
  ) {
    String birim = egzersiz == "Plank" ? "saniye" : "tekrar";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    egzersiz,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "$tekrar $birim yapıldı",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (hata > 0) ...[
                Text(
                  "$hata Hata",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
