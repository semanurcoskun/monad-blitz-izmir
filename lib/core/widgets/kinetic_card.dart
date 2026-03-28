import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class KineticCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;
  final bool hasAmbientShadow;

  const KineticCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius = 12.0,
    this.hasAmbientShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasAmbientShadow
            ? [
                BoxShadow(
                  color: AppColors.onSurface.withOpacity(0.04),
                  blurRadius: 40,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
