import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_a_bike/model/trip.dart';
import 'package:share_a_bike/components/trip.dart';

class UserTripsScreen extends StatefulWidget {
  final List<TripModel> trips;

  const UserTripsScreen({super.key, required this.trips});

  @override
  State<UserTripsScreen> createState() => _UserTripsScreenState();
}

class _UserTripsScreenState extends State<UserTripsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('recent_trips').tr(),
      ),
      body: ListView.builder(
        itemCount: widget.trips.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              if (index != 0)
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                  indent: 10,
                  endIndent: 10,
                  height: 10,
                ),
              TripComponent(trip: widget.trips.reversed.toList()[index]),
            ],
          );
        },
      ),
    );
  }
}
