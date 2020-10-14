import 'package:FaceApp/navigation/navigation_controller.dart';
import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:FaceApp/views/auth/face_detection/logic/detector_painters.dart';
import 'package:FaceApp/views/auth/face_detection/logic/methods.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FaceDetectionView extends StatefulWidget {
  @override
  _FaceDetectionViewState createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView> {
  dynamic _scanResults;
  CameraController _camera;

  Detector _currentDetector = Detector.face;
  bool _isDetecting = false, _isProcessingPhoto = false, _isToggling = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  CameraImage _cameraImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    print("Cerrar camara");
    _camera?.dispose();
    super.dispose();
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
        _cameraImage = image;

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
          takePhoto();
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

  void takePhoto() async {
    try {
      if (!_isProcessingPhoto && _cameraImage != null) {
        print("========================================================== Process photo ==========================================================");
        _isProcessingPhoto = true;
        await _camera.stopImageStream();
        var bytes = await convertImagetoPng(_cameraImage);
        print("========================================================== Foto tomada ==========================================================");
        NavigationController.navigation = NavigationTabs(NavTab.FaceComparison, params: bytes);
      }
    } catch (e) {
      print("No se pudo tomar una foto\nError: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection View'),
        actions: <Widget>[
          PopupMenuButton<Detector>(
            onSelected: (Detector result) {
              _currentDetector = result;
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
              const PopupMenuItem<Detector>(
                child: Text('Detect Barcode'),
                value: Detector.barcode,
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Face'),
                value: Detector.face,
              ),
              // const PopupMenuItem<Detector>(
              //   child: Text('Detect Label'),
              //   value: Detector.label,
              // ),
              // const PopupMenuItem<Detector>(
              //   child: Text('Detect Cloud Label'),
              //   value: Detector.cloudLabel,
              // ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Text'),
                value: Detector.text,
              ),
            ],
          ),
        ],
      ),
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
