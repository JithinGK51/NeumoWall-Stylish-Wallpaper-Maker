import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../themes/neumorphic_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitSpinningLines(
      size: size ?? 50,
      color: color ?? Theme.of(context).colorScheme.primary,
      lineWidth: 3,
    );
  }
}

