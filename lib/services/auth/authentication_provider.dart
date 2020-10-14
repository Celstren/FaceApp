import 'dart:io';

import 'package:FaceApp/services/config/dioClient.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AuthenticationProvider {
  static Future<Response> verifyFace(File photo,
      {String subjectId = "", String galleryName = ""}) async {
    try {
      if (photo != null) {
        String filename = basename(photo.path);
        List<String> parts = lookupMimeType(photo.path).split("/");
        FormData formData = FormData.fromMap({
          "subject_id": subjectId,
          "gallery_name": galleryName,
          "image": await MultipartFile.fromFile(
            photo.path,
            filename: filename,
            contentType: MediaType(parts[0], parts[1]),
          )
        });
        print("remove this");
        return await dioClient?.post("/verify", data: formData);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<Response> enrollFace(File photo,
      {String subjectId = "", String galleryName = ""}) async {
    try {
      if (photo != null) {
        String filename = basename(photo.path);
        List<String> parts = lookupMimeType(photo.path).split("/");
        FormData formData = FormData.fromMap({
          "subject_id": subjectId,
          "gallery_name": galleryName,
          "image": await MultipartFile.fromFile(
            photo.path,
            filename: filename,
            contentType: MediaType(parts[0], parts[1]),
          )
        });
        return await dioClient?.post("/enroll", data: formData);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
