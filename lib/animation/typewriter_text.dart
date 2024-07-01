import 'package:flutter/material.dart';

class TypewriterTextTransition extends AnimatedWidget {
  final Widget text;
  final Animation<double> animation;

  const TypewriterTextTransition({
    Key? key,
    required this.text,
    required this.animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;

    if (text is Text) {
      final String fullText = (text as Text).data ?? '';
      final int cutoff = (fullText.length * animation.value).round();
      final String displayedText = fullText.substring(0, cutoff);

      return Text(
        displayedText,
        style: (text as Text).style,
      );
    }

    return text;
  }
}
