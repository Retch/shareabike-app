import 'package:flutter/material.dart';

class BikeAnimatedIcon extends StatefulWidget {
  const BikeAnimatedIcon({super.key});

  @override
  BikeAnimatedIconState createState() => BikeAnimatedIconState();
}

class BikeAnimatedIconState extends State<BikeAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(5, 0),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: _animation.value,
          child: child,
        );
      },
      child: const Icon(Icons.directions_bike, size: 22, color: Colors.white),
    );
  }
}

void main() => runApp(
    const MaterialApp(home: Scaffold(body: Center(child: BikeAnimatedIcon()))));
