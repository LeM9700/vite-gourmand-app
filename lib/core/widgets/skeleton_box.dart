import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
