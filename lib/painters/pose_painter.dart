import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../utils/coordinates_translator.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final int tekrarSayisi;
  final String durum;
  final String egzersizTipi;

  // --- OPTİMİZASYON (60 FPS İÇİN): FIRÇALAR ÖNBELLEĞE ALINDI ---
  static final Paint _paintNeonBlue = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6.0
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF00E5FF)
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5);

  static final Paint _paintNeonRed = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6.0
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFFFF004D)
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5);

  static final Paint _paintJoint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white
    ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

  PosePainter(
    this.poses,
    this.absoluteImageSize,
    this.rotation,
    this.cameraLensDirection,
    this.tekrarSayisi,
    this.durum,
    this.egzersizTipi,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // --- SİNEMATİK HUD BİLGİ EKRANI ---
    String gosterilecekMetin = (egzersizTipi == "Plank")
        ? '$tekrarSayisi sn'
        : '$tekrarSayisi';

    // Dev Sayaç
    final textPainterSayac = TextPainter(
      text: TextSpan(
        text: gosterilecekMetin,
        style: const TextStyle(
          fontSize: 75,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
            Shadow(color: Color(0xFF00E5FF), blurRadius: 25),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainterSayac.paint(
      canvas,
      Offset((size.width - textPainterSayac.width) / 2, 80),
    );

    // Durum Bildirimi
    final textPainterDurum = TextPainter(
      text: TextSpan(
        text: durum,
        style: const TextStyle(
          fontSize: 22,
          color: Color(0xFFFF8008),
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          shadows: [Shadow(color: Colors.black, blurRadius: 15)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainterDurum.paint(
      canvas,
      Offset((size.width - textPainterDurum.width) / 2, 160),
    );

    // --- İSKELET VE EKLEMLERİ ÇİZME ---
    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        if (landmark.likelihood > 0.6) {
          canvas.drawCircle(
            Offset(
              translateX(
                landmark.x,
                size,
                absoluteImageSize,
                rotation,
                cameraLensDirection,
              ),
              translateY(
                landmark.y,
                size,
                absoluteImageSize,
                rotation,
                cameraLensDirection,
              ),
            ),
            4.0,
            _paintJoint,
          );
        }
      });

      PoseLandmark? ilkNokta;
      PoseLandmark? ortaNokta;
      PoseLandmark? sonNokta;

      if (egzersizTipi == "Squat" || egzersizTipi == "Lunge") {
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
      } else if (egzersizTipi == "Bicep Curl" || egzersizTipi == "Şınav") {
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
      } else if (egzersizTipi == "Omuz Yana Açış" ||
          egzersizTipi == "Front Raise" ||
          egzersizTipi == "Jumping Jack") {
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
      } else if (egzersizTipi == "High Knees") {
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
      } else if (egzersizTipi == "Düz Bacak Kaldırma") {
        // --- YENİ DİNAMİK UZUV TAKİBİ (Sadece kalkan bacağı çiz) ---
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

          // Hangi bacak daha çok kalkmışsa (açısı daha darsa) o bacağı ÇİZ
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
      } else if (egzersizTipi == "Plank") {
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
      } else if (egzersizTipi == "Köprü" || egzersizTipi == "Mekik") {
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

      if (ilkNokta != null && ortaNokta != null && sonNokta != null) {
        double aci = hesaplaAci(ilkNokta, ortaNokta, sonNokta);
        bool aciTehlikeliMi = false;

        if (egzersizTipi == "Squat")
          aciTehlikeliMi = (aci < 60);
        else if (egzersizTipi == "Lunge")
          aciTehlikeliMi = (aci < 65);
        else if (egzersizTipi == "Bicep Curl")
          aciTehlikeliMi = (aci < 35);
        else if (egzersizTipi == "Omuz Yana Açış")
          aciTehlikeliMi = (aci > 110);
        else if (egzersizTipi == "Front Raise")
          aciTehlikeliMi = (aci > 120);
        else if (egzersizTipi == "Düz Bacak Kaldırma")
          aciTehlikeliMi = (aci < 90);
        else if (egzersizTipi == "Şınav")
          aciTehlikeliMi = (aci < 50);
        else if (egzersizTipi == "Plank")
          aciTehlikeliMi = (aci < 155);
        else if (egzersizTipi == "Köprü")
          aciTehlikeliMi = (aci > 175);
        else if (egzersizTipi == "Mekik")
          aciTehlikeliMi = (aci < 60);

        final textSpan = TextSpan(
          text: '${aci.toStringAsFixed(0)}°',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: aciTehlikeliMi
                    ? const Color(0xFFFF004D)
                    : const Color(0xFF00E5FF),
                blurRadius: 15,
              ),
            ],
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        final double x = translateX(
          ortaNokta.x,
          size,
          absoluteImageSize,
          rotation,
          cameraLensDirection,
        );
        final double y = translateY(
          ortaNokta.y,
          size,
          absoluteImageSize,
          rotation,
          cameraLensDirection,
        );

        textPainter.paint(canvas, Offset(x + 15, y - 15));

        canvas.drawLine(
          Offset(
            translateX(
              ilkNokta.x,
              size,
              absoluteImageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              ilkNokta.y,
              size,
              absoluteImageSize,
              rotation,
              cameraLensDirection,
            ),
          ),
          Offset(x, y),
          aciTehlikeliMi ? _paintNeonRed : _paintNeonBlue,
        );

        canvas.drawLine(
          Offset(x, y),
          Offset(
            translateX(
              sonNokta.x,
              size,
              absoluteImageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              sonNokta.y,
              size,
              absoluteImageSize,
              rotation,
              cameraLensDirection,
            ),
          ),
          aciTehlikeliMi ? _paintNeonRed : _paintNeonBlue,
        );
      }
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

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) => true;
}
