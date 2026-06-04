import 'package:camera/camera.dart';
import 'package:fizik_tedavi_asistani/painters/pose_painter.dart';
import 'package:fizik_tedavi_asistani/screens/result_screen.dart';
import 'package:fizik_tedavi_asistani/views/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:collection';
import 'dart:math' as math;
import 'package:hive/hive.dart';
import 'dart:async';
import 'dart:ui';

class AnaEkran extends StatefulWidget {
  final bool testModu;
  final String? egzersizTipi;
  final int? hedefTekrar;
  final List<Map<String, dynamic>>? zincirlemeProgram;

  const AnaEkran({
    Key? key,
    this.testModu = false,
    this.egzersizTipi,
    this.hedefTekrar,
    this.zincirlemeProgram,
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

  int _egzersizIndeksi = 0;
  late String _aktifEgzersiz;
  late int _aktifHedef;
  bool _isTransitioning = false;

  int _sayac = 0;
  int _hataSayaci = 0;
  int _kareSayaci = 0;
  List<double> _aciVerileri = [];
  String _durum = "BEKLENİYOR";
  bool _hedefeUlasti = false;

  int _mevcutSet = 1;
  int _toplamSet = 1; // 1 SET OLARAK AYARLANDI
  bool _isResting = false;
  int _restTime = 30;
  Timer? _restTimer;
  int _toplamYapilanTekrar = 0;
  int _toplamHataSayaci = 0;

  final Queue<double> _aciGecmisi = Queue<double>();
  final int _yumusatmaMiktari = 6;
  DateTime _sonUyariZamani = DateTime.now();

  double _gecenSureSaniye = 0;
  DateTime _sonZaman = DateTime.now();

  @override
  void initState() {
    super.initState();
    _motorAyarlariniYap();
  }

  void _motorAyarlariniYap() {
    if (widget.zincirlemeProgram != null &&
        widget.zincirlemeProgram!.isNotEmpty) {
      _aktifEgzersiz = widget.zincirlemeProgram![0]['egzersiz'];
      _aktifHedef = widget.zincirlemeProgram![0]['hedef'];
      _toplamSet = 1;
    } else {
      _aktifEgzersiz = widget.egzersizTipi ?? "Squat";
      _aktifHedef = widget.hedefTekrar ?? 10;
      _toplamSet = 1;
    }
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
      if (!widget.testModu) {
        await _flutterTts.speak(
          "$_aktifEgzersiz antrenmanı başlıyor. Lütfen pozisyon al.",
        );
      }
    } catch (e) {
      debugPrint("Ses Motoru Başlatılamadı: $e");
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _poseDetector.close();
    super.dispose();
  }

  void _cikisOnayiIste() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              "Antrenmanı İptal Et?",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          "Eğer şimdi çıkarsan bu seansta yaptığın hareketler kaydedilmeyecek. Çıkmak istediğine emin misin?",
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Vazgeç, Devam Et",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "Evet, Çık",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _cikisOnayiIste();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
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
              top: 60,
              left: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.zincirlemeProgram != null
                              ? Icons.route_rounded
                              : Icons.layers_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.zincirlemeProgram != null
                              ? "Aşama: ${_egzersizIndeksi + 1} / ${widget.zincirlemeProgram!.length}"
                              : "Set: $_mevcutSet / $_toplamSet",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isResting)
              Positioned.fill(
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: _isTransitioning
                                    ? const Color(0xFF00E5FF).withOpacity(0.2)
                                    : Colors.blueAccent.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _isTransitioning
                                        ? const Color(
                                            0xFF00E5FF,
                                          ).withOpacity(0.5)
                                        : Colors.blueAccent.withOpacity(0.5),
                                    blurRadius: 50,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isTransitioning
                                    ? Icons.double_arrow_rounded
                                    : Icons.timer_outlined,
                                color: Colors.white,
                                size: 70,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              _isTransitioning
                                  ? "SIRADAKİ: $_aktifEgzersiz"
                                  : "DİNLENME ZAMANI",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$_restTime",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 90,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: 200,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.15,
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: const BorderSide(
                                      color: Colors.white30,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onPressed: _nextSetOrExercise,
                                child: const Text(
                                  "Hemen Başla",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _egzersiziBitir,
                      icon: const Icon(Icons.check_circle_rounded, size: 28),
                      label: const Text("Erken Bitir & Kaydet"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(
    InputImage inputImage,
    CameraLensDirection direction,
  ) async {
    if (_isBusy || _isResting) return;
    _isBusy = true;

    try {
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final pose = poses.first;
        PoseLandmark? ilkNokta, ortaNokta, sonNokta;

        // --- İSKELET NOKTALARI EŞLEŞTİRMESİ ---
        if (_aktifEgzersiz == "Squat" || _aktifEgzersiz == "Lunge") {
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
        } else if (_aktifEgzersiz == "Bicep Curl" ||
            _aktifEgzersiz == "Şınav") {
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
        } else if (_aktifEgzersiz == "Omuz Yana Açış" ||
            _aktifEgzersiz == "Front Raise" ||
            _aktifEgzersiz == "Jumping Jack") {
          final sagOmuz = pose.landmarks[PoseLandmarkType.rightShoulder];
          final solOmuz = pose.landmarks[PoseLandmarkType.leftShoulder];
          bool sagDahaNet =
              (sagOmuz?.likelihood ?? 0) > (solOmuz?.likelihood ?? 0);
          ilkNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightHip]
              : pose.landmarks[PoseLandmarkType.leftHip];
          ortaNokta = sagDahaNet ? sagOmuz : solOmuz;
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightWrist]
              : pose.landmarks[PoseLandmarkType.leftWrist];
        } else if (_aktifEgzersiz == "Düz Bacak Kaldırma") {
          // --- YENİ MANTIK: DİNAMİK UZUV TAKİBİ EKLENDİ ---
          final sagOmuz = pose.landmarks[PoseLandmarkType.rightShoulder];
          final sagKalca = pose.landmarks[PoseLandmarkType.rightHip];
          final sagBilek = pose.landmarks[PoseLandmarkType.rightAnkle];

          final solOmuz = pose.landmarks[PoseLandmarkType.leftShoulder];
          final solKalca = pose.landmarks[PoseLandmarkType.leftHip];
          final solBilek = pose.landmarks[PoseLandmarkType.leftAnkle];

          if (sagOmuz != null &&
              sagKalca != null &&
              sagBilek != null &&
              solOmuz != null &&
              solKalca != null &&
              solBilek != null) {
            double sagAci = hesaplaAci(sagOmuz, sagKalca, sagBilek);
            double solAci = hesaplaAci(solOmuz, solKalca, solBilek);

            // Hangi bacak daha çok kalkmışsa (açısı darsa) onu takip et
            if (sagAci < solAci) {
              ilkNokta = sagOmuz;
              ortaNokta = sagKalca;
              sonNokta = sagBilek;
            } else {
              ilkNokta = solOmuz;
              ortaNokta = solKalca;
              sonNokta = solBilek;
            }
          }
        } else if (_aktifEgzersiz == "High Knees") {
          final sagKalca = pose.landmarks[PoseLandmarkType.rightHip];
          final solKalca = pose.landmarks[PoseLandmarkType.leftHip];
          bool sagDahaNet =
              (sagKalca?.likelihood ?? 0) > (solKalca?.likelihood ?? 0);
          ilkNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightShoulder]
              : pose.landmarks[PoseLandmarkType.leftShoulder];
          ortaNokta = sagDahaNet ? sagKalca : solKalca;
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightKnee]
              : pose.landmarks[PoseLandmarkType.leftKnee];
        } else if (_aktifEgzersiz == "Plank") {
          final sagOmuz = pose.landmarks[PoseLandmarkType.rightShoulder];
          final solOmuz = pose.landmarks[PoseLandmarkType.leftShoulder];
          bool sagDahaNet =
              (sagOmuz?.likelihood ?? 0) > (solOmuz?.likelihood ?? 0);
          ilkNokta = sagDahaNet ? sagOmuz : solOmuz;
          ortaNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightHip]
              : pose.landmarks[PoseLandmarkType.leftHip];
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightAnkle]
              : pose.landmarks[PoseLandmarkType.leftAnkle];
        } else if (_aktifEgzersiz == "Köprü" || _aktifEgzersiz == "Mekik") {
          final sagOmuz = pose.landmarks[PoseLandmarkType.rightShoulder];
          final solOmuz = pose.landmarks[PoseLandmarkType.leftShoulder];
          bool sagDahaNet =
              (sagOmuz?.likelihood ?? 0) > (solOmuz?.likelihood ?? 0);
          ilkNokta = sagDahaNet ? sagOmuz : solOmuz;
          ortaNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightHip]
              : pose.landmarks[PoseLandmarkType.leftHip];
          sonNokta = sagDahaNet
              ? pose.landmarks[PoseLandmarkType.rightKnee]
              : pose.landmarks[PoseLandmarkType.leftKnee];
        }

