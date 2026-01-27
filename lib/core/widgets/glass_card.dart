import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/shadows.dart';

/// Carte en verre sophistiquée avec effets premium
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color? fillColor;
  final Color? borderColor;
  final double borderWidth;
  final bool hasHover;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 16,
    this.blur = 20,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 1,
    this.hasHover = true,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = widget.fillColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.glassFill.withValues(alpha: 0.1)
            : AppColors.surface.withValues(alpha: 0.85));

    final effectiveBorderColor = widget.borderColor ?? AppColors.glassBorder;

    return MouseRegion(
      onEnter: (_) {
        if (widget.hasHover) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
      },
      onExit: (_) {
        if (widget.hasHover) {
          setState(() => _isHovered = false);
          _controller.reverse();
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius),
                  boxShadow:
                      _isHovered ? AppShadows.dramatic : AppShadows.premium,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blur,
                      sigmaY: widget.blur,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            effectiveFillColor,
                            effectiveFillColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(widget.radius),
                        border: Border.all(
                          color: effectiveBorderColor,
                          width: widget.borderWidth,
                        ),
                      ),
                      child: Container(
                        // Effet de brillance interne
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            widget.radius - 1,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.glassHighlight,
                              Colors.transparent,
                              Colors.transparent,
                              AppColors.champagne.withValues(alpha: 0.05),
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                        padding: widget.padding,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
