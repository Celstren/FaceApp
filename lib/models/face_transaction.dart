// To parse this JSON data, do
//
//     final transaction = transactionFromJson(jsonString);

import 'dart:convert';

FaceTransaction transactionFromJson(String str) => FaceTransaction.fromJson(json.decode(str));

String transactionToJson(FaceTransaction data) => json.encode(data.toJson());

class FaceTransaction {
    FaceTransaction({
        this.confidence,
        this.enrollmentTimestamp,
        this.eyeDistance,
        this.faceId,
        this.galleryName,
        this.height,
        this.pitch,
        this.quality,
        this.roll,
        this.status,
        this.subjectId,
        this.topLeftX,
        this.topLeftY,
        this.width,
        this.yaw,
    });

    num confidence;
    String enrollmentTimestamp;
    num eyeDistance;
    String faceId;
    String galleryName;
    num height;
    num pitch;
    num quality;
    num roll;
    String status;
    String subjectId;
    num topLeftX;
    num topLeftY;
    num width;
    num yaw;

    factory FaceTransaction.fromJson(Map<String, dynamic> json) => FaceTransaction(
        confidence: json["confidence"],
        enrollmentTimestamp: json["enrollment_timestamp"],
        eyeDistance: json["eyeDistance"],
        faceId: json["face_id"],
        galleryName: json["gallery_name"],
        height: json["height"],
        pitch: json["pitch"],
        quality: json["quality"],
        roll: json["roll"],
        status: json["status"],
        subjectId: json["subject_id"],
        topLeftX: json["topLeftX"],
        topLeftY: json["topLeftY"],
        width: json["width"],
        yaw: json["yaw"],
    );

    Map<String, dynamic> toJson() => {
        "confidence": confidence,
        "enrollment_timestamp": enrollmentTimestamp,
        "eyeDistance": eyeDistance,
        "face_id": faceId,
        "gallery_name": galleryName,
        "height": height,
        "pitch": pitch,
        "quality": quality,
        "roll": roll,
        "status": status,
        "subject_id": subjectId,
        "topLeftX": topLeftX,
        "topLeftY": topLeftY,
        "width": width,
        "yaw": yaw,
    };
}