        // --- TOLERANSLI AÇI HESAPLAMALARI ---
        if (ilkNokta != null && ortaNokta != null && sonNokta != null) {
          if (ilkNokta.likelihood > 0.60 &&
              ortaNokta.likelihood > 0.60 &&
              sonNokta.likelihood > 0.60) {
            double anlikAci = hesaplaAci(ilkNokta, ortaNokta, sonNokta);

            _aciGecmisi.addLast(anlikAci);
            if (_aciGecmisi.length > _yumusatmaMiktari) {
              _aciGecmisi.removeFirst();
            }
            double ortalamaAci =
                _aciGecmisi.reduce((a, b) => a + b) / _aciGecmisi.length;

            _kareSayaci++;
            if (_kareSayaci % 5 == 0) {
              _aciVerileri.add(ortalamaAci);
            }

            if (_aktifEgzersiz == "Squat") {
              if (ortalamaAci < 100) {
                _durum = "ÇÖKTÜ";
                _hedefeUlasti = true;
                if (ortalamaAci < 60) _hataVer("Dikkat, çok eğildin!");
              }
              if (ortalamaAci > 150 && _hedefeUlasti) _sayacArtir("AYAKTA");
            } else if (_aktifEgzersiz == "Lunge") {
              if (ortalamaAci < 100) {
                _durum = "LUNGE YAPTI";
                _hedefeUlasti = true;
                if (ortalamaAci < 65)
                  _hataVer("Dizini yere çok yaklaştırdın, dengeni koru!");
              }
              if (ortalamaAci > 150 && _hedefeUlasti) _sayacArtir("AYAKTA");
            } else if (_aktifEgzersiz == "Bicep Curl") {
              if (ortalamaAci < 75) {
                _durum = "KOL BÜKÜLÜ";
                _hedefeUlasti = true;
                if (ortalamaAci < 35)
                  _hataVer("Ağırlığı omzuna çok çarptırıyorsun!");
              }
              if (ortalamaAci > 135 && _hedefeUlasti) _sayacArtir("KOL DÜZ");
            } else if (_aktifEgzersiz == "Şınav") {
              if (ortalamaAci < 100) {
                _durum = "AŞAĞIDA";
                _hedefeUlasti = true;
                if (ortalamaAci < 50) _hataVer("Çok derine indin!");
              }
              if (ortalamaAci > 145 && _hedefeUlasti) _sayacArtir("YUKARIDA");
            } else if (_aktifEgzersiz == "Omuz Yana Açış") {
              if (ortalamaAci > 75) {
                _durum = "KOL YUKARIDA";
                _hedefeUlasti = true;
                if (ortalamaAci > 110)
                  _hataVer("Kollarını omuz hizasından yukarı kaldırma!");
              }
              if (ortalamaAci < 45 && _hedefeUlasti) _sayacArtir("KOL AŞAĞIDA");
            } else if (_aktifEgzersiz == "Düz Bacak Kaldırma") {
              // YENİ TOLERANS
              if (ortalamaAci < 145) {
                _durum = "BACAK YUKARIDA";
                _hedefeUlasti = true;
                if (ortalamaAci < 90)
                  _hataVer("Bacağını çok diktin, belini yerden kesme!");
              }
              if (ortalamaAci > 155 && _hedefeUlasti)
                _sayacArtir("BACAK YERDE");
            } else if (_aktifEgzersiz == "Jumping Jack") {
              // YENİ TOLERANS
              if (ortalamaAci > 105) {
                _durum = "KOLLAR YUKARIDA";
                _hedefeUlasti = true;
              }
              if (ortalamaAci < 85 && _hedefeUlasti) _sayacArtir("AŞAĞIDA");
            } else if (_aktifEgzersiz == "High Knees") {
              // YENİ TOLERANS
              if (ortalamaAci < 135) {
                _durum = "DİZ YUKARIDA";
                _hedefeUlasti = true;
              }
              if (ortalamaAci > 145 && _hedefeUlasti)
                _sayacArtir("DİZ AŞAĞIDA");
            } else if (_aktifEgzersiz == "Front Raise") {
              if (ortalamaAci > 70) {
                _durum = "KOL ÖNDE";
                _hedefeUlasti = true;
                if (ortalamaAci > 120) _hataVer("Kollarını çok kaldırma!");
              }
              if (ortalamaAci < 40 && _hedefeUlasti) _sayacArtir("KOL AŞAĞIDA");
            } else if (_aktifEgzersiz == "Plank") {
              if (ortalamaAci >= 150) {
                if (_durum != "DOĞRU POZİSYON") {
                  _durum = "DOĞRU POZİSYON";
                  _sonZaman = DateTime.now();
                } else {
                  final simdi = DateTime.now();
                  _gecenSureSaniye +=
                      simdi.difference(_sonZaman).inMilliseconds / 1000.0;
                  _sayac = _gecenSureSaniye.toInt();
                  _sonZaman = simdi;

                  if (!widget.testModu) {
                    if (_sayac == (_aktifHedef / 2).floor() && _sayac > 0) {
                      _flutterTts.speak(
                        "Sürenin yarısı bitti, harika gidiyorsun!",
                      );
                    } else if (_aktifHedef - _sayac == 5) {
                      _flutterTts.speak("Son 5 saniye, dayan!");
                    }
                  }

                  if (_sayac >= _aktifHedef && !_egzersizBitti) {
                    _egzersizBitti = true;
                    HapticFeedback.vibrate();
                    if (!widget.testModu)
                      _flutterTts.speak("Süre doldu, harika!");
                    Future.delayed(
                      const Duration(milliseconds: 1000),
                      () => _zincirlemeVeyaSetKontrol(),
                    );
                  }
                }
              } else {
                _durum = "POZİSYONU DÜZELT";
                _hataVer("Kalçanı hizada tut!");
              }
            } else if (_aktifEgzersiz == "Köprü") {
              if (ortalamaAci > 155) {
                // Kalça yeterince yukarıda
                _durum = "KALÇA YUKARIDA";
                _hedefeUlasti = true;
                if (ortalamaAci > 175)
                  _hataVer("Belini çok yukarı ittin, aşırı kavis yapma!");
              }
              if (ortalamaAci < 145 && _hedefeUlasti) {
                // Kalça yere indi
                _sayacArtir("KALÇA YERDE");
              }
            } else if (_aktifEgzersiz == "Mekik") {
              if (ortalamaAci < 115) {
                _durum = "DOĞRULDU";
                _hedefeUlasti = true;
                if (ortalamaAci < 60) _hataVer("Boynuna çok asılıyorsun!");
              }
              if (ortalamaAci > 130 && _hedefeUlasti) _sayacArtir("SIRT YERDE");
            } else {
              _durum = "VÜCUT TAM GÖRÜNMÜYOR";
            }
          } else {
            _durum = "POZİSYON ARANIYOR...";
          }
        }
      } else {
        _aciGecmisi.clear();
        _durum = "KADRAJA GİRİN";
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
          _aktifEgzersiz,
        );
        _customPaint = CustomPaint(painter: painter);
      }
    } catch (e) {
      debugPrint("İşleme Hatası: $e");
    } finally {
      _isBusy = false;
      if (mounted) setState(() {});
    }
  }

  void _sayacArtir(String yeniDurum) {
    _sayac++;
    _toplamYapilanTekrar++;
    _durum = yeniDurum;
    _hedefeUlasti = false;
    HapticFeedback.lightImpact();

    if (!widget.testModu) {
      _flutterTts.speak("$_sayac");
      if (_sayac == (_aktifHedef / 2).floor()) {
        Future.delayed(
          const Duration(milliseconds: 800),
          () => _flutterTts.speak("Yarıladın, tempoyu koru!"),
        );
      } else if (_aktifHedef - _sayac == 3) {
        Future.delayed(
          const Duration(milliseconds: 800),
          () => _flutterTts.speak("Son 3 tekrar, dayan!"),
        );
      }
    }

    if (_sayac >= _aktifHedef && !_egzersizBitti) {
      _zincirlemeVeyaSetKontrol();
    }
  }

  void _zincirlemeVeyaSetKontrol() {
    _egzersizBitti = true;
    _toplamHataSayaci += _hataSayaci;
    _aktifEgzersiziKaydet();

    if (widget.zincirlemeProgram != null) {
      if (_egzersizIndeksi < widget.zincirlemeProgram!.length - 1) {
        _egzersizIndeksi++;
        _startTransitionResting();
      } else {
        if (!widget.testModu)
          _flutterTts.speak("Tüm programı başarıyla tamamladın!");
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => _egzersiziBitirVeGec(),
        );
      }
    } else {
      if (_mevcutSet < _toplamSet) {
        _startResting();
      } else {
        if (!widget.testModu) _flutterTts.speak("Antrenman bitti, harikasın!");
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => _egzersiziBitirVeGec(),
        );
      }
    }
  }

  String _getAITip(String egzersiz) {
    switch (egzersiz) {
      case "Squat":
        return "Bir sonraki sette topuklarından güç al ve göğsünü dik tut.";
      case "Lunge":
        return "Adım atarken dizinin ayak parmak ucunu geçmemesine dikkat et.";
      case "Şınav":
        return "Dirseklerini dışa değil, vücuduna 45 derece açıyla geriye bük.";
      case "Plank":
        return "Kalçanı çok düşürme, karın kaslarını sımsıkı tut.";
      case "Bicep Curl":
        return "Ağırlığı kaldırırken dirseklerini oynatma, sadece kolların çalışsın.";
      case "Omuz Yana Açış":
        return "Ağırlığı omuz hizandan daha yukarı kaldırmamaya çalış.";
      case "Düz Bacak Kaldırma":
        return "Bacağını indirirken belini yerden kaldırma.";
      case "Köprü":
        return "Kalçanı yukarı ittiğinde üst noktada 1 saniye sıkıştırıp bekle.";
      case "Mekik":
        return "Boynundan çekme, hareketi tamamen karın kaslarınla yap.";
      case "Jumping Jack":
        return "Zıplarken dizlerini hafif bükerek eklemlerini koru.";
      case "High Knees":
        return "Dizlerini göğsüne olabildiğince çek, tempoyu düşürme.";
      case "Front Raise":
        return "Ağırlığı kaldırırken belinden güç alma, gövdeni sabit tut.";
      default:
        return "Nefes alışverişini hareketin zor kısmında vermeye odaklan.";
    }
  }

  void _startResting() {
    int hesaplananDinlenme = 30;
    String sesliMesaj = "Set bitti. Lütfen dinlen.";

    if (_hataSayaci == 0) {
      hesaplananDinlenme = 15;
      sesliMesaj =
          "Kusursuz form! Nabzını yüksek tutmak için molanı 15 saniyeye düşürüyorum.";
    } else if (_hataSayaci >= 3) {
      hesaplananDinlenme = 45;
      String tip = _getAITip(_aktifEgzersiz);
      sesliMesaj = "Biraz zorlandın. $tip Toparlanman için 45 saniye dinlen.";
    }

    setState(() {
      _isResting = true;
      _isTransitioning = false;
      _restTime = hesaplananDinlenme;
      _durum = "DİNLENME MODU";
    });

    if (!widget.testModu) _flutterTts.speak(sesliMesaj);

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTime > 0) {
        setState(() => _restTime--);
      } else {
        timer.cancel();
        _nextSetOrExercise();
      }
    });
  }

  void _startTransitionResting() {
    int hesaplananDinlenme = 15;
    String sesliMesaj =
        "Sıradaki hareket ${widget.zincirlemeProgram![_egzersizIndeksi]['egzersiz']}. Hazırlan!";

    if (_hataSayaci >= 3) {
      hesaplananDinlenme = 30;
      sesliMesaj =
          "Zorlandığını görüyorum. 30 saniye dinlen ve ${widget.zincirlemeProgram![_egzersizIndeksi]['egzersiz']} pozisyonu al.";
    }

    setState(() {
      _aktifEgzersiz = widget.zincirlemeProgram![_egzersizIndeksi]['egzersiz'];
      _aktifHedef = widget.zincirlemeProgram![_egzersizIndeksi]['hedef'];
      _isResting = true;
      _isTransitioning = true;
      _restTime = hesaplananDinlenme;
      _durum = "SIRADAKİ: $_aktifEgzersiz";
    });

    if (!widget.testModu) _flutterTts.speak(sesliMesaj);

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTime > 0) {
        setState(() => _restTime--);
      } else {
        timer.cancel();
        _nextSetOrExercise();
      }
    });
  }

  void _nextSetOrExercise() {
    _restTimer?.cancel();
    setState(() {
      _sayac = 0;
      _gecenSureSaniye = 0;
      _egzersizBitti = false;
      _isResting = false;
      _isTransitioning = false;
      _durum = "BEKLENİYOR";
      _hedefeUlasti = false;
      _hataSayaci = 0;

      _aciGecmisi.clear();

      if (widget.zincirlemeProgram == null) {
        _mevcutSet++;
      }
    });
    if (!widget.testModu && widget.zincirlemeProgram == null) {
      _flutterTts.speak("$_mevcutSet. set başlıyor. Hazırlan!");
    }
  }

  void _hataVer(String mesaj) {
    final simdi = DateTime.now();
    if (simdi.difference(_sonUyariZamani).inSeconds > 3) {
      HapticFeedback.heavyImpact();
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

  void _aktifEgzersiziKaydet() {
    if (_sayac > 0) {
      var kutu = Hive.box('egzersizGecmisi');
      final simdi = DateTime.now();
      final kayitAnahtari =
          "${simdi.day}-${simdi.month}-${simdi.year}-$_aktifEgzersiz";

      Map<dynamic, dynamic> bugunkuVeri = kutu.get(
        kayitAnahtari,
        defaultValue: {'tekrar': 0, 'hata': 0},
      );

      int yeniTekrar = bugunkuVeri['tekrar'] + _sayac;
      int yeniHata = bugunkuVeri['hata'] + _hataSayaci;

      kutu.put(kayitAnahtari, {'tekrar': yeniTekrar, 'hata': yeniHata});
    }
  }

  void _egzersiziBitir() async {
    _isBusy = true;
    _aktifEgzersiziKaydet();
    _toplamHataSayaci += _hataSayaci;
    _sayac = 0;
    _hataSayaci = 0;
    _egzersiziBitirVeGec();
  }

  void _egzersiziBitirVeGec() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          totalReps: _aktifEgzersiz == "Plank" ? _sayac : _toplamYapilanTekrar,
          totalErrors: _toplamHataSayaci,
          aciVerileri: _aciVerileri,
          egzersizTipi: _aktifEgzersiz,
        ),
      ),
    );
  }
}
