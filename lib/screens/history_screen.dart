import 'package:fizik_tedavi_asistani/utils/workout_calculator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
// YENİ: Merkezi Motor Eklendi

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  final List<String> _aylar = const [
    "",
    "Oca",
    "Şub",
    "Mar",
    "Nis",
    "May",
    "Haz",
    "Tem",
    "Ağu",
    "Eyl",
    "Eki",
    "Kas",
    "Ara",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          "AI Antrenman Hafızası",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Color(0xFF1E2022),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            onPressed: () => _gecmisiTemizleDialog(context),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('egzersizGecmisi').listenable(),
        builder: (context, Box kutu, _) {
          if (kutu.isEmpty) return _buildEmptyState();

          Map<String, List<Map<String, dynamic>>> grupluVeriler = {};

          // Kariyer İstatistikleri
          int toplamKariyerTekrar = 0;
          double toplamKariyerKalori = 0;
          int toplamKariyerSaniye = 0;

          for (var key in kutu.keys) {
            String keyStr = key.toString();
            List<String> parcalar = keyStr.split('-');
            if (parcalar.length >= 4) {
              String tarih = "${parcalar[0]}-${parcalar[1]}-${parcalar[2]}";
              String egzersiz = parcalar.sublist(3).join('-');
              var veri = kutu.get(key);

              if (veri != null && veri['tekrar'] != null) {
                int tekrar = veri['tekrar'] as int;
                int hata = veri['hata'] as int;

                toplamKariyerTekrar += tekrar;

                // DRY KURALI: Artık hesaplamayı Merkezi Motordan alıyoruz!
                var analiz = WorkoutCalculator.hesaplaKaloriVeSure(
                  egzersiz,
                  tekrar,
                );
                toplamKariyerKalori += analiz['kalori']!;
                toplamKariyerSaniye += analiz['sure']!.toInt();

                if (!grupluVeriler.containsKey(tarih))
                  grupluVeriler[tarih] = [];
                grupluVeriler[tarih]!.add({
                  'egzersiz': egzersiz,
                  'tekrar': tekrar,
                  'hata': hata,
                  'kalori': analiz['kalori'],
                });
              }
            }
          }

          List<String> siraliTarihler = grupluVeriler.keys.toList()
            ..sort((a, b) {
              var aP = a.split('-');
              var bP = b.split('-');
              return DateTime(
                int.parse(bP[2]),
                int.parse(bP[1]),
                int.parse(bP[0]),
              ).compareTo(
                DateTime(int.parse(aP[2]), int.parse(aP[1]), int.parse(aP[0])),
              );
            });

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCareerInsightCard(
                        toplamKariyerTekrar,
                        toplamKariyerKalori,
                        (toplamKariyerSaniye / 60).floor(),
                      ),
                      const SizedBox(height: 35),
                      const Text(
                        "Haftalık Antrenman Hacmi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2022),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildWeeklyBarChart(kutu),
                      const SizedBox(height: 35),
                      const Text(
                        "Günlük Raporlar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2022),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildDailyActivityCard(
                      context,
                      siraliTarihler[index],
                      grupluVeriler[siraliTarihler[index]]!,
                    );
                  }, childCount: siraliTarihler.length),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCareerInsightCard(
    int toplamTekrar,
    double toplamKalori,
    int toplamDakika,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
              const SizedBox(width: 15),
              const Text(
                "AI Kariyer Özeti",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKariyerStatItem(
                Icons.fitness_center_rounded,
                "Hacim",
                "$toplamTekrar",
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildKariyerStatItem(
                Icons.local_fire_department_rounded,
                "Yakılan",
                "${toplamKalori.toInt()} kcal",
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildKariyerStatItem(
                Icons.timer_rounded,
                "Süre",
                "${toplamDakika} Dk",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKariyerStatItem(IconData icon, String baslik, String deger) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 8),
        Text(
          deger,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          baslik,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyActivityCard(
    BuildContext context,
    String tarih,
    List<Map<String, dynamic>> hareketler,
  ) {
    List<String> tarihParcalari = tarih.split('-');
    String gun = tarihParcalari[0];
    String ay = _aylar[int.parse(tarihParcalari[1])];

    double gunlukKalori = hareketler.fold(
      0.0,
      (sum, h) => sum + (h['kalori'] as double),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(15),
        iconColor: const Color(0xFF4A00E0),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FA),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                gun,
                style: const TextStyle(
                  color: Color(0xFF1E2022),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                ay,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          "${hareketler.length} Egzersiz Tamamlandı",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E2022),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "${gunlukKalori.toInt()} kcal",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 15),
              const Icon(
                Icons.fitness_center_rounded,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "${hareketler.fold(0, (sum, h) => sum + (h['tekrar'] as int))} Tekrar",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        children: hareketler.map((h) => _buildDetailItem(h)).toList(),
      ),
    );
  }

  Widget _buildDetailItem(Map<String, dynamic> hareket) {
    int tekrar = hareket['tekrar'];
    int hata = hareket['hata'];
    int basari = tekrar == 0 ? 0 : ((tekrar / (tekrar + hata)) * 100).toInt();

    Color aiColor = basari >= 85
        ? Colors.green
        : (basari < 60 ? Colors.redAccent : Colors.orange);
    String aiTag = basari >= 85
        ? "Kusursuz"
        : (basari < 60 ? "Form Kritik" : "Gelişim");

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: aiColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt_rounded, color: aiColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hareket['egzersiz'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF1E2022),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$tekrar Tekrar / Süre",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "%$basari Başarı",
                style: TextStyle(
                  color: aiColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                aiTag,
                style: TextStyle(
                  color: aiColor.withOpacity(0.7),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
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
            Icons.history_rounded,
            size: 100,
            color: const Color(0xFF4A00E0).withOpacity(0.15),
          ),
          const SizedBox(height: 25),
          const Text(
            "Temiz Bir Sayfa",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E2022),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Henüz antrenman verisi bulunmuyor.\nKataloğa dön ve ilk hareketini yap!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(Box kutu) {
    List<int> haftalikHacim = List.filled(7, 0);
    DateTime bugun = DateTime.now();
    int maxHacim = 0;

    for (int i = 0; i < 7; i++) {
      DateTime gun = bugun.subtract(Duration(days: 6 - i));
      String tarihStr = "${gun.day}-${gun.month}-${gun.year}";
      int gunlukToplam = 0;
      for (var key in kutu.keys) {
        if (key.toString().startsWith(tarihStr)) {
          var veri = kutu.get(key);
          if (veri != null && veri['tekrar'] != null)
            gunlukToplam += (veri['tekrar'] as int);
        }
      }
      haftalikHacim[i] = gunlukToplam;
      if (gunlukToplam > maxHacim) maxHacim = gunlukToplam;
    }
    if (maxHacim == 0) maxHacim = 50;

    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 25, bottom: 15, left: 20, right: 20),
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
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxHacim.toDouble() * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E2022).withOpacity(0.9),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "${rod.toY.toInt()} Tekrar\n",
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  DateTime gun = bugun.subtract(
                    Duration(days: 6 - value.toInt()),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      [
                        "Pzt",
                        "Sal",
                        "Çar",
                        "Per",
                        "Cum",
                        "Cmt",
                        "Paz",
                      ][gun.weekday - 1],
                      style: TextStyle(
                        color: value.toInt() == 6
                            ? const Color(0xFF4A00E0)
                            : Colors.grey.shade600,
                        fontWeight: value.toInt() == 6
                            ? FontWeight.w900
                            : FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            bool isToday = index == 6;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: haftalikHacim[index].toDouble(),
                  color: isToday
                      ? const Color(0xFF4A00E0)
                      : const Color(0xFF4A00E0).withOpacity(0.2),
                  width: 24,
                  borderRadius: BorderRadius.circular(8),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxHacim.toDouble() * 1.2,
                    color: Colors.grey.withOpacity(0.05),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _gecmisiTemizleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          contentPadding: const EdgeInsets.all(30),
          titlePadding: const EdgeInsets.only(top: 30),
          title: const Column(
            children: [
              Icon(Icons.warning_rounded, color: Colors.redAccent, size: 60),
              SizedBox(height: 20),
              Text(
                "Geçmişi Sil",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E2022),
                  fontSize: 24,
                ),
              ),
            ],
          ),
          content: const Text(
            "Tüm antrenman geçmişin ve kazandığın AI analizleri kalıcı olarak silinecek. Emin misin?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.only(
            bottom: 30,
            left: 20,
            right: 20,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Vazgeç",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 5,
                shadowColor: Colors.redAccent.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                Hive.box('egzersizGecmisi').clear();
                Navigator.pop(context);
              },
              child: const Text(
                "Evet, Sil",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
