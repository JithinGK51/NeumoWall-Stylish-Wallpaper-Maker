import 'package:flutter/material.dart';
import '../themes/neumorphic_theme.dart';
import 'custom_neumorphic.dart';

class NeumorphicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final double? width;
  final double? height;

  const NeumorphicButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? NeumorphicThemeConfig.minTapTargetSize,
      child: CustomNeumorphicButton(
        onPressed: onPressed,
        depth: isOutlined ? NeumorphicThemeConfig.lightDepth : NeumorphicThemeConfig.depth,
        color: isOutlined
            ? Colors.transparent
            : Theme.of(context).colorScheme.primary,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: NeumorphicThemeConfig.defaultPadding,
            vertical: NeumorphicThemeConfig.smallPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isOutlined
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOutlined
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

