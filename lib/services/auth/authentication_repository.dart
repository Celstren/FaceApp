import 'dart:io';

import 'package:FaceApp/models/face_transaction.dart';
import 'package:FaceApp/services/auth/authentication_provider.dart';
import 'package:FaceApp/utils/general/constant_helper.dart';
import 'package:dio/dio.dart';

class AuthenticationRepository {
  static Future<bool> verifyFace (File photo,
      {String subjectId = "", String galleryName = ""}) async {
    Response response = await AuthenticationProvider.verifyFace(photo, subjectId: subjectId, galleryName: galleryName);
    if (response == null) return false;
    if ((response.statusCode == 201 || response.statusCode == 200) && response.data["images"] != null) {
      var found = response.data["images"].firstWhere((element){
        return FaceTransaction.fromJson(element["transaction"]).confidence >= ConstantHelper.MinConfidence;
      }, orElse: () => null);
      return found != null;
    }
    return false;
  }

  static Future<bool> enrollFace (File photo,
      {String subjectId = "", String galleryName = ""}) async {
    Response response = await AuthenticationProvider.enrollFace(photo, subjectId: subjectId, galleryName: galleryName);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    }
    return false;
  }
}