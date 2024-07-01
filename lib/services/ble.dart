import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static Future<bool> isBluetoothMacNearby(String mac) async {
    var completer = Completer<bool>();
    if (kDebugMode) {
      print("[SEARCHING FOR BLE LOCK] $mac");
    }

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          if (kDebugMode) {
            print("[BLE FOUND LOCK]");
          }
          completer.complete(true);
        }
      },
      onError: (e) => {
        if (kDebugMode)
          {
            print(e),
          },
        completer.complete(false),
      },
    );

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(
        withRemoteIds: [mac], timeout: const Duration(seconds: 1));

    await FlutterBluePlus.isScanning.where((val) => val == false).first;
    return completer.future;
  }
}
