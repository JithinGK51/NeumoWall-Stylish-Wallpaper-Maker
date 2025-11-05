// Custom Neumorphic widgets to replace flutter_neumorphic package
// This avoids compatibility issues with deprecated APIs

import 'package:flutter/material.dart';
import '../themes/neumorphic_theme.dart';

/// Custom Neumorphic container widget
class CustomNeumorphic extends StatelessWidget {
  final Widget child;
  final double? depth;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const CustomNeumorphic({
    super.key,
    required this.child,
    this.depth,
    this.color,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final depthValue = depth ?? NeumorphicThemeConfig.depth;
    final bgColor = color ?? Theme.of(context).colorScheme.surface;
    
    // Calculate shadow colors based on theme
    final lightShadow = isDark 
        ? const Color(0xFF3D3D4D).withOpacity(0.5)
        : Colors.white.withOpacity(0.8);
    final darkShadow = isDark
        ? const Color(0xFF0F0F1F).withOpacity(0.5)
        : Colors.black.withOpacity(0.1);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? BorderRadius.circular(NeumorphicThemeConfig.borderRadius),
        boxShadow: [
          // Dark shadow (bottom-right)
          BoxShadow(
            color: darkShadow,
            blurRadius: depthValue,
            spreadRadius: 1,
            offset: Offset(depthValue / 2, depthValue / 2),
          ),
          // Light shadow (top-left)
          BoxShadow(
            color: lightShadow,
            blurRadius: depthValue,
            spreadRadius: 1,
            offset: Offset(-depthValue / 2, -depthValue / 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Custom Neumorphic button
class CustomNeumorphicButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? depth;
  final Color? color;
  final BorderRadius? borderRadius;

  const CustomNeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.depth,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomNeumorphic(
        depth: depth ?? NeumorphicThemeConfig.lightDepth,
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(NeumorphicThemeConfig.borderRadius),
        child: child,
      ),
    );
  }
}

/// Pressed/inset neumorphic style
class CustomNeumorphicInset extends StatelessWidget {
  final Widget child;
  final double? depth;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const CustomNeumorphicInset({
    super.key,
    required this.child,
    this.depth,
    this.color,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final depthValue = depth ?? NeumorphicThemeConfig.depth;
    final bgColor = color ?? Theme.of(context).colorScheme.surface;
    
    final lightShadow = isDark 
        ? const Color(0xFF3D3D4D).withOpacity(0.3)
        : Colors.white.withOpacity(0.6);
    final darkShadow = isDark
        ? const Color(0xFF0F0F1F).withOpacity(0.3)
        : Colors.black.withOpacity(0.15);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? BorderRadius.circular(NeumorphicThemeConfig.borderRadius),
        boxShadow: [
          // Inset shadows (reversed)
          BoxShadow(
            color: darkShadow,
            blurRadius: depthValue,
            spreadRadius: -1,
            offset: Offset(-depthValue / 2, -depthValue / 2),
          ),
          BoxShadow(
            color: lightShadow,
            blurRadius: depthValue,
            spreadRadius: -1,
            offset: Offset(depthValue / 2, depthValue / 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

