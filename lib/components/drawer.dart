import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_a_bike/services/auth.dart';
import 'package:share_a_bike/services/user.dart';
import 'package:share_a_bike/helper/jwt.dart';
import 'package:share_a_bike/enum/api/response.dart';
import 'package:share_a_bike/screens/user_trips.dart';
import 'package:share_a_bike/screens/login.dart';

class DrawerComponent extends StatelessWidget {
  final BuildContext contextParent;

  const DrawerComponent({super.key, required this.contextParent});

  void _openUserTripsScreen() {
    UserService.getUserTrips().then((trips) => {
          if (trips != null)
            {
              Navigator.push(
                contextParent,
                MaterialPageRoute(
                    builder: (context) => UserTripsScreen(trips: trips)),
              )
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  const Color(0xFF529fff)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                  child: Text('Flotte',
                      style: GoogleFonts.pacifico(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                        ),
                      )),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.white54,
                          child: Icon(
                            Icons.account_circle,
                            size: 40.0,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                JwtHelper.getUsername()))
                      ],
                    ))
              ],
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.receipt_long_outlined),
                ),
                const Text('recent_trips').tr(),
              ],
            ),
            onTap: () {
              _openUserTripsScreen();
            },
          ),
          ListTile(
            title: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.logout_outlined),
                ),
                const Text('log_out').tr(),
              ],
            ),
            onTap: () {
              AuthService.logoutUser().then((response) {
                if (response == ApiResponse.success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
