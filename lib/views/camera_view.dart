import 'dart:io';
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

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  int _cameraIndex = -1;
  List<CameraDescription> _cameras = [];
  bool _isChangingCamera = false;

  @override
  void initState() {
    super.initState();
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
      print("Kamera hatası: $e");
    }
  }

  void _switchCamera() async {
    if (_isChangingCamera || _cameras.isEmpty) return;
    _isChangingCamera = true;

    final oldController = _controller;
    _controller = null;
    setState(() {});

    try {
      if (oldController != null) {
        if (oldController.value.isStreamingImages) {
          await oldController.stopImageStream();
        }
        await oldController.dispose();
      }
      await Future.delayed(const Duration(milliseconds: 300));
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      _startCamera();
    } catch (e) {
      print("Geçiş Hatası: $e");
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

    // Gelen ham formatı tanımla
    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    // Format tanınmıyorsa, uygulamayı çökertmek yerine kareyi yoksay (skip frame)
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

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (widget.customPaint != null) widget.customPaint!,
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: Icon(
                  Platform.isIOS
                      ? Icons.flip_camera_ios
                      : Icons.flip_camera_android,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: _switchCamera,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
