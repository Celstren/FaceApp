import 'dart:io';

import 'package:FaceApp/navigation/navigation_controller.dart';
import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:FaceApp/services/auth/authentication_repository.dart';
import 'package:FaceApp/utils/exports/app_design.dart';
import 'package:FaceApp/utils/general/constant_helper.dart';
import 'package:FaceApp/utils/widgets/custom_dialog.dart';
import 'package:FaceApp/utils/widgets/two_options_dialog.dart';
import 'package:FaceApp/views/auth/face_detection/logic/detector_painters.dart';
import 'package:FaceApp/views/auth/face_detection/logic/methods.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FaceDetectionView extends StatefulWidget {
  final String dni;
  const FaceDetectionView({Key key, this.dni = ""}) : super(key: key);

  @override
  _FaceDetectionViewState createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView>
    with WidgetsBindingObserver {
  dynamic _scanResults;
  CameraController _camera;

  Detector _currentDetector = Detector.face;
  bool _isDetecting = false, _isProcessingPhoto = false, _isToggling = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  Rect scannerRect, scannerCenterRect;
  double minFaceWidth = 0, minFaceHeight = 0;
  bool sizesInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
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

  void _initSizes() {
    if (!sizesInitialized) {
      final double globalWidth = MediaQuery.of(context).size.width;
      final double globalHeight = MediaQuery.of(context).size.height;
      scannerRect = Rect.fromLTRB(
        globalWidth * .15,
        globalHeight * .2,
        globalWidth * .85,
        globalHeight * .8,
      );
      scannerCenterRect = Rect.fromCenter(
        center: scannerRect.center,
        width: MediaQuery.of(context).size.width * .1,
        height: MediaQuery.of(context).size.height * .1,
      );
      minFaceWidth = MediaQuery.of(context).size.width *
          ConstantHelper.MinFaceWidthPercentage;
      minFaceHeight = MediaQuery.of(context).size.height *
          ConstantHelper.MinFaceHeightPercentage;
      sizesInitialized = true;
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
        _isProcessingPhoto = false;

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
        if (_scanResults.isNotEmpty && scannerCenterRect != null) {
          Face faceDetected = _scanResults.firstWhere((element) {
            if (element is! Face) return false;
            Rect faceRect = scaleRect(
                rect: element.boundingBox,
                imageSize: imageSize,
                widgetSize: MediaQuery.of(context).size);
            bool isInCenter = scannerCenterRect.contains(faceRect.center);
            bool validWidth = faceRect.size.width >= minFaceWidth;
            bool validHeight = faceRect.size.height >= minFaceHeight;
            return isInCenter && validWidth && validHeight;
          }, orElse: () => null);
          if (faceDetected != null) {
            processPhoto();
          }
        }
        break;
      default:
        assert(_currentDetector == Detector.text);
        if (_scanResults is! VisionText) return noResultsText;
        painter = TextDetectorPainter(imageSize, _scanResults);
    }

    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildScannerArea() {
    if (scannerRect == null) return Container();
    return CustomPaint(
      painter: RectPainter(MediaQuery.of(context).size, scannerRect),
    );
  }

  Widget _buildContent() {
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
                _buildScannerArea(),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .1,
                    left: MediaQuery.of(context).size.width * .2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: FlatButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            NavigationController.navigation =
                                NavigationTabs(NavTab.LoginDni);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 50,
                            color: AppColors.PrimaryWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * .1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Por favor enfoque su cara",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.whiteStyle(
                          fontFamily: AppFonts.Montserrat_Bold,
                          fontSize: AppFontSizes.title18,
                        ),
                      ),
                    ],
                  ),
                ),
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
        File photo = File(path);
        bool success = await AuthenticationRepository.verifyFace(photo,
            subjectId: widget.dni, galleryName: ConstantHelper.FacialGallery);
        if (success) {
          await Future.delayed(Duration(seconds: 1));
          NavigationController.navigation = NavigationTabs(NavTab.Home);
        } else {
          showCustomDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return CustomDialog(
                  child: TwoOptionsDialog(
                    title: "Fallo autenticación facial",
                    leftOptionText: "Cancelar",
                    onLeftPress: () async {
                      Navigator.pop(context);
                      await Future.delayed(Duration(seconds: 1));
                      NavigationController.navigation =
                          NavigationTabs(NavTab.LoginDni);
                    },
                    rightOptionText: "Reintentar",
                    onRightPress: () async {
                      await _camera.dispose();
                      setState(() {
                        _camera = null;
                      });
                      await _initializeCamera();
                      Navigator.pop(context);
                    },
                  ),
                );
              });
        }
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
    final String filePath =
        '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

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
    _initSizes();
    return WillPopScope(
        child: Scaffold(
          body: _buildContent(),
          floatingActionButton: FloatingActionButton(
            onPressed: _toggleCameraDirection,
            child: _isToggling
                ? CircularProgressIndicator()
                : _direction == CameraLensDirection.back
                    ? const Icon(Icons.camera_front)
                    : const Icon(Icons.camera_rear),
          ),
        ),
        onWillPop: () async {
          NavigationController.navigation = NavigationTabs(NavTab.LoginDni);
          return false;
        });
  }
}
