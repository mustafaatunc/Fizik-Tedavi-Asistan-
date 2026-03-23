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
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;
    final paintRed = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.red;

    // --- SAYAÇ VE DURUM KUTUSU ---
    final paintKutu = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(20, 40, 160, 100), paintKutu);

    String gosterilecekMetin = (egzersizTipi == "Plank")
        ? '$tekrarSayisi sn'
        : '$tekrarSayisi';

    final textPainterSayac = TextPainter(
      text: TextSpan(
        text: gosterilecekMetin,
        style: const TextStyle(
          fontSize: 60,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterSayac.paint(canvas, const Offset(80, 50));

    final textPainterDurum = TextPainter(
      text: TextSpan(
        text: durum,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterDurum.paint(canvas, const Offset(40, 110));

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
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
          1,
          paint,
        );
      });

      PoseLandmark? ilkNokta;
      PoseLandmark? ortaNokta;
      PoseLandmark? sonNokta;

      // --- DİNAMİK ÇİZİM MOTORU ---
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
      } else if (egzersizTipi == "Bicep Curl") {
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
      }

      if (ilkNokta != null && ortaNokta != null && sonNokta != null) {
        double aci = hesaplaAci(ilkNokta, ortaNokta, sonNokta);

        bool aciTehlikeliMi = (egzersizTipi == "Bicep Curl")
            ? false
            : (aci < 90);

        final textSpan = TextSpan(
          text: '${aci.toStringAsFixed(0)}°',
          style: TextStyle(
            color: aciTehlikeliMi ? Colors.red : Colors.green,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black54,
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
        textPainter.paint(canvas, Offset(x, y));

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
          aciTehlikeliMi ? paintRed : paint,
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
          aciTehlikeliMi ? paintRed : paint,
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
