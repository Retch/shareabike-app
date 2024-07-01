import 'dart:convert';

CurrentTripModel userModelFromJson(String str) =>
    CurrentTripModel.fromJson(json.decode(str));

String userModelToJson(CurrentTripModel data) => json.encode(data);

class CurrentTripModel {
  int id;
  int bikeId;
  DateTime start;
  int durationSeconds;

  CurrentTripModel({
    required this.id,
    required this.bikeId,
    required this.start,
    required this.durationSeconds,
  });

  factory CurrentTripModel.fromJson(Map<String, dynamic> json) =>
      CurrentTripModel(
        id: json["id"],
        bikeId: json["bikeId"],
        start:
            DateTime.fromMillisecondsSinceEpoch(json["startTimestamp"] * 1000),
        durationSeconds: json["durationSeconds"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "bikeId": bikeId,
        "startTimestamp": start.millisecondsSinceEpoch ~/ 1000,
        "durationSeconds": durationSeconds,
      };
}
