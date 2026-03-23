import 'package:camera/camera.dart';
import 'package:fizik_tedavi_asistani/painters/pose_painter.dart';
import 'package:fizik_tedavi_asistani/screens/home_screen.dart';
import 'package:fizik_tedavi_asistani/screens/result_screen.dart';
import 'package:fizik_tedavi_asistani/views/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:collection';
import 'dart:math' as math;
import 'package:hive/hive.dart';

class AnaEkran extends StatefulWidget {
  final bool testModu;
  final String egzersizTipi;
  final int hedefTekrar;

  const AnaEkran({
    Key? key,
    this.testModu = false,
    required this.egzersizTipi,
    required this.hedefTekrar,
  }) : super(key: key);

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  bool _egzersizBitti = false;

  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(),
  );
  final FlutterTts _flutterTts = FlutterTts();
  CustomPaint? _customPaint;
  bool _isBusy = false;

  int _sayac = 0;
  int _hataSayaci = 0;
  List<double> _aciVerileri = [];
  String _durum = "BEKLENİYOR";
  bool _hedefeUlasti = false;

  final Queue<double> _aciGecmisi = Queue<double>();
  final int _yumusatmaMiktari = 6;
  DateTime _sonUyariZamani = DateTime.now();

  double _gecenSureSaniye = 0;
  DateTime _sonZaman = DateTime.now();

  @override
  void initState() {
    super.initState();
    _konusmaAyarlari();
  }

  void _konusmaAyarlari() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      var isTrSupported = await _flutterTts.isLanguageAvailable("tr-TR");
      if (isTrSupported) {
        await _flutterTts.setLanguage("tr-TR");
      } else {
        await _flutterTts.setLanguage("en-US");
      }
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak("${widget.egzersizTipi} antrenmanı başlıyor");
    } catch (e) {
      print("Ses Motoru Başlatılamadı: $e");
    }
  }

  @override
  void dispose() {
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraView(
            customPaint: _customPaint,
            onImage: (inputImage, direction) {
              _processImage(inputImage, direction);
            },
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _egzersiziBitir,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text("Egzersizi Bitir"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processImage(
    InputImage inputImage,
    CameraLensDirection direction,
  ) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final pose = poses.first;

        PoseLandmark? ilkNokta;
        PoseLandmark? ortaNokta;
        PoseLandmark? sonNokta;

        // --- DİNAMİK EKLEM SEÇİCİ ---
        if (widget.egzersizTipi == "Squat" || widget.egzersizTipi == "Lunge") {
          final sagKalca = pose.landmarks[PoseLandmarkType.rightHip];
          final solKalca = pose.landmarks[PoseLandmarkType.leftHip];
          bool sagDahaNet =
              (sagKalca?.likelihood ?? 0) > (solKalca?.likelihood ?? 0);
          ilkNokta = sagDahaNet ? sagKalca : solKalca;
          ortaNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightKnee]
              : pose.landmarks[PoseLandmarkType.leftKnee];
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightAnkle]
              : pose.landmarks[PoseLandmarkType.leftAnkle];
        } else if (widget.egzersizTipi == "Bicep Curl" ||
            widget.egzersizTipi == "Omuz Presi" ||
            widget.egzersizTipi == "Şınav") {
          final sagOmuz = pose.landmarks[PoseLandmarkType.rightShoulder];
          final solOmuz = pose.landmarks[PoseLandmarkType.leftShoulder];
          bool sagDahaNet =
              (sagOmuz?.likelihood ?? 0) > (solOmuz?.likelihood ?? 0);
          ilkNokta = sagDahaNet ? sagOmuz : solOmuz;
          ortaNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightElbow]
              : pose.landmarks[PoseLandmarkType.leftElbow];
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightWrist]
              : pose.landmarks[PoseLandmarkType.leftWrist];
        } else if (widget.egzersizTipi == "Omuz Yana Açış") {
          final sagOmuz = pose.landmarks[PoseLandmarkType.rightShoulder];
          final solOmuz = pose.landmarks[PoseLandmarkType.leftShoulder];
          bool sagDahaNet =
              (sagOmuz?.likelihood ?? 0) > (solOmuz?.likelihood ?? 0);
          ilkNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightHip]
              : pose.landmarks[PoseLandmarkType.leftHip]; // Kalça
          ortaNokta = sagDahaNet ? sagOmuz : solOmuz; // Omuz
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightElbow]
              : pose.landmarks[PoseLandmarkType.leftElbow]; // Dirsek
        } else if (widget.egzersizTipi == "Düz Bacak Kaldırma") {
          final sagKalca = pose.landmarks[PoseLandmarkType.rightHip];
          final solKalca = pose.landmarks[PoseLandmarkType.leftHip];
          bool sagDahaNet =
              (sagKalca?.likelihood ?? 0) > (solKalca?.likelihood ?? 0);
          ilkNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightShoulder]
              : pose.landmarks[PoseLandmarkType.leftShoulder]; // Omuz
          ortaNokta = sagDahaNet ? sagKalca : solKalca; // Kalça
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightAnkle]
              : pose.landmarks[PoseLandmarkType.leftAnkle]; // Bilek
        } else if (widget.egzersizTipi == "Plank") {
          final sagOmuz = pose.landmarks[PoseLandmarkType.rightShoulder];
          final solOmuz = pose.landmarks[PoseLandmarkType.leftShoulder];
          bool sagDahaNet =
              (sagOmuz?.likelihood ?? 0) > (solOmuz?.likelihood ?? 0);
          ilkNokta = sagDahaNet ? sagOmuz : solOmuz; // Omuz
          ortaNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightHip]
              : pose.landmarks[PoseLandmarkType.leftHip]; // Kalça
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightAnkle]
              : pose.landmarks[PoseLandmarkType.leftAnkle]; // Ayak Bileği
        } else if (widget.egzersizTipi == "Köprü" ||
            widget.egzersizTipi == "Mekik") {
          final sagOmuz = pose.landmarks[PoseLandmarkType.rightShoulder];
          final solOmuz = pose.landmarks[PoseLandmarkType.leftShoulder];
          bool sagDahaNet =
              (sagOmuz?.likelihood ?? 0) > (solOmuz?.likelihood ?? 0);

          ilkNokta = sagDahaNet ? sagOmuz : solOmuz; // Omuz
          ortaNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightHip]
              : pose.landmarks[PoseLandmarkType.leftHip]; // Kalça
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightKnee]
              : pose.landmarks[PoseLandmarkType.leftKnee]; // Diz
        }

        if (ilkNokta != null && ortaNokta != null && sonNokta != null) {
          if (ilkNokta.likelihood > 0.50 &&
              ortaNokta.likelihood > 0.50 &&
              sonNokta.likelihood > 0.50) {
            double anlikAci = hesaplaAci(ilkNokta, ortaNokta, sonNokta);

            _aciGecmisi.addLast(anlikAci);
            if (_aciGecmisi.length > _yumusatmaMiktari)
              _aciGecmisi.removeFirst();
            double ortalamaAci =
                _aciGecmisi.reduce((a, b) => a + b) / _aciGecmisi.length;
            if (_aciVerileri.length % 5 == 0) _aciVerileri.add(ortalamaAci);

            // --- 5 FARKLI EGZERSİZİN KURALLARI ---
            if (widget.egzersizTipi == "Squat") {
              if (ortalamaAci < 95) {
                _durum = "ÇÖKTÜ";
                _hedefeUlasti = true;
                if (ortalamaAci < 60) _hataVer("Dikkat, çok eğildin!");
              }
              if (ortalamaAci > 160 && _hedefeUlasti) _sayacArtir("AYAKTA");
            } else if (widget.egzersizTipi == "Lunge") {
              if (ortalamaAci < 100) {
                _durum = "LUNGE YAPTI";
                _hedefeUlasti = true;
                if (ortalamaAci < 65) _hataVer("Dizini fazla öne itme!");
              }
              if (ortalamaAci > 150 && _hedefeUlasti) _sayacArtir("AYAKTA");
            } else if (widget.egzersizTipi == "Bicep Curl") {
              if (ortalamaAci < 45) {
                _durum = "BÜKÜLDÜ";
                _hedefeUlasti = true;
              }
              if (ortalamaAci > 150 && _hedefeUlasti) _sayacArtir("KOL DÜZ");
            } else if (widget.egzersizTipi == "Omuz Yana Açış") {
              // Kol aşağıdayken açı dar (0-30), kalktığında genişler (80-90)
              if (ortalamaAci > 80) {
                _durum = "KOL YUKARIDA";
                _hedefeUlasti = true;
              }
              if (ortalamaAci < 40 && _hedefeUlasti) _sayacArtir("KOL AŞAĞIDA");
            } else if (widget.egzersizTipi == "Düz Bacak Kaldırma") {
              // Sırt üstü yatarken bacak yerde (180), kalktığında kalça açısı daralır (<130)
              if (ortalamaAci < 135) {
                _durum = "BACAK YUKARIDA";
                _hedefeUlasti = true;
              }
              if (ortalamaAci > 160 && _hedefeUlasti)
                _sayacArtir("BACAK YERDE");
            } else if (widget.egzersizTipi == "Şınav") {
              // ŞINAV KURALLARI
              if (ortalamaAci < 90) {
                // Dirsek 90 derece büküldüğünde şınav inmiş sayılır
                _durum = "AŞAĞIDA";
                _hedefeUlasti = true;
              }
              if (ortalamaAci > 160 && _hedefeUlasti) {
                // Kollar düzeldiğinde tekrar sayılır
                _sayacArtir("YUKARIDA");
              }
            } else if (widget.egzersizTipi == "Plank") {
              if (ortalamaAci >= 155) {
                // Sırt düze yakınsa (İdeal 180)
                if (_durum != "DOĞRU POZİSYON") {
                  _durum = "DOĞRU POZİSYON";
                  _sonZaman = DateTime.now(); // Kronometreyi başlat
                } else {
                  final simdi = DateTime.now();
                  _gecenSureSaniye +=
                      simdi.difference(_sonZaman).inMilliseconds / 1000.0;
                  _sayac = _gecenSureSaniye.toInt(); // Saniyeyi ekrana yansıt
                  _sonZaman = simdi;

                  if (_sayac >= widget.hedefTekrar && !_egzersizBitti) {
                    _egzersizBitti = true;
                    if (!widget.testModu)
                      _flutterTts.speak("Tebrikler, hedefe ulaştın!");
                    Future.delayed(
                      const Duration(milliseconds: 1000),
                      () => _egzersiziBitir(),
                    );
                  }
                }
              } else {
                _durum = "KALÇAYI DÜZELT";
                if (ortalamaAci < 140) _hataVer("Kalçanı çok düşürdün!");
              }
            } else if (widget.egzersizTipi == "Köprü") {
              // Yerde yatarken açı dardır (~130°). Kalça havaya kalkıp vücut düzleşince açı genişler (>160°)
              if (ortalamaAci > 160) {
                _durum = "KALÇA YUKARIDA";
                _hedefeUlasti = true;
              }
              if (ortalamaAci < 140 && _hedefeUlasti) {
                _sayacArtir("KALÇA YERDE");
              }
            } else if (widget.egzersizTipi == "Mekik") {
              // Yerde yatarken açı geniştir (>130°). Doğrulup mekik çekince açı daralır (<110°)
              if (ortalamaAci < 110) {
                _durum = "DOĞRULDU";
                _hedefeUlasti = true;
              }
              if (ortalamaAci > 130 && _hedefeUlasti) {
                _sayacArtir("SIRT YERDE");
              }
            } else {
              // Eklemler %75'ten az görünüyorsa kullanıcıyı uyar
              _durum = "VÜCUT TAM GÖRÜNMÜYOR";
            }
          } else {
            //  Yapay zeka referans noktalarını hiç bulamazsa
            _durum = "POZİSYON ARANIYOR...";
          }
        }
      } else {
        _aciGecmisi.clear();
      }

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          direction,
          _sayac,
          _durum,
          widget.egzersizTipi,
        );
        _customPaint = CustomPaint(painter: painter);
      }
    } catch (e) {
      print("İşleme Hatası: $e");
    } finally {
      _isBusy = false;
      if (mounted) setState(() {});
    }
  }

  void _sayacArtir(String yeniDurum) {
    _sayac++;
    _durum = yeniDurum;
    _hedefeUlasti = false;
    if (!widget.testModu) _flutterTts.speak("$_sayac");

    if (_sayac >= widget.hedefTekrar && !_egzersizBitti) {
      _egzersizBitti = true;
      if (!widget.testModu) _flutterTts.speak("Tebrikler, hedefe ulaştın!");
      Future.delayed(
        const Duration(milliseconds: 1000),
        () => _egzersiziBitir(),
      );
    }
  }

  void _hataVer(String mesaj) {
    final simdi = DateTime.now();
    if (simdi.difference(_sonUyariZamani).inSeconds > 3) {
      if (!widget.testModu) _flutterTts.speak(mesaj);
      _hataSayaci++;
      _sonUyariZamani = simdi;
    }
  }

  double hesaplaAci(PoseLandmark ilk, PoseLandmark orta, PoseLandmark son) {
    final double radyan =
        math.atan2(son.y - orta.y, son.x - orta.x) -
        math.atan2(ilk.y - orta.y, ilk.x - orta.x);
    double derece = radyan * 180.0 / math.pi;
    derece = derece.abs();
    if (derece > 180.0) derece = 360.0 - derece;
    return derece;
  }

  void _egzersiziBitir() async {
    _isBusy = true;
    if (_sayac > 0) {
      var kutu = Hive.box('egzersizGecmisi');
      final simdi = DateTime.now();
      final kayitAnahtari =
          "${simdi.day}-${simdi.month}-${simdi.year}-${widget.egzersizTipi}";

      Map<dynamic, dynamic> bugunkuVeri = kutu.get(
        kayitAnahtari,
        defaultValue: {'tekrar': 0, 'hata': 0},
      );
      int yeniTekrar = bugunkuVeri['tekrar'] + _sayac;
      int yeniHata = bugunkuVeri['hata'] + _hataSayaci;
      await kutu.put(kayitAnahtari, {'tekrar': yeniTekrar, 'hata': yeniHata});
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          totalReps: _sayac,
          totalErrors: _hataSayaci,
          aciVerileri: _aciVerileri,
          egzersizTipi: widget.egzersizTipi,
        ),
      ),
    );
  }
}
