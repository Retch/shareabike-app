import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_a_bike/constants/constants.dart' as constants;
import 'package:share_a_bike/components/map.dart';
import 'package:share_a_bike/components/qr.dart';
import 'package:share_a_bike/components/appbar.dart';
import 'package:share_a_bike/components/drawer.dart';
import 'package:share_a_bike/services/bike.dart';
import 'package:share_a_bike/services/user.dart';
import 'package:share_a_bike/helper/qr_content.dart';
import 'package:share_a_bike/helper/time.dart';
import 'package:share_a_bike/components/animated_bike.dart';
import 'package:share_a_bike/animation/typewriter_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<String> _lockQrCode = ValueNotifier<String>("");
  bool _isQrCodeScanable = true;
  DateTime _lastScan = DateTime.now();
  Timer? _durationTimeUpdateTimer;
  bool _isTimerRunning = false;
  int _tripHours = 0;
  int _tripMinutes = 0;
  int _tripSeconds = 0;

  void _startDurationTimeUpdateTimer() {
    _isTimerRunning = true;
    _durationTimeUpdateTimer = Timer.periodic(const Duration(milliseconds: 250),
        (Timer t) => _updateTripDurationCounter());
  }

  void _stopDurationTimeUpdateTimer() {
    _isTimerRunning = false;
    _durationTimeUpdateTimer?.cancel();
  }

  void _updateTripDurationCounter() {
    setState(() {
      _tripHours = TimeHelper.getHours(DateTime.now()
          .difference(
              UserService.currentUserTrip.value?.start ?? DateTime.now())
          .inSeconds
          .abs());
      _tripMinutes = TimeHelper.getRemainingMinutes(DateTime.now()
          .difference(
              UserService.currentUserTrip.value?.start ?? DateTime.now())
          .inSeconds
          .abs());
      _tripSeconds = TimeHelper.getRemainingSeconds(DateTime.now()
          .difference(
              UserService.currentUserTrip.value?.start ?? DateTime.now())
          .inSeconds
          .abs());
    });
  }

  void onQrScanned(String value) {
    if (DateTime.now().difference(_lastScan).inSeconds.abs() > 2) {
      _lastScan = DateTime.now();
      String oldQr = _lockQrCode.value;
      if (oldQr != value) {
        _lockQrCode.value = value;
      } else {
        _lockQrCode.notifyListeners();
      }
      QrContentHelper.lastQrContent = value;
    } else {
      if (kDebugMode) {
        print("[QR Code scanned to fast]");
      }
    }
    Navigator.pop(context);
  }

  void openQrScannerModal() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 350,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28.0),
                      topRight: Radius.circular(28.0),
                    ),
                    child: SizedBox(
                        height: 350,
                        child: QrScannerComponent(
                            callback: (val) => onQrScanned(val))))
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    BikeService.startFetchingData();
    UserService.startFetchingCurrentUserTripsPeriodically();

    _lockQrCode.addListener(() {
      if (_lockQrCode.value != "") {
        if (kDebugMode) {
          print("[LOCK QR CODE] ${_lockQrCode.value}");
        }
        if (BikeService.selectedBike.value == null &&
            BikeService.isFetchingAvailableBike == false) {
          BikeService.isFetchingAvailableBike = true;
          BikeService.getAvailableBikeWithQrContent(_lockQrCode.value)
              .then((value) => BikeService.isFetchingAvailableBike = false);
        }
      }
    });

    UserService.currentUserTrip.addListener(() {
      if (UserService.currentUserTrip.value != null) {
        if (!_isTimerRunning) {
          _startDurationTimeUpdateTimer();
        }
        setState(() {
          _isQrCodeScanable = false;
        });
      } else {
        if (_isTimerRunning) {
          _stopDurationTimeUpdateTimer();
        }
        setState(() {
          _isQrCodeScanable = true;
        });
      }
    });

    return Scaffold(
      appBar: const AppbarComponent(),
      drawer: DrawerComponent(contextParent: context),
      body: const MapComponent(),
      floatingActionButton: Container(
          padding: const EdgeInsets.only(bottom: constants.fabBottomPadding),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: _isQrCodeScanable ? 180 : 225,
                    height: 54,
                    child: NiceButtons(
                      stretch: true,
                      disabled: !_isQrCodeScanable,
                      gradientOrientation: GradientOrientation.Horizontal,
                      startColor: Theme.of(context).primaryColor,
                      endColor: const Color(0xFF529fff),
                      onTap: (finish) {
                        if (_isQrCodeScanable) {
                          Timer(const Duration(milliseconds: 250), () {
                            openQrScannerModal();
                          });
                        }
                      },
                      child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 800),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return TypewriterTextTransition(
                              animation: animation,
                              text: child,
                            );
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isQrCodeScanable
                                    ? const Icon(Icons.qr_code_scanner,
                                        color: Colors.white)
                                    : const BikeAnimatedIcon(),
                                SizedBox(width: _isQrCodeScanable ? 6 : 12),
                                Text(
                                  _isQrCodeScanable
                                      ? tr('scan_bike_qr')
                                      : "${tr('lending_since')}: ${_tripHours}h ${_tripMinutes.toString().padLeft(2, '0')}m ${_tripSeconds.toString().padLeft(2, '0')}s",
                                  key: ValueKey<bool>(_isQrCodeScanable),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                )
                              ])),
                    )),
              ])),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
