import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Geçmiş Antrenmanlar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3142),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            onPressed: () {
              if (Hive.box('egzersizGecmisi').isNotEmpty) {
                _gecmisiTemizleDialog(context);
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('egzersizGecmisi').listenable(),
        builder: (context, Box kutu, _) {
          if (kutu.isEmpty) {
            return const Center(
              child: Text(
                "Henüz kaydedilmiş bir antrenman yok.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Verileri Tarihlere Göre Gruplama Sözlüğü
          Map<String, List<Map<String, dynamic>>> grupluVeriler = {};

          for (var key in kutu.keys) {
            String keyStr = key.toString();
            List<String> parcalar = keyStr.split('-');

            if (parcalar.length >= 4) {
              String tarih = "${parcalar[0]}-${parcalar[1]}-${parcalar[2]}";
              String egzersiz = parcalar.sublist(3).join('-');

              var veri = kutu.get(key);
              if (veri != null && veri['tekrar'] != null) {
                if (!grupluVeriler.containsKey(tarih)) {
                  grupluVeriler[tarih] = [];
                }
                grupluVeriler[tarih]!.add({
                  'egzersiz': egzersiz,
                  'tekrar': veri['tekrar'],
                  'hata': veri['hata'],
                });
              }
            }
          }

          if (grupluVeriler.isEmpty) {
            return const Center(child: Text("Gösterilecek veri bulunamadı."));
          }

          // Tarihleri Yeniden Eskiye Göre Sıralama
          List<String> siraliTarihler = grupluVeriler.keys.toList();
          siraliTarihler.sort((a, b) {
            List<String> aParca = a.split('-');
            List<String> bParca = b.split('-');
            DateTime aDate = DateTime(
              int.parse(aParca[2]),
              int.parse(aParca[1]),
              int.parse(aParca[0]),
            );
            DateTime bDate = DateTime(
              int.parse(bParca[2]),
              int.parse(bParca[1]),
              int.parse(bParca[0]),
            );
            return bDate.compareTo(aDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: siraliTarihler.length,
            itemBuilder: (context, index) {
              String tarih = siraliTarihler[index];
              List<Map<String, dynamic>> oGunkuHareketler =
                  grupluVeriler[tarih]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 3,
                shadowColor: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            tarih,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 30,
                        thickness: 1,
                        color: Color(0xFFE2E8F0),
                      ),
                      ...oGunkuHareketler.map((hareket) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "• ${hareket['egzersiz']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${hareket['tekrar']} ${hareket['egzersiz'] == 'Plank' ? 'Saniye' : 'Tekrar'} (${hareket['hata']} Hata)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

  //  GEÇMİŞİ TEMİZLEME PENCERESİ
  void _gecmisiTemizleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Geçmişi Sil",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          content: const Text(
            "Tüm antrenman geçmişin kalıcı olarak silinecek. Emin misin?",
          ),
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
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
