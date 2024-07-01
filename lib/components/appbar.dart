import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';

class AppbarComponent extends StatelessWidget implements PreferredSizeWidget {
  const AppbarComponent({super.key, this.title = 'Flotte'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const HeroIcon(HeroIcons.bars3BottomLeft),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Text(
        title,
        style: GoogleFonts.pacifico(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 26,
          ),
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, const Color(0xFF529fff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 4,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: const [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
