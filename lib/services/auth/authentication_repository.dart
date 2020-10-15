import 'dart:io';

import 'package:FaceApp/models/error_message.dart';
import 'package:FaceApp/models/face_transaction.dart';
import 'package:FaceApp/services/auth/authentication_provider.dart';
import 'package:FaceApp/utils/general/constant_helper.dart';
import 'package:FaceApp/utils/general/constant_method_helper.dart';
import 'package:FaceApp/utils/widgets/global_dialogs.dart';
import 'package:dio/dio.dart';

class AuthenticationRepository {
  static Future<bool> verifyFace(File photo,
      {String subjectId = "", String galleryName = ""}) async {
    Response response = await AuthenticationProvider.verifyFace(photo,
        subjectId: subjectId, galleryName: galleryName);
    if (response == null) return false;
    if ((response.statusCode == 201 || response.statusCode == 200) &&
        response.data["images"] != null) {
      var found = response.data["images"].firstWhere((element) {
        return FaceTransaction.fromJson(element["transaction"]).confidence >=
            ConstantHelper.MinConfidence;
      }, orElse: () => null);
      return found != null;
    }
    return false;
  }

  static Future<bool> enrollFace(File photo,
      {String subjectId = "", String galleryName = ""}) async {
    Response response = await AuthenticationProvider.enrollFace(photo,
        subjectId: subjectId, galleryName: galleryName);
    if (response == null) {
      GlobalDialogs.displayGeneralDialog(text: "Error de conexión al servidor");
      return false;
    }
    if ((response.statusCode == 201 || response.statusCode == 200) &&
        response.data["face_id"] != null) {
      return true;
    } else if (response.data["Errors"] != null &&
        response.data["Errors"].isNotEmpty) {
      GlobalDialogs.displayGeneralDialog(
          text: ConstantMethodHelper.translateErrorResponse(ErrorMessage.fromJson(response.data["Errors"].first)));
      return false;
    }
    GlobalDialogs.displayGeneralDialog(text: "Ocurrió un error inesperado");
    return false;
  }
}
