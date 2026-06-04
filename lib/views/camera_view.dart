import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CameraView extends StatefulWidget {
  final Function(InputImage inputImage, CameraLensDirection direction) onImage;
  final CustomPaint? customPaint;

  const CameraView({Key? key, required this.onImage, this.customPaint})
    : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? _controller;
  int _cameraIndex = -1;
  List<CameraDescription> _cameras = [];
  bool _isChangingCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  void _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    if (_cameraIndex == -1) _cameraIndex = 0;

    _startCamera();
  }

  void _startCamera() async {
    if (_cameras.isEmpty) return;
    final camera = _cameras[_cameraIndex];

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller?.initialize();
      if (!mounted) return;
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    } catch (e) {
      debugPrint("Kamera hatası: $e");
    }
  }

  void _switchCamera() async {
    if (_isChangingCamera || _cameras.isEmpty) return;
    _isChangingCamera = true;

    final oldController = _controller;
    _controller = null;
    setState(() {});

    try {
      // HATA ÇÖZÜMÜ: Eski kamerayı kapatırken güvenlik kontrolleri
      if (oldController != null && oldController.value.isInitialized) {
        if (oldController.value.isStreamingImages) {
          await oldController.stopImageStream();
        }
        await oldController.dispose();
      }

      await Future.delayed(const Duration(milliseconds: 300));
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      _startCamera();
    } catch (e) {
      debugPrint("Geçiş Hatası: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _isChangingCamera = false;
    }
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage != null && _controller != null) {
      widget.onImage(inputImage, _controller!.description.lensDirection);
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    } else if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == null) return null;
    if (Platform.isAndroid &&
        format != InputImageFormat.nv21 &&
        format != InputImageFormat.yuv_420_888) {
      return null;
    }

    if (image.planes.isEmpty) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  // YENİ: UYGULAMA ARKA PLANA ATILDIĞINDA VEYA GERİ GELDİĞİNDE ÇALIŞIR
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // Kamera henüz hazır değilse hiçbir şey yapma
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Uygulama arka plana atıldı (Telefon çaldı vs.) -> Kamerayı serbest bırak
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Kullanıcı uygulamaya geri döndü -> Kamerayı tekrar başlat
      _startCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_controller != null && _controller!.value.isInitialized) {
      if (_controller!.value.isStreamingImages) {
        _controller!.stopImageStream();
      }
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F2027),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.4),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: Color(0xFF00E5FF),
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                "Yapay Zeka Başlatılıyor...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Lütfen telefonunuzu sabitleyin",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (widget.customPaint != null) widget.customPaint!,
          Positioned(
            top: 60,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(12),
                    icon: Icon(
                      Platform.isIOS
                          ? Icons.flip_camera_ios_rounded
                          : Icons.flip_camera_android_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _switchCamera,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
