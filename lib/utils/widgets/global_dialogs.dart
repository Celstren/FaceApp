import 'package:FaceApp/utils/widgets/custom_dialog.dart';
import 'package:FaceApp/utils/widgets/loading_screen.dart';
import 'package:FaceApp/utils/widgets/ok_dialog.dart';
import 'package:flutter/material.dart';

class GlobalDialogs {
  static GlobalDialogs _instance;
  static BuildContext _context;

  GlobalDialogs._();

  factory GlobalDialogs() => _getInstance();

  static GlobalDialogs _getInstance() {
    if (_instance == null) {
      _instance = GlobalDialogs._();
    }
    return _instance;
  }

  static initContext(BuildContext context) => _context = context;

  static displayConnectionError({int statusCode}) {
    if (_context != null) {
      showCustomDialog(
        context: _context,
        child: CustomDialog(
          backgroundColor: Colors.transparent,
          child: OkDialog(
            title: _getResponse(statusCode),
            okText: "Cerrar",
            onPress: () => Navigator.pop(_context),
          ),
        ),
      );
    }
  }

  static displayGeneralDialog({String text}) {
    if (_context != null) {
      showCustomDialog(
        context: _context,
        child: CustomDialog(
          backgroundColor: Colors.transparent,
          child: OkDialog(
            title: text,
            okText: "Ok",
            onPress: () => Navigator.pop(_context),
          ),
        ),
      );
    }
  }

  static String _getResponse(int statusCode) {
    switch (statusCode) {
      case 501: case 500:
        return "Fallo el servidor";
      case 401:
        return "No autorizado";
      default:
        return "Sin conexión";
    }
  }

  static displayLoading() {
    if (_context != null) {
      displayLoadingScreen(_context);
    }
  }

  static popContext() {
    if (_context != null && Navigator.canPop(_context)) {
      Navigator.pop(_context);
    }
  }
}
