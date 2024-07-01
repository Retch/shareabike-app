import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_a_bike/model/trip.dart';
import 'package:share_a_bike/helper/time.dart';

class TripComponent extends StatelessWidget {
  final TripModel trip;

  const TripComponent({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String tripId = trip.id.toString();
    int hours = TimeHelper.getHours(trip.durationSeconds);
    int minutes = TimeHelper.getRemainingMinutes(trip.durationSeconds);
    int seconds = TimeHelper.getRemainingSeconds(trip.durationSeconds);

    return ListTile(
        leading: const Icon(Icons.directions_bike),
        title: Text(
            "${tr('trip')} $tripId (${trip.start.day.toString().padLeft(2, '0')}.${trip.start.month.toString().padLeft(2, '0')}.${trip.start.year})"),
        subtitle: Text(
            "${'duration'.tr()}: ${hours > 0 ? "$hours ${hours == 1 ? 'hour'.tr() : 'hours'.tr()}, " : ""}"
            "${minutes > 0 ? "$minutes ${minutes == 1 ? 'minute'.tr() : 'minutes'.tr()}, " : ""}$seconds ${seconds == 1 ? 'second'.tr() : 'seconds'.tr()}"));
  }
}
