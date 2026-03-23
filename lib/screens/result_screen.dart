import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    int basariPuani = 100 - (totalErrors * 15);
    if (basariPuani < 0) basariPuani = 0;
    if (totalReps == 0) basariPuani = 0;

    Color basariRengi = basariPuani >= 80
        ? Colors.green
        : (basariPuani >= 50 ? Colors.orange : Colors.red);

    // --- DİNAMİK GRAFİK KURALLARI ---
    String grafikBasligi = "Eklem Açısı Analizi";
    List<HorizontalLine> referansCizgileri = [];

    if (egzersizTipi == "Squat") {
      grafikBasligi = "Diz Açısı Analizi";
      referansCizgileri = [
        HorizontalLine(
          y: 90,
          color: Colors.green.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "İdeal (90°)",
            style: const TextStyle(color: Colors.green),
          ),
        ),
        HorizontalLine(
          y: 60,
          color: Colors.red.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "Hata (60°)",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ];
    } else if (egzersizTipi == "Lunge") {
      grafikBasligi = "Diz Açısı Analizi";
      referansCizgileri = [
        HorizontalLine(
          y: 100,
          color: Colors.green.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "İdeal (~100°)",
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ];
    } else if (egzersizTipi == "Bicep Curl") {
      grafikBasligi = "Dirsek Açısı Analizi";
      referansCizgileri = [
        HorizontalLine(
          y: 45,
          color: Colors.green.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "Bükülme (45°)",
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ];
    } else if (egzersizTipi == "Omuz Yana Açış") {
      grafikBasligi = "Omuz Açısı Analizi";
      referansCizgileri = [
        HorizontalLine(
          y: 80,
          color: Colors.green.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "Kaldırma (>80°)",
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ];
    } else if (egzersizTipi == "Düz Bacak Kaldırma") {
      grafikBasligi = "Kalça Açısı Analizi";
      referansCizgileri = [
        HorizontalLine(
          y: 135,
          color: Colors.green.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "Kaldırma (<135°)",
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ];
    } else if (egzersizTipi == "Şınav") {
      grafikBasligi = "Dirsek Açısı Analizi (Şınav)";
      referansCizgileri = [
        HorizontalLine(
          y: 90,
          color: Colors.green.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "İdeal İniş (90°)",
            style: const TextStyle(color: Colors.green),
          ),
        ),
        HorizontalLine(
          y: 160,
          color: Colors.blue.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "Tam Kalkış (160°)",
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ];
    } else if (egzersizTipi == "Plank") {
      grafikBasligi = "Omurga Düzlüğü Analizi (Plank)";
      referansCizgileri = [
        HorizontalLine(
          y: 180,
          color: Colors.green.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "İdeal Düzlük (180°)",
            style: const TextStyle(color: Colors.green),
          ),
        ),
        HorizontalLine(
          y: 150,
          color: Colors.red.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "Hata / Düşme (<150°)",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ];
    } else if (egzersizTipi == "Köprü") {
      grafikBasligi = "Kalça Açısı Analizi (Köprü)";
      referansCizgileri = [
        HorizontalLine(
          y: 160,
          color: Colors.green.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "Tam Kalkış (>160°)",
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ];
    } else if (egzersizTipi == "Mekik") {
      grafikBasligi = "Gövde Açısı Analizi (Mekik)";
      referansCizgileri = [
        HorizontalLine(
          y: 110,
          color: Colors.green.withOpacity(0.8),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (_) => "Doğrulma (<110°)",
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "$egzersizTipi Raporu",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3142),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // BAŞARI ORANI DAİRESİ
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
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
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: basariPuani / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey[200],
                            color: basariRengi,
                          ),
                        ),
                        Text(
                          "%$basariPuani",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: basariRengi,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Performans",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          basariPuani >= 80
                              ? "Mükemmel Form! 🔥"
                              : (basariPuani >= 50
                                    ? "Biraz Daha Çaba 💪"
                                    : "Formunu Düzelt ⚠️"),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ÖZET KARTLARI
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "Tekrar",
                      "$totalReps",
                      Colors.blueAccent,
                      Icons.repeat,
                    ),
                  ),
                  Expanded(
                    child: _statCard(
                      egzersizTipi == "Plank" ? "Süre (sn)" : "Tekrar",
                      "$totalReps",
                      Colors.blueAccent,
                      egzersizTipi == "Plank" ? Icons.timer : Icons.repeat,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _statCard(
                      "Hata",
                      "$totalErrors",
                      Colors.redAccent,
                      Icons.warning_amber_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // GRAFİK ALANI
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  grafikBasligi,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    right: 20,
                    top: 20,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: aciVerileri.isEmpty
                      ? const Center(child: Text("Yeterli veri yok"))
                      : LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey[200],
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minY: 30,
                            maxY: 180,
                            lineBarsData: [
                              LineChartBarData(
                                spots: aciVerileri
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => FlSpot(e.key.toDouble(), e.value),
                                    )
                                    .toList(),
                                isCurved: true,
                                color: Colors.blueAccent,
                                barWidth: 4,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blueAccent.withOpacity(0.1),
                                ),
                              ),
                            ],
                            // DİNAMİK KLİNİK ÇİZGİLER
                            extraLinesData: ExtraLinesData(
                              horizontalLines: referansCizgileri,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                  child: const Text(
                    "Yeni Egzersiz Başlat",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
