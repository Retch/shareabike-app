import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:share_a_bike/constants/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_a_bike/model/bike.dart';
import 'package:share_a_bike/services/bike.dart';
import 'package:share_a_bike/services/location.dart';
import 'package:share_a_bike/services/ble.dart';
import '../helper/qr_content.dart';

class MapComponent extends StatefulWidget {
  const MapComponent({super.key});

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent>
    with TickerProviderStateMixin {
  static const _useTransformerId = 'useTransformerId';
  final bool _useTransformer = true;
  late final _animatedMapController = AnimatedMapController(vsync: this);
  final double _zoom = 17.0;
  final List<Marker> _markers = [];
  DateTime _lastBikeSelected = DateTime.now();
  bool _isBikeSelected = false;
  bool _wasMapCenterChanged = true;

  onMapMarkerSelected(bool isQrCodeVerified, BikeModel bike) {
    if (_isBikeSelected) {
      return;
    }
    if (kDebugMode) {
      print("Bike marker selected");
    }
    _isBikeSelected = true;
    DateTime lastContact = DateTime.fromMillisecondsSinceEpoch(
        bike.lastContactUtcTimestamp * 1000);
    int lastContactSecondsAgo =
        DateTime.now().difference(lastContact).inSeconds.abs();
    String lastContactString = "";
    switch (lastContactSecondsAgo) {
      case < 60:
        lastContactString = "time_ago.few_seconds";
        break;
      case < 600:
        lastContactString = "time_ago.few_minutes";
        break;
      case < 3600:
        lastContactString = "time_ago.several_minutes";
        break;
      case < 86400:
        lastContactString = "time_ago.several_hours";
        break;
      case < 172800:
        lastContactString = "time_ago.yesterday";
        break;
      default:
        lastContactString = "time_ago.several_days";
        break;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${tr('bike_no')} ${bike.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    "${tr('last_ping')}: ${lastContactString.tr()}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        height: 100,
                        image: AssetImage('assets/images/bike_rent.webp'),
                      ),
                      if (isQrCodeVerified)
                        Container(
                            margin: const EdgeInsets.only(left: 42),
                            child: SizedBox(
                              height: 100,
                              width: 150,
                              child: NiceButtons(
                                height: 100,
                                stretch: true,
                                progress: true,
                                startColor: Theme.of(context).primaryColor,
                                borderColor: Theme.of(context).primaryColor,
                                gradientOrientation:
                                    GradientOrientation.Horizontal,
                                onTap: (finish) {
                                  Timer(const Duration(seconds: 2), () {
                                    sendRentBikeRequestWithMacOrWithout(bike)
                                        .then((value) => {
                                              if (value) {finish()},
                                              Timer(
                                                  const Duration(
                                                      milliseconds: 300), () {
                                                Navigator.of(context).pop();
                                              })
                                            });
                                  });
                                },
                                child: const Text(
                                  'unlock',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ).tr(),
                              ),
                            ))
                    ],
                  )
                ],
              ),
            )
          ],
        );
      },
    ).then((value) => Timer(const Duration(milliseconds: 200), () {
          _isBikeSelected = false;

          BikeService.selectedBike.value = null;
          _animatedMapController.animatedZoomOut(
            customId: _useTransformer ? _useTransformerId : null,
          );
        }));
  }

  Future<bool> sendRentBikeRequestWithMacOrWithout(BikeModel bike) {
    var completer = Completer<bool>();
    if (bike.isBtVerificationRequired) {
      BleService.isBluetoothMacNearby(bike.btMac).then((value) => {
            if (value)
              {
                sendRentBikeRequest(bike)
                    .then((value) => completer.complete(value))
              }
            else
              {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('error.could_not_connect_to_lock').tr(),
                  ),
                )
              }
          });
    } else {
      sendRentBikeRequest(bike).then((value) => completer.complete(value));
    }

    return completer.future;
  }

  Future<bool> sendRentBikeRequest(BikeModel bike) {
    var completer = Completer<bool>();
    BikeService.rentBike(QrContentHelper.lastQrContent, bike)
        .then((value) => completer.complete(true));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    _markers.clear();
    for (var bike in BikeService.bikes.value) {
      _markers.add(Marker(
          point: LatLng(bike.latitudeDegrees, bike.longitudeDegrees),
          width: 34,
          height: 34,
          child: FloatingActionButton(
            onPressed: () {
              _animatedMapController
                  .animateTo(
                      dest: LatLng(bike.latitudeDegrees, bike.longitudeDegrees),
                      zoom: _zoom + 1)
                  .then((value) => onMapMarkerSelected(false, bike));
            },
            shape: const CircleBorder(),
            child: Image.asset('assets/images/bike_icon.webp'),
          )));
    }

    _animatedMapController.mapController.mapEventStream
        .listen((MapEvent event) {
      if (event is MapEventMove) {
        if (_wasMapCenterChanged == false) {
          setState(() {
            _wasMapCenterChanged = true;
          });
        }
      }
    });

    BikeService.bikes.addListener(() {
      setState(() {});
    });

    LocationService.mapCenter.addListener(() {
      if (kDebugMode) {
        print("[SETTING MAP TO NEW CENTER]");
      }
      _animatedMapController
          .centerOnPoint(LocationService.mapCenter.value, zoom: _zoom)
          .then((value) {
        _animatedMapController.animatedRotateReset();
        if (_wasMapCenterChanged == true) {
          setState(() {
            _wasMapCenterChanged = false;
          });
        }
      });
    });

    BikeService.selectedBike.addListener(() {
      if (BikeService.selectedBike.value != null) {
        if (DateTime.now().difference(_lastBikeSelected).inSeconds.abs() > 1) {
          _lastBikeSelected = DateTime.now();
          if (BikeService.selectedBike.value?.latitudeDegrees != null &&
              BikeService.selectedBike.value?.longitudeDegrees != null) {
            LatLng bikeLocation = LatLng(
                BikeService.selectedBike.value!.latitudeDegrees,
                BikeService.selectedBike.value!.longitudeDegrees);
            _animatedMapController
                .animateTo(dest: bikeLocation, zoom: _zoom + 1)
                .then((value) =>
                    onMapMarkerSelected(true, BikeService.selectedBike.value!));
          }
        }
      } else {
        _animatedMapController.centerOnPoint(LocationService.mapCenter.value,
            zoom: _zoom);
      }
    });

    return Stack(children: [
      FlutterMap(
        mapController: _animatedMapController.mapController,
        options: MapOptions(
          initialCenter: LocationService.mapCenter.value,
          initialZoom: _zoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          CurrentLocationLayer(
            style: LocationMarkerStyle(
                marker: DefaultLocationMarker(
              color: Theme.of(context).primaryColor,
            )),
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
      Positioned(
          bottom: constants.fabBottomPadding,
          right: 10,
          child: SizedBox(
              height: 54,
              width: 54,
              child: NiceButtons(
                stretch: true,
                disabled: !_wasMapCenterChanged,
                startColor: const Color(0xFF529fff),
                endColor: const Color(0xFF529fff),
                borderColor: Theme.of(context).primaryColor,
                gradientOrientation: GradientOrientation.Horizontal,
                onTap: (finish) {
                  LocationService.getCurrentLocationAndUpdateMapCenter();
                },
                child: Icon(
                    _wasMapCenterChanged
                        ? Icons.near_me_outlined
                        : Icons.near_me,
                    color: Colors.white),
              ))),
    ]);
  }
}
