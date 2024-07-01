import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:share_a_bike/helper/api.dart';
import 'package:share_a_bike/helper/jwt.dart';
import 'package:share_a_bike/model/bike.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../enum/api/response.dart';

class BikeService {
  static const String _availableBikesPath = '/bikes';
  static const String _findAvailableByQrContent = '/bike/find/available/';
  static const String _rentBike = '/bike/';
  static ValueNotifier<BikeModel?> selectedBike =
      ValueNotifier<BikeModel?>(null);
  static final ValueNotifier<List<BikeModel>> bikes =
      ValueNotifier<List<BikeModel>>([]);
  static Timer? _timer;
  static bool _isFetchingBikes = false;
  static bool isFetchingAvailableBike = false;

  static void startFetchingData() {
    if (!_isFetchingBikes) {
      _isFetchingBikes = true;
      _timer = Timer.periodic(
          const Duration(seconds: 2),
          (Timer t) => getAllAvailableBikes().then((bikeList) {
                if (listEquals(bikes.value, bikeList) == false) {
                  bikes.value = bikeList ?? [];
                }
              }));
    }
  }

  static void stopFetchingData() {
    if (_isFetchingBikes) {
      _isFetchingBikes = false;
      _timer?.cancel();
    }
  }

  static Future<List<BikeModel>?> getAllAvailableBikes() async {
    String token = await JwtHelper.getTokenFromStorage();
    return ApiHelper.getUri(_availableBikesPath).then((uri) async {
      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<BikeModel> bikes = [];
        for (var bike in jsonResponse['bikes']) {
          bikes.add(BikeModel.fromJson(bike));
        }
        if (kDebugMode) {
          print("[FETCHED BIKES] ${bikes.length}");
        }
        return bikes;
      } else {
        return null;
      }
    });
  }

  static Future<BikeModel?> getAvailableBikeWithQrContent(String qr) async {
    String token = await JwtHelper.getTokenFromStorage();
    return ApiHelper.getUri(_findAvailableByQrContent + qr).then((uri) async {
      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        BikeModel bike = BikeModel.fromJson(jsonResponse);
        if (kDebugMode) {
          print("[FOUND BIKE]");
        }
        selectedBike.value = bike;
        return bike;
      } else {
        return null;
      }
    });
  }

  static Future<ApiResponse> rentBike(String qr, BikeModel bike) async {
    String token = await JwtHelper.getTokenFromStorage();
    Map<String, dynamic> jsonData = {
      'qrCodeContent': qr,
    };
    if (bike.isBtVerificationRequired) {
      jsonData['btMac'] = bike.btMac;
    }

    String jsonString = jsonEncode(jsonData);
    return ApiHelper.getUri('$_rentBike${bike.id}/rent').then((uri) async {
      var response = await http.post(
        uri,
        body: jsonString,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("[BIKE RENT REQUEST SENT]");
        }
        return ApiResponse.success;
      } else {
        return ApiResponse.error;
      }
    });
  }
}
