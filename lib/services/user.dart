import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:share_a_bike/model/trip.dart';
import '../helper/api.dart';
import '../helper/jwt.dart';
import '../model/current_trip.dart';

class UserService {
  static const String _userTripsPath = '/user/trips';
  static const String _userCurrentTripInfoPath = '/user/trip/current/info';
  static ValueNotifier<CurrentTripModel?> currentUserTrip =
      ValueNotifier<CurrentTripModel?>(null);
  static Timer? _timer;
  static bool _isFetchingCurrentUserTrips = false;

  static void startFetchingCurrentUserTripsPeriodically() {
    if (!_isFetchingCurrentUserTrips) {
      _isFetchingCurrentUserTrips = true;
      _timer = Timer.periodic(
          const Duration(seconds: 2),
          (Timer t) => getUserCurrentTrip().then((trip) {
                currentUserTrip.value = trip;
              }));
    }
  }

  static void stopFetchingCurrentUserTripsPeriodically() {
    if (_isFetchingCurrentUserTrips) {
      _isFetchingCurrentUserTrips = false;
      _timer?.cancel();
    }
  }

  static Future<List<TripModel>?> getUserTrips() async {
    if (kDebugMode) {
      print("[API: GETTING USER TRIPS]");
    }
    String token = await JwtHelper.getTokenFromStorage();
    return ApiHelper.getUri(_userTripsPath).then((uri) async {
      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<TripModel> trips = [];
        for (var trip in jsonResponse['trips']) {
          trips.add(TripModel.fromJson(trip));
        }
        if (kDebugMode) {
          print("[FETCHED TRIPS] ${trips.length}");
        }
        return trips;
      } else {
        return null;
      }
    });
  }

  static Future<CurrentTripModel?> getUserCurrentTrip() async {
    if (kDebugMode) {
      print("[API: GETTING USER CURRENT TRIP]");
    }
    String token = await JwtHelper.getTokenFromStorage();
    return ApiHelper.getUri(_userCurrentTripInfoPath).then((uri) async {
      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        CurrentTripModel? currentTrip;
        if (jsonResponse['currentTrip'] != null) {
          currentTrip = CurrentTripModel.fromJson(jsonResponse['currentTrip']);
        }
        if (kDebugMode) {
          print("[FETCHED CURRENT TRIP]");
        }
        return currentTrip;
      } else {
        return null;
      }
    });
  }
}
