import 'package:fizik_tedavi_asistani/utils/workout_calculator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ResultScreen extends StatefulWidget {
  final int totalReps;
  final int totalErrors;
  final List<double> aciVerileri;
  final String egzersizTipi;

  const ResultScreen({
    Key? key,
    required this.totalReps,
    required this.totalErrors,
    required this.aciVerileri,
    required this.egzersizTipi,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _yeniRozetKontrolu(context);
      });
      _isInit = false;
    }
  }

  void _guvenliCikisYap() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    int basariYuzdesi = widget.totalReps == 0
        ? 0
        : ((widget.totalReps / (widget.totalReps + widget.totalErrors)) * 100)
              .toInt();
    int gorselPuan = 100 - (widget.totalErrors * 15);
    if (gorselPuan < 0) gorselPuan = 0;
    if (widget.totalReps == 0) gorselPuan = 0;

    Color basariRengi = basariYuzdesi >= 85
        ? Colors.greenAccent
        : (basariYuzdesi >= 60 ? Colors.orangeAccent : Colors.redAccent);
    String grafikBasligi = "${widget.egzersizTipi} Analizi";
    String birim = widget.egzersizTipi == "Plank" ? "Saniye" : "Tekrar";

    var metrikler = WorkoutCalculator.hesaplaKaloriVeSure(
      widget.egzersizTipi,
      widget.totalReps,
    );
    int kalori = metrikler["kalori"]!.toInt();
    int dakika = (metrikler["sure"]! / 60).ceil();
    if (dakika == 0 && widget.totalReps > 0) dakika = 1;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _guvenliCikisYap();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          title: Text(
            "${widget.egzersizTipi} Raporu",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: const Color(0xFF1E2022),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _guvenliCikisYap,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFFF4F6FA),
                    child: Column(
                      children: [
                        _buildScoreCard(gorselPuan, basariRengi),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                birim,
                                "${widget.totalReps}",
                                const Color(0xFF4A00E0),
                                widget.egzersizTipi == "Plank"
                                    ? Icons.timer_rounded
                                    : Icons.repeat_rounded,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _statCard(
                                "Hata",
                                "${widget.totalErrors}",
                                Colors.redAccent,
                                Icons.warning_amber_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                "Yakılan",
                                "$kalori kcal",
                                Colors.orange,
                                Icons.local_fire_department_rounded,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _statCard(
                                "Aktif Süre",
                                "$dakika Dk",
                                Colors.teal,
                                Icons.directions_run_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            grafikBasligi,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E2022),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildGrafikAlani(),
                        const SizedBox(height: 35),
                        _buildAIOnerisi(context, basariYuzdesi),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: TextButton(
                      onPressed: _guvenliCikisYap,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Ana Ekrana Dön",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E2022),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrafikAlani() {
    List<HorizontalLine> referansCizgileri = [];
    if (widget.egzersizTipi == "Squat" || widget.egzersizTipi == "Lunge") {
      referansCizgileri = [
        HorizontalLine(
          y: 90,
          color: Colors.green.withOpacity(0.6),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => "İdeal Çöküş",
          ),
        ),
        HorizontalLine(
          y: 60,
          color: Colors.red.withOpacity(0.6),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => "Tehlike (Aşırı Açı)",
          ),
        ),
      ];
    } else if (widget.egzersizTipi == "Plank") {
      referansCizgileri = [
        HorizontalLine(
          y: 170,
          color: Colors.green.withOpacity(0.6),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => "Düz Omurga",
          ),
        ),
        HorizontalLine(
          y: 140,
          color: Colors.red.withOpacity(0.6),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => "Kalça Düştü",
          ),
        ),
      ];
    } else if (widget.egzersizTipi == "Şınav") {
      referansCizgileri = [
        HorizontalLine(
          y: 90,
          color: Colors.green.withOpacity(0.6),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => "İdeal İniş",
          ),
        ),
        HorizontalLine(
          y: 50,
          color: Colors.red.withOpacity(0.6),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => "Ekleme Yük Bindirme",
          ),
        ),
      ];
    }

    return SizedBox(
      height: 250,
      child: Container(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 10,
          right: 20,
          left: 10,
        ),
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
        child: widget.aciVerileri.length < 2
            ? const Center(
                child: Text(
                  "Grafik çizimi için yeterli veri toplanamadı.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 200,
                  minX: 0,
                  maxX: (widget.aciVerileri.length - 1).toDouble(),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          const Color(0xFF1E2022).withOpacity(0.9),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          String durumText = "Hareket";
                          Color durumColor = Colors.orangeAccent;
                          if (widget.egzersizTipi == "Squat" ||
                              widget.egzersizTipi == "Lunge") {
                            if (spot.y < 60) {
                              durumText = "Fazla Çöktün!";
                              durumColor = Colors.redAccent;
                            } else if (spot.y < 95) {
                              durumText = "Kusursuz!";
                              durumColor = Colors.greenAccent;
                            }
                          } else if (widget.egzersizTipi == "Plank") {
                            if (spot.y < 150) {
                              durumText = "Bozuldu!";
                              durumColor = Colors.redAccent;
                            } else if (spot.y > 165) {
                              durumText = "Stabil!";
                              durumColor = Colors.greenAccent;
                            }
                          } else if (widget.egzersizTipi == "Şınav") {
                            if (spot.y < 50) {
                              durumText = "Çok İndin!";
                              durumColor = Colors.redAccent;
                            } else if (spot.y < 95) {
                              durumText = "Tam Form!";
                              durumColor = Colors.greenAccent;
                            }
                          }
                          return LineTooltipItem(
                            "${spot.y.toInt()}°\n",
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                            children: [
                              TextSpan(
                                text: durumText,
                                style: TextStyle(
                                  color: durumColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == 200 || value % 45 != 0)
                            return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              "${value.toInt()}°",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 45,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: referansCizgileri,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: widget.aciVerileri
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: const Color(0xFF4A00E0),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF4A00E0).withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAIOnerisi(BuildContext context, int basariYuzdesi) {
    String oneriEgzersiz = "Plank";
    String oneriMesaji = "";
    IconData oneriIcon = Icons.timer_rounded;
    Color oneriRenk = const Color(0xFF00E5FF);
    String rozetMetni = "Yapay Zeka Analizi";

    if (basariYuzdesi < 60) {
      oneriEgzersiz = "Köprü";
      oneriMesaji =
          "Hareket formun bozulmaya başlamış ve yorulmuşsun. Sakatlanmamak için kaslarını esnetecek Köprü hareketine geçmeni veya dinlenmeni öneririm.";
      oneriIcon = Icons.airline_seat_recline_normal_rounded;
      oneriRenk = const Color(0xFFFF416C);
      rozetMetni = "Kurtarma Modu (Recovery)";
    } else if (basariYuzdesi >= 85) {
      rozetMetni = "Maksimum Verim";
      oneriRenk = Colors.greenAccent;

      // ALT VÜCUT KONTROLÜ
      if (widget.egzersizTipi == "Squat" ||
          widget.egzersizTipi == "Lunge" ||
          widget.egzersizTipi == "High Knees" ||
          widget.egzersizTipi == "Düz Bacak Kaldırma") {
        oneriEgzersiz = widget.egzersizTipi == "Squat" ? "Lunge" : "Squat";
        oneriMesaji =
            "Muhteşem form! Alt vücut kasların tam olarak ateşlenmiş durumda. Nabzını düşürmeden hemen $oneriEgzersiz hareketine geç.";
        oneriIcon = Icons.directions_walk_rounded;
      }
      // ÜST VÜCUT KONTROLÜ
      else if (widget.egzersizTipi == "Şınav" ||
          widget.egzersizTipi == "Bicep Curl" ||
          widget.egzersizTipi == "Omuz Yana Açış" ||
          widget.egzersizTipi == "Front Raise" ||
          widget.egzersizTipi == "Jumping Jack") {
        oneriEgzersiz = widget.egzersizTipi == "Şınav" ? "Bicep Curl" : "Şınav";
        oneriMesaji =
            "Üst vücut koordinasyonun kusursuz. Kaslarını tükenişe götürmek ve gelişimi maksimuma çıkarmak için $oneriEgzersiz ile devam et!";
        oneriIcon = Icons.sports_gymnastics_rounded;
      }
      // CORE (KARIN) KONTROLÜ
      else {
        oneriEgzersiz = widget.egzersizTipi == "Plank" ? "Mekik" : "Plank";
        oneriMesaji =
            "Merkez bölgeni (Core) harika sıktın. Şimdi bunu $oneriEgzersiz ile bitirici bir seriye dönüştür.";
        oneriIcon = Icons.sports_martial_arts_rounded;
      }
    } else {
      oneriEgzersiz = "Plank";
      oneriMesaji =
          "İyi bir iş çıkardın ancak formunda ufak sapmalar var. Merkez bölgeni (Core) güçlendirmek ileride daha stabil hareket etmeni sağlar.";
      oneriIcon = Icons.timer_rounded;
      oneriRenk = const Color(0xFFFF8008);
      rozetMetni = "Denge Önerisi";
    }

    return Container(
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
            color: oneriRenk.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: oneriRenk.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: oneriRenk, size: 22),
              const SizedBox(width: 8),
              Text(
                rozetMetni,
                style: TextStyle(
                  color: oneriRenk,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            oneriMesaji,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: oneriRenk.withOpacity(0.15),
                foregroundColor: oneriRenk,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: oneriRenk.withOpacity(0.5), width: 2),
                ),
              ),
              onPressed: () {
                _guvenliCikisYap();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(oneriIcon, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    "$oneriEgzersiz Egzersizine Geç",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int puan, Color renk) {
    return Container(
      padding: const EdgeInsets.all(25),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: puan / 100,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  color: renk,
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
              Text(
                "%$puan",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: renk,
                ),
              ),
            ],
          ),
          const Text(
            "Performans\nSkoru",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E2022),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _yeniRozetKontrolu(BuildContext context) {
    var profilKutusu = Hive.box('userProfile');
    if (widget.totalReps >= 1 &&
        !profilKutusu.get('rozet_ilk_adim', defaultValue: false)) {
      _rozetDialogGoster(
        context,
        "İlk Adım 🌟",
        "Muhteşem bir başlangıç! İlk antrenmanını başarıyla tamamladın.",
      );
      profilKutusu.put('rozet_ilk_adim', true);
    }
  }

  void _rozetDialogGoster(BuildContext context, String rozetAdi, String mesaj) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1C29), Color(0xFF2A2D3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8008).withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFFF8008).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "✨ YENİ BAŞARIM KİLİDİ AÇILDI! ✨",
                  style: TextStyle(
                    color: Color(0xFFFF8008),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8008).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFF8008),
                    size: 80,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  rozetAdi,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  mesaj,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8008),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Koleksiyonuma Ekle",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
