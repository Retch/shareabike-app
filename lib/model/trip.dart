import 'dart:convert';

List<TripModel> userModelFromJson(String str) =>
    List<TripModel>.from(json.decode(str).map((x) => TripModel.fromJson(x)));

String userModelToJson(List<TripModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TripModel {
  int id;
  DateTime start;
  DateTime end;
  int durationSeconds;

  TripModel({
    required this.id,
    required this.start,
    required this.end,
    required this.durationSeconds,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
        id: json["id"],
        start:
            DateTime.fromMillisecondsSinceEpoch(json["startTimestamp"] * 1000),
        end: DateTime.fromMillisecondsSinceEpoch(json["endTimestamp"] * 1000),
        durationSeconds: json["durationSeconds"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startTimestamp": start.millisecondsSinceEpoch ~/ 1000,
        "endTimestamp": end.millisecondsSinceEpoch ~/ 1000,
        "durationSeconds": durationSeconds,
      };
}
