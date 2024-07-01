import 'dart:convert';

List<BikeModel> userModelFromJson(String str) =>
    List<BikeModel>.from(json.decode(str).map((x) => BikeModel.fromJson(x)));

String userModelToJson(List<BikeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BikeModel {
  int id;
  int lockId;
  bool isAvailable;
  String latitudeHemisphere;
  double latitudeDegrees;
  String longitudeHemisphere;
  double longitudeDegrees;
  int lastContactUtcTimestamp;
  bool isBtVerificationRequired;
  String btMac;

  BikeModel({
    required this.id,
    required this.lockId,
    required this.isAvailable,
    required this.latitudeHemisphere,
    required this.latitudeDegrees,
    required this.longitudeHemisphere,
    required this.longitudeDegrees,
    required this.lastContactUtcTimestamp,
    required this.isBtVerificationRequired,
    required this.btMac,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) => BikeModel(
      id: json["id"],
      lockId: json["lockId"],
      isAvailable: json["isAvailable"],
      latitudeHemisphere: json["latitudeHemisphere"],
      latitudeDegrees: json["latitudeDegrees"],
      longitudeHemisphere: json["longitudeHemisphere"],
      longitudeDegrees: json["longitudeDegrees"],
      lastContactUtcTimestamp: json["lastContactUtcTimestamp"],
      isBtVerificationRequired: json["isBtVerificationRequired"],
      btMac: json["btMac"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "lockId": lockId,
        "isAvailable": isAvailable,
        "latitudeHemisphere": latitudeHemisphere,
        "latitudeDegrees": latitudeDegrees,
        "longitudeHemisphere": longitudeHemisphere,
        "longitudeDegrees": longitudeDegrees,
        "lastContactUtcTimestamp": lastContactUtcTimestamp,
        "isBtVerificationRequired": isBtVerificationRequired,
        "btMac": btMac,
      };
}
