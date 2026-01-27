import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Widget d'étoiles de notation interactif et sophistiqué
class RatingStars extends StatefulWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;
  final bool enabled;

  const RatingStars({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 40,
    this.enabled = true,
  });

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _scaleAnimations = _controllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOut),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTap(int index) {
    if (!widget.enabled) return;
    final newRating = index + 1;
    widget.onRatingChanged(newRating);
    _controllers[index].forward().then((_) => _controllers[index].reverse());
  }

  void _handleHover(int? index) {
    if (!widget.enabled) return;
    setState(() => _hoveredIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < widget.rating;
        final isHovered = _hoveredIndex != null && index <= _hoveredIndex!;

        return MouseRegion(
          onEnter: (_) => _handleHover(index),
          onExit: (_) => _handleHover(null),
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: () => _handleTap(index),
            child: AnimatedBuilder(
              animation: _scaleAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimations[index].value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isFilled || isHovered ? Icons.star : Icons.star_border,
                        size: widget.size,
                        color: isFilled || isHovered
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
