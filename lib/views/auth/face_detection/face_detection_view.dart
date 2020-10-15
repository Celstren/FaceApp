import 'dart:io';

import 'package:FaceApp/navigation/navigation_controller.dart';
import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:FaceApp/views/auth/face_detection/logic/detector_painters.dart';
import 'package:FaceApp/views/auth/face_detection/logic/methods.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FaceDetectionView extends StatefulWidget {
  @override
  _FaceDetectionViewState createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView> with WidgetsBindingObserver {
  dynamic _scanResults;
  CameraController _camera;

  Detector _currentDetector = Detector.face;
  bool _isDetecting = false, _isProcessingPhoto = false, _isToggling = false;
  CameraLensDirection _direction = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    print("Cerrar camara");
    _camera?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_camera == null || !_camera.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _camera?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_camera != null) {
        onNewCameraSelected(_camera.description);
      }
    }
  }

  Future<void> _initializeCamera() async {
    //Aqui obtengo la camara
    CameraDescription description = await getCamera(_direction);
    if (description != null) {
      ImageRotation rotation =
          rotationIntToImageRotation(description.sensorOrientation);

      // Aqui defino el controlador de la camara que voy a usar
      _camera = CameraController(
        description,
        defaultTargetPlatform == TargetPlatform.iOS
            ? ResolutionPreset.low
            : ResolutionPreset.medium,
      );
      await _camera.initialize();

      _camera.startImageStream((CameraImage image) {
        if (_isDetecting) return;

        _isDetecting = true;

        detect(image, _getDetectionMethod(), rotation).then(
          (dynamic result) {
            setState(() {
              _scanResults = result;
            });

            _isDetecting = false;
          },
        ).catchError(
          (_) {
            _isDetecting = false;
          },
        );
      });
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_camera != null) {
      await _camera.dispose();
    }
    _camera = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );

    // If the controller is updated then update the UI.
    _camera.addListener(() {
      if (mounted) setState(() {});
      if (_camera.value.hasError) {
        print('Camera error ${_camera.value.errorDescription}');
      }
    });

    try {
      await _camera.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  HandleDetection _getDetectionMethod() {
    final FirebaseVision mlVision = FirebaseVision.instance;

    switch (_currentDetector) {
      case Detector.text:
        return mlVision.textRecognizer().processImage;
      case Detector.barcode:
        return mlVision.barcodeDetector().detectInImage;
      // case Detector.label:
      //   return mlVision.labelDetector().detectInImage;
      // case Detector.cloudLabel:
      //   return mlVision.cloudLabelDetector().detectInImage;
      default:
        assert(_currentDetector == Detector.face);
        return mlVision.faceDetector().processImage;
    }
  }

  Widget _buildResults() {
    const Text noResultsText = const Text('No results!');

    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }

    CustomPainter painter;

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );

    switch (_currentDetector) {
      case Detector.barcode:
        if (_scanResults is! List<Barcode>) return noResultsText;
        painter = BarcodeDetectorPainter(imageSize, _scanResults);
        break;
      case Detector.face:
        if (_scanResults is! List<Face>) return noResultsText;
        // processFaceDetected();
        // painter = FaceDetectorPainter(imageSize, _scanResults, context);
        if (_scanResults.isNotEmpty && _scanResults.first is Face) {
          processPhoto();
        }
        break;
      // case Detector.label:
      //   if (_scanResults is! List<Label>) return noResultsText;
      //   painter = LabelDetectorPainter(imageSize, _scanResults);
      //   break;
      // case Detector.cloudLabel:
      //   if (_scanResults is! List<Label>) return noResultsText;
      //   painter = LabelDetectorPainter(imageSize, _scanResults);
      //   break;
      default:
        assert(_currentDetector == Detector.text);
        if (_scanResults is! VisionText) return noResultsText;
        painter = TextDetectorPainter(imageSize, _scanResults);
    }

    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(
              child: Text(
                'Iniciando cámara...',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                _buildResults(),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (!_isToggling) {
      _isToggling = true;
      if (_direction == CameraLensDirection.back) {
        _direction = CameraLensDirection.front;
      } else {
        _direction = CameraLensDirection.back;
      }

      await _camera.stopImageStream();
      await _camera.dispose();

      setState(() {
        _camera = null;
      });

      await _initializeCamera();
      _isToggling = false;
    }
  }

  void processPhoto() async {
    try {
      if (!_isProcessingPhoto) {
        _isProcessingPhoto = true;
        await _camera.stopImageStream();
        String path = await takePicture();
        NavigationController.navigation = NavigationTabs(NavTab.FaceComparison, params: path);
      }
    } catch (e) {
      print("No se pudo tomar una foto\nError: $e");
    }
  }

  Future<String> takePicture() async {
    if (!_camera.value.isInitialized) {
      print('Error: Falta seleccionar una cámara');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (_camera.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await _camera.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCameraDirection,
        child: _isToggling
            ? CircularProgressIndicator()
            : _direction == CameraLensDirection.back
                ? const Icon(Icons.camera_front)
                : const Icon(Icons.camera_rear),
      ),
    );
  }
}
