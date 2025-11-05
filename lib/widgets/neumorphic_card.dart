import 'package:flutter/material.dart';
import '../themes/neumorphic_theme.dart';
import 'custom_neumorphic.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? depth;
  final BorderRadius? borderRadius;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.depth,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomNeumorphic(
      depth: depth,
      borderRadius: borderRadius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(NeumorphicThemeConfig.borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(NeumorphicThemeConfig.defaultPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

