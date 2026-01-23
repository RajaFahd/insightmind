import 'package:flutter/material.dart';

class CurvedBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const CurvedBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: colors ?? [
            const Color(0xFFFF9E87),
            Colors.white,
          ],
        ),
      ),
      child: child,
    );
  }
}
